import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _api = ApiService();
  List<dynamic> _incidents = [];
  List<dynamic> _rooms = [];
  List<dynamic> _types = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final incidents = await _api.getMyIncidents();
    final rooms = await _api.getRooms();
    final types = await _api.getIncidentTypes();

    if (mounted) {
      setState(() {
        _incidents = incidents;
        _rooms = rooms;
        _types = types;
        _isLoading = false;
      });
    }
  }

  void _showReportDialog() {
    int? selectedRoomId = _rooms.isNotEmpty ? _rooms.first['ma_phong_hoc'] : null;
    int? selectedTypeId = _types.isNotEmpty ? _types.first['ma_loai_su_co'] : null;
    final descCtrl = TextEditingController();
    final locationCtrl = TextEditingController();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'BÁO CÁO SỰ CỐ MỚI',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D47A1),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // Chọn phòng học
                const Text('Phòng học:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                DropdownButtonFormField<int>(
                  value: selectedRoomId,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: _rooms.map<DropdownMenuItem<int>>((r) {
                    return DropdownMenuItem<int>(
                      value: r['ma_phong_hoc'],
                      child: Text('Phòng ${r['so_phong']} (${r['ma_qr_dinh_danh'] ?? 'Tầng ${r['tang_so']}'})'),
                    );
                  }).toList(),
                  onChanged: (val) => setModalState(() => selectedRoomId = val),
                ),
                const SizedBox(height: 15),

                // Chọn loại sự cố
                const Text('Loại sự cố:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                DropdownButtonFormField<int>(
                  value: selectedTypeId,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: _types.map<DropdownMenuItem<int>>((t) {
                    return DropdownMenuItem<int>(
                      value: t['ma_loai_su_co'],
                      child: Text(t['ten_loai_su_co']),
                    );
                  }).toList(),
                  onChanged: (val) => setModalState(() => selectedTypeId = val),
                ),
                const SizedBox(height: 15),

                // Vị trí trong phòng
                const Text('Vị trí trong phòng (tùy chọn):', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(
                  controller: locationCtrl,
                  decoration: const InputDecoration(
                    hintText: 'VD: Bàn 3 dãy giữa, gần cửa sổ...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),

                // Mô tả hư hỏng
                const Text('Mô tả chi tiết hư hỏng:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(
                  controller: descCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'VD: Máy lạnh kêu to, chảy nước, quạt trần không quay...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),

                // Nút gửi
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D47A1),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: isSubmitting
                        ? null
                        : () async {
                            final desc = descCtrl.text.trim();
                            if (selectedRoomId == null || selectedTypeId == null || desc.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Vui lòng điền mô tả sự cố!')),
                              );
                              return;
                            }

                            setModalState(() => isSubmitting = true);
                            final res = await _api.createIncident(
                              roomId: selectedRoomId!,
                              typeId: selectedTypeId!,
                              description: desc,
                              location: locationCtrl.text.trim(),
                            );
                            setModalState(() => isSubmitting = false);

                            if (mounted) {
                              Navigator.pop(ctx);
                              if (res['status'] == 'success') {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('✅ Gửi báo cáo thành công!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                _loadData();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(res['message'] ?? 'Có lỗi xảy ra'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                    child: isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('GỬI BÁO CÁO SỰ CỐ', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Chờ tiếp nhận':
        return Colors.orange;
      case 'Đang xử lý':
        return Colors.blue;
      case 'Hoàn thành':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userName = widget.user['ho_va_ten'] ?? 'Sinh viên TVU';
    final userRole = widget.user['vai_tro'] ?? 'Sinh viên';
    final userClass = widget.user['lop_don_vi'] ?? 'DA23TTA';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text('TVU - Báo Cáo Sự Cố', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
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
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card thông tin sinh viên
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 28,
                        backgroundColor: Color(0xFF0D47A1),
                        child: Icon(Icons.person, color: Colors.white, size: 32),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$userRole • Lớp: $userClass',
                              style: TextStyle(color: Colors.grey[700], fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Nút hành động báo cáo nhanh
              InkWell(
                onTap: _showReportDialog,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo, color: Colors.white, size: 28),
                      SizedBox(width: 12),
                      Text(
                        'BÁO CÁO SỰ CỐ MỚI',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Tiêu đề danh sách
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Sự cố bạn đã gửi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF263238)),
                  ),
                  Text(
                    '${_incidents.length} phiếu',
                    style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Danh sách sự cố
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_incidents.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.assignment_turned_in_outlined, size: 60, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      Text(
                        'Chưa có báo cáo sự cố nào',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Bấm "BÁO CÁO SỰ CỐ MỚI" ở trên để gửi phản ánh.',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _incidents.length,
                  itemBuilder: (context, index) {
                    final item = _incidents[index];
                    final status = item['trang_thai'] ?? 'Chờ tiếp nhận';
                    final room = item['phong_hoc'];
                    final roomText = room != null ? 'Phòng ${room['so_phong']}' : 'Phòng #${item['ma_phong_hoc']}';
                    final dateText = item['ngay_gui_bao_cao'] ?? '';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item['ma_phieu_su_co'] ?? 'Phiếu sự cố',
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
                            const Divider(height: 16),
                            Text(
                              item['mo_ta_hu_hong'] ?? 'Không có mô tả',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.meeting_room_outlined, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(roomText, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                                if (item['vi_tri_trong_phong'] != null && (item['vi_tri_trong_phong'] as String).isNotEmpty) ...[
                                  const SizedBox(width: 12),
                                  const Icon(Icons.place_outlined, size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      item['vi_tri_trong_phong'],
                                      style: TextStyle(color: Colors.grey[700], fontSize: 13),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            if (dateText.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.access_time, size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    dateText.toString().split('T').first,
                                    style: TextStyle(color: Colors.grey[500], fontSize: 11),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
