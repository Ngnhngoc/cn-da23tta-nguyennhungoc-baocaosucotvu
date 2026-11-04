import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class TechnicianScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const TechnicianScreen({super.key, required this.user});

  @override
  State<TechnicianScreen> createState() => _TechnicianScreenState();
}

class _TechnicianScreenState extends State<TechnicianScreen> {
  final ApiService _api = ApiService();
  List<dynamic> _incidents = [];
  bool _isLoading = true;
  bool _onlyAssignedToMe = true;

  @override
  void initState() {
    super.initState();
    _loadIncidents();
  }

  Future<void> _loadIncidents() async {
    setState(() => _isLoading = true);
    final incidents = await _api.getAllIncidents(assignedToMe: _onlyAssignedToMe);
    if (mounted) {
      setState(() {
        _incidents = incidents;
        _isLoading = false;
      });
    }
  }

  void _showZoomImage(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  errorBuilder: (c, e, s) => Container(
                    padding: const EdgeInsets.all(24),
                    color: Colors.white,
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.broken_image, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Không thể tải ảnh'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: InkWell(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                  child: const Icon(Icons.close, color: Colors.white, size: 22),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateStatusDialog(Map<String, dynamic> item, String targetStatus) {
    final noteCtrl = TextEditingController(
      text: targetStatus == 'Đang xử lý' 
          ? 'Kỹ thuật viên đã tiếp nhận và đang tiến hành kiểm tra sửa chữa.' 
          : 'Đã thay thế linh kiện, kiểm tra hoạt động tốt và dọn dẹp hiện trường.',
    );
    bool isSaving = false;
    final List<Uint8List> resolvedImagesBytesList = [];
    final List<String> resolvedImagesNamesList = [];
    final ImagePicker picker = ImagePicker();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) {
          // 1. Chụp ảnh từ camera điện thoại
          Future<void> captureFromCamera() async {
            if (resolvedImagesBytesList.length >= 5) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('⚠️ Đã đạt tối đa 5 ảnh bằng chứng nghiệm thu!')),
              );
              return;
            }
            try {
              final XFile? photo = await picker.pickImage(
                source: ImageSource.camera,
                maxWidth: 1280,
                maxHeight: 1280,
                imageQuality: 85,
              );
              if (photo != null) {
                final bytes = await photo.readAsBytes();
                setDlgState(() {
                  if (resolvedImagesBytesList.length < 5) {
                    resolvedImagesBytesList.add(bytes);
                    resolvedImagesNamesList.add(photo.name);
                  }
                });
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lỗi mở máy ảnh: $e')),
                );
              }
            }
          }

          // 2. Tải ảnh từ thư viện thiết bị (hỗ trợ chọn nhiều ảnh cùng lúc)
          Future<void> pickFromGallery() async {
            if (resolvedImagesBytesList.length >= 5) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('⚠️ Đã đạt tối đa 5 ảnh bằng chứng nghiệm thu!')),
              );
              return;
            }
            try {
              final List<XFile> photos = await picker.pickMultiImage(
                maxWidth: 1280,
                maxHeight: 1280,
                imageQuality: 85,
              );
              if (photos.isNotEmpty) {
                for (final photo in photos) {
                  if (resolvedImagesBytesList.length >= 5) break;
                  final bytes = await photo.readAsBytes();
                  resolvedImagesBytesList.add(bytes);
                  resolvedImagesNamesList.add(photo.name);
                }
                setDlgState(() {});
              }
            } catch (_) {
              // Fallback nếu pickMultiImage không khả dụng
              try {
                final XFile? photo = await picker.pickImage(
                  source: ImageSource.gallery,
                  maxWidth: 1280,
                  maxHeight: 1280,
                  imageQuality: 85,
                );
                if (photo != null) {
                  final bytes = await photo.readAsBytes();
                  setDlgState(() {
                    if (resolvedImagesBytesList.length < 5) {
                      resolvedImagesBytesList.add(bytes);
                      resolvedImagesNamesList.add(photo.name);
                    }
                  });
                }
              } catch (err) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi mở thư viện: $err')),
                  );
                }
              }
            }
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Icon(
                  targetStatus == 'Đang xử lý' ? Icons.play_circle_fill : Icons.verified,
                  color: targetStatus == 'Hoàn thành' ? Colors.green : const Color(0xFF0D47A1),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  targetStatus == 'Đang xử lý' ? 'TIẾP NHẬN SỰ CỐ' : 'HOÀN TẤT & NGHIỆM THU',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            content: SizedBox(
              width: 440,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Mã phiếu: ${item['ma_phieu_su_co']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
                          const SizedBox(height: 2),
                          Builder(builder: (_) {
                            final r = item['phongHoc'] ?? item['phong_hoc'];
                            final soPhong = r != null ? (r['so_phong_day_du'] ?? 'B21.${r['so_phong']}') : '${item['ma_phong_hoc']}';
                            var khu = r != null ? (r['ten_khu'] ?? 'Tòa B').toString() : 'Tòa B';
                            if (khu.startsWith('Khu ')) khu = khu.replaceFirst('Khu ', 'Tòa ');
                            return Text('Phòng học: $soPhong ($khu)', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600));
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('Ghi chú xử lý / Biên bản khắc phục: *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: noteCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Nhập chi tiết linh kiện thay thế, giải pháp xử lý...',
                        isDense: true,
                      ),
                    ),
                    if (targetStatus == 'Hoàn thành') ...[
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Ảnh bằng chứng nghiệm thu: *',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1B5E20)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: resolvedImagesBytesList.isNotEmpty ? Colors.green.shade50 : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: resolvedImagesBytesList.isNotEmpty ? Colors.green.shade400 : Colors.grey.shade300,
                              ),
                            ),
                            child: Text(
                              '${resolvedImagesBytesList.length}/5 ảnh',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: resolvedImagesBytesList.isNotEmpty ? Colors.green.shade800 : Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Chụp ảnh máy ảnh điện thoại hoặc tải ảnh hiện trường sau khi sửa (tối đa 5 ảnh):',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),

                      // Danh sách thumbnail ảnh đã chụp / tải lên
                      if (resolvedImagesBytesList.isNotEmpty) ...[
                        SizedBox(
                          height: 88,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: resolvedImagesBytesList.length,
                            separatorBuilder: (c, i) => const SizedBox(width: 8),
                            itemBuilder: (context, idx) {
                              final bytes = resolvedImagesBytesList[idx];
                              return Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.green.shade600, width: 2),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: Image.memory(
                                        bytes,
                                        width: 84,
                                        height: 84,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: -5,
                                    right: -5,
                                    child: InkWell(
                                      onTap: () => setDlgState(() {
                                        resolvedImagesBytesList.removeAt(idx);
                                        resolvedImagesNamesList.removeAt(idx);
                                      }),
                                      child: Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                                        ),
                                        child: const Icon(Icons.close, color: Colors.white, size: 14),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],

                      // 2 Nút: Mở Camera & Thư viện ảnh
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF1B5E20),
                                side: const BorderSide(color: Color(0xFF1B5E20), width: 1.5),
                                padding: const EdgeInsets.symmetric(vertical: 9),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              icon: const Icon(Icons.camera_alt, size: 17),
                              label: const Text('Mở Camera', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                              onPressed: resolvedImagesBytesList.length < 5 ? () => captureFromCamera() : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.teal.shade800,
                                side: BorderSide(color: Colors.teal.shade700, width: 1.5),
                                padding: const EdgeInsets.symmetric(vertical: 9),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              icon: const Icon(Icons.photo_library, size: 17),
                              label: const Text('Thư Viện Ảnh', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                              onPressed: resolvedImagesBytesList.length < 5 ? () => pickFromGallery() : null,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Hủy'),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: targetStatus == 'Hoàn thành' ? Colors.green.shade700 : const Color(0xFF0D47A1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: isSaving 
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.check, size: 18),
                onPressed: isSaving
                    ? null
                    : () async {
                        setDlgState(() => isSaving = true);
                        final res = await _api.updateIncidentStatus(
                          item['ma_su_co_id'],
                          targetStatus,
                          note: noteCtrl.text.trim(),
                          imagesBytesList: resolvedImagesBytesList,
                          imagesNamesList: resolvedImagesNamesList,
                        );
                        setDlgState(() => isSaving = false);

                        if (context.mounted) {
                          Navigator.pop(ctx);
                          if (res['status'] == 'success') {
                            final count = resolvedImagesBytesList.length;
                            final msg = count > 0 
                                ? '✅ Đã hoàn tất và lưu $count ảnh bằng chứng nghiệm thu!' 
                                : '✅ Đã cập nhật trạng thái: $targetStatus';
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(msg), backgroundColor: Colors.green),
                            );
                            _loadIncidents();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(res['message'] ?? 'Thất bại'), backgroundColor: Colors.red),
                            );
                          }
                        }
                      },
                label: Text(
                  targetStatus == 'Hoàn thành' ? 'Xác Nhận Hoàn Thành & Nghiệm Thu' : 'Xác Nhận Tiếp Nhận',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showReporterDialog(Map<String, dynamic> item) {
    final rep = item['nguoi_bao_cao_info'] ?? item['nguoiBaoCao'];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.person, color: Color(0xFF1B5E20)),
            SizedBox(width: 8),
            Text('THÔNG TIN NGƯỜI BÁO CÁO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Họ và tên:', rep != null ? (rep['ho_va_ten'] ?? 'Nguyễn Như Ngọc') : 'Nguyễn Như Ngọc'),
            _buildInfoRow('Mã SV / GV:', rep != null ? (rep['ten_dang_nhap'] ?? '110123030') : '110123030'),
            _buildInfoRow('Vai trò:', rep != null ? (rep['vai_tro'] ?? 'Sinh viên') : 'Sinh viên'),
            _buildInfoRow('Lớp / Đơn vị:', rep != null ? (rep['lop_don_vi'] ?? rep['lop_hoac_don_vi'] ?? 'DA23TTA') : 'DA23TTA'),
            _buildInfoRow('Số điện thoại:', rep != null ? (rep['so_dien_thoai'] ?? '0912345678') : '0912345678'),
            _buildInfoRow('Email TVU:', rep != null ? (rep['email_tvu'] ?? '110123030@st.tvu.edu.vn') : '110123030@st.tvu.edu.vn'),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B5E20)),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: Colors.grey)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Chờ tiếp nhận': return Colors.orange;
      case 'Đang xử lý': return Colors.blue;
      case 'Hoàn thành': return Colors.green;
      default: return Colors.grey;
    }
  }

  Widget _buildPhotoThumbnails(List<dynamic> list, String label, Color badgeColor) {
    if (list.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: badgeColor)),
            const SizedBox(width: 6),
            Text('(${list.length} ảnh)', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          ],
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 70,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: list.length,
            separatorBuilder: (c, i) => const SizedBox(width: 8),
            itemBuilder: (context, idx) {
              final raw = list[idx];
              final imgUrl = raw is String ? raw : (raw['duong_dan_anh'] ?? '');
              return InkWell(
                onTap: () => _showZoomImage(context, imgUrl),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: badgeColor.withValues(alpha: 0.5)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                    child: Image.network(
                      imgUrl,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        width: 70,
                        height: 70,
                        color: Colors.grey.shade100,
                        child: const Icon(Icons.broken_image, size: 24, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final userName = widget.user['ho_va_ten'] ?? 'Kỹ thuật viên';
    final userUnit = widget.user['lop_don_vi'] ?? 'Tổ Kỹ Thuật TVU';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text('Kỹ Thuật Viên TVU', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1B5E20), // Xanh lá kỹ thuật
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadIncidents,
            tooltip: 'Làm mới',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _api.logout();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header KTV
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 26,
                  backgroundColor: Color(0xFF1B5E20),
                  child: Icon(Icons.handyman, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('$userUnit', style: TextStyle(color: Colors.grey[700], fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tab lọc
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('Được giao cho tôi')),
                    selected: _onlyAssignedToMe,
                    onSelected: (val) {
                      setState(() => _onlyAssignedToMe = true);
                      _loadIncidents();
                    },
                    selectedColor: const Color(0xFF1B5E20),
                    labelStyle: TextStyle(
                      color: _onlyAssignedToMe ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('Tất cả sự cố')),
                    selected: !_onlyAssignedToMe,
                    onSelected: (val) {
                      setState(() => _onlyAssignedToMe = false);
                      _loadIncidents();
                    },
                    selectedColor: const Color(0xFF1B5E20),
                    labelStyle: TextStyle(
                      color: !_onlyAssignedToMe ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Danh sách sự cố
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _incidents.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline, size: 60, color: Colors.grey[400]),
                            const SizedBox(height: 10),
                            Text(
                              _onlyAssignedToMe ? 'Bạn chưa có sự cố nào được phân công' : 'Chưa có sự cố nào trong hệ thống',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadIncidents,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(14),
                          itemCount: _incidents.length,
                          itemBuilder: (context, index) {
                            final item = _incidents[index];
                            final status = item['trang_thai'] ?? 'Chờ tiếp nhận';
                            final room = item['phongHoc'] ?? item['phong_hoc'];
                            String roomText;
                            if (room != null) {
                              final soPhong = room['so_phong_day_du'] ?? 'B21.${room['so_phong']}';
                              var khu = (room['ten_khu'] ?? 'Tòa B').toString();
                              if (khu.startsWith('Khu ')) khu = khu.replaceFirst('Khu ', 'Tòa ');
                              roomText = 'Phòng $soPhong ($khu)';
                            } else {
                              roomText = 'Phòng #${item['ma_phong_hoc']}';
                            }
                            final reporter = item['nguoiBaoCao'] ?? item['nguoi_bao_cao'];
                            final reporterName = reporter != null ? reporter['ho_va_ten'] : 'Sinh viên TVU';

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          item['ma_phieu_su_co'] ?? 'Phiếu SC',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(status).withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            status,
                                            style: TextStyle(
                                              color: _getStatusColor(status),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      item['mo_ta_hu_hong'] ?? '',
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.meeting_room, size: 15, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(roomText, style: TextStyle(color: Colors.grey[800], fontSize: 13, fontWeight: FontWeight.w500)),
                                        const SizedBox(width: 14),
                                        const Icon(Icons.person, size: 15, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text('Báo bởi: $reporterName', style: TextStyle(color: Colors.grey[700], fontSize: 12)),
                                      ],
                                    ),
                                    if (item['vi_tri_trong_phong'] != null && (item['vi_tri_trong_phong'] as String).isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text('Vị trí: ${item['vi_tri_trong_phong']}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                    ],

                                    // Hiển thị ảnh hiện trường & ảnh bằng chứng nghiệm thu của KTV
                                    Builder(builder: (context) {
                                      final rawImages = (item['hinh_anh_list'] as List<dynamic>?) ?? [];
                                      final reportImages = rawImages.where((i) => (i is Map && i['loai_hinh_anh'] != 'Nghiệm thu') || (i is String && !i.contains('resolved'))).toList();
                                      final proofImages = rawImages.where((i) => (i is Map && i['loai_hinh_anh'] == 'Nghiệm thu') || (i is String && i.contains('resolved'))).toList();

                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          _buildPhotoThumbnails(reportImages, '📷 Ảnh hiện trường ban đầu', const Color(0xFF0D47A1)),
                                          _buildPhotoThumbnails(proofImages, '🛠️ Bằng chứng nghiệm thu của KTV', const Color(0xFF1B5E20)),
                                        ],
                                      );
                                    }),

                                    const Divider(height: 18),

                                    // Các nút thao tác của Kỹ thuật viên
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        OutlinedButton.icon(
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: const Color(0xFF1B5E20),
                                            side: BorderSide(color: Colors.green.shade300),
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                            visualDensity: VisualDensity.compact,
                                          ),
                                          icon: const Icon(Icons.badge_outlined, size: 15),
                                          label: const Text('Xem Người Báo', style: TextStyle(fontSize: 12)),
                                          onPressed: () => _showReporterDialog(item),
                                        ),
                                        Row(
                                          children: [
                                            if (status == 'Chờ tiếp nhận') ...[
                                              ElevatedButton.icon(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.blue.shade700,
                                                  foregroundColor: Colors.white,
                                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                  visualDensity: VisualDensity.compact,
                                                ),
                                                icon: const Icon(Icons.play_arrow, size: 16),
                                                label: const Text('Tiếp Nhận', style: TextStyle(fontSize: 12)),
                                                onPressed: () => _showUpdateStatusDialog(item, 'Đang xử lý'),
                                              ),
                                            ],
                                            if (status == 'Đang xử lý') ...[
                                              ElevatedButton.icon(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.green.shade700,
                                                  foregroundColor: Colors.white,
                                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                  visualDensity: VisualDensity.compact,
                                                ),
                                                icon: const Icon(Icons.check_circle, size: 16),
                                                label: const Text('Hoàn Tất & Nghiệm Thu', style: TextStyle(fontSize: 12)),
                                                onPressed: () => _showUpdateStatusDialog(item, 'Hoàn thành'),
                                              ),
                                            ],
                                            if (status == 'Hoàn thành') ...[
                                              const Text('✅ Đã xong', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12.5)),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
