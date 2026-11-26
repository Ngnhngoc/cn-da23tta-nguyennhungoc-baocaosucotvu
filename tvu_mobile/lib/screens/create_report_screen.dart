import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/api_service.dart';
import '../widgets/qr_scanner_modal.dart';

class CreateReportScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  final VoidCallback onReportCreated;
  final Map<String, dynamic>? initialRoom;

  const CreateReportScreen({
    super.key,
    required this.user,
    required this.onReportCreated,
    this.initialRoom,
  });

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final ApiService _api = ApiService();
  List<dynamic> _rooms = [];
  List<dynamic> _types = [];
  bool _isLoading = true;

  // Lựa chọn & Nhập liệu
  int? _selectedRoomId;
  int? _selectedTypeId;
  Map<String, dynamic>? _selectedRoomData;
  final _roomInputCtrl = TextEditingController(text: 'B21.101');
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  // Danh sách ảnh chụp / tải lên từ điện thoại (tối đa 5 ảnh)
  final List<Uint8List> _imagesBytes = [];
  final List<String> _imagesNames = [];
  final ImagePicker _picker = ImagePicker();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialRoom != null) {
      _applySelectedRoom(widget.initialRoom!);
    }
    _loadInitialData();
  }

  @override
  void didUpdateWidget(covariant CreateReportScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialRoom != null && widget.initialRoom != oldWidget.initialRoom) {
      setState(() {
        _applySelectedRoom(widget.initialRoom!);
      });
    }
  }

  void _applySelectedRoom(Map<String, dynamic> room) {
    _selectedRoomId = room['ma_phong_hoc'];
    _selectedRoomData = room;
    _roomInputCtrl.text = _formatRoomShort(room);
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    final rooms = await _api.getRooms();
    final types = await _api.getIncidentTypes();

    if (mounted) {
      setState(() {
        _rooms = rooms;
        _types = types;
        if (_selectedRoomId == null) {
          if (widget.initialRoom != null) {
            _applySelectedRoom(widget.initialRoom!);
          } else if (rooms.isNotEmpty) {
            _applySelectedRoom(rooms.first);
          }
        }
        if (types.isNotEmpty) {
          _selectedTypeId = types.first['ma_loai_su_co'];
        }
        _isLoading = false;
      });
    }
  }

  // Định dạng tên phòng ngắn gọn: "B21.101"
  String _formatRoomShort(dynamic r) {
    if (r == null) return '';
    return (r['so_phong_day_du'] ?? 'B21.${r['so_phong']}').toString();
  }

  // Định dạng tên phòng đầy đủ: "Phòng B21.101 (Tòa B)"
  String _formatRoom(dynamic r) {
    if (r == null) return 'Chưa chọn phòng';
    final soPhong = r['so_phong_day_du'] ?? 'B21.${r['so_phong']}';
    var khu = (r['ten_khu'] ?? 'Tòa B').toString();
    if (khu.startsWith('Khu ')) {
      khu = khu.replaceFirst('Khu ', 'Tòa ');
    }
    return 'Phòng $soPhong ($khu)';
  }

  // Xử lý khi người dùng gõ số phòng trực tiếp (VD: B21.101, 101, B21.102...)
  void _handleRoomInputChanged(String val) {
    final clean = val.trim().toLowerCase().replaceAll('phòng', '').replaceAll('tvu-', '').trim();
    if (clean.isEmpty) return;

    for (final r in _rooms) {
      final soPhong = (r['so_phong'] ?? '').toString().toLowerCase();
      final soPhongFull = (r['so_phong_day_du'] ?? 'b21.$soPhong').toString().toLowerCase();
      final qr = (r['ma_qr_dinh_danh'] ?? '').toString().toLowerCase();

      if (clean == soPhongFull || clean == soPhong || clean == qr || qr.endsWith(clean)) {
        setState(() {
          _selectedRoomId = r['ma_phong_hoc'];
          _selectedRoomData = r;
        });
        break;
      }
    }
  }

  // Chụp ảnh hiện trường từ Camera
  Future<void> _captureFromCamera() async {
    if (_imagesBytes.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Đã đạt giới hạn tối đa 5 hình ảnh!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 85,
      );
      if (photo != null) {
        final bytes = await photo.readAsBytes();
        setState(() {
          _imagesBytes.add(bytes);
          _imagesNames.add(photo.name);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Đã thêm ảnh hiện trường (${_imagesBytes.length}/5)'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 1),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể mở Camera: $e')),
        );
      }
    }
  }

  // Chọn ảnh từ Thư viện / Album điện thoại
  Future<void> _pickFromGallery() async {
    if (_imagesBytes.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Đã đạt giới hạn tối đa 5 hình ảnh!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final List<XFile> photos = await _picker.pickMultiImage(
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 85,
      );

      if (photos.isNotEmpty) {
        int addedCount = 0;
        for (final photo in photos) {
          if (_imagesBytes.length >= 5) break;
          final bytes = await photo.readAsBytes();
          _imagesBytes.add(bytes);
          _imagesNames.add(photo.name);
          addedCount++;
        }

        setState(() {});

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Đã thêm $addedCount ảnh (${_imagesBytes.length}/5)'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể mở Thư viện ảnh: $e')),
        );
      }
    }
  }

  // Xóa 1 ảnh trong danh sách
  void _removeImageAt(int index) {
    setState(() {
      _imagesBytes.removeAt(index);
      _imagesNames.removeAt(index);
    });
  }

  // Mở Hộp thoại Quét Mã QR Camera Chuyên Nghiệp
  void _openQrScanner() {
    QrScannerModal.show(
      context: context,
      availableRooms: _rooms,
      onScanned: (code) {
        _handleQrScanned(code);
      },
    );
  }

  // Hiển thị danh sách Mã QR phòng học mẫu để người dùng quét hoặc bấm chọn nhanh
  void _showSampleQrDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.qr_code_2, color: Color(0xFF0D47A1), size: 28),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'MÃ QR CÁC PHÒNG HỌC TVU',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 360,
          height: 420,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bấm nút "Áp dụng phòng này" để tự động nhận diện phòng học ngay lập tức:',
                style: TextStyle(fontSize: 12, color: Colors.black87),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.separated(
                  itemCount: _rooms.length,
                  separatorBuilder: (c, i) => const Divider(height: 16),
                  itemBuilder: (context, idx) {
                    final r = _rooms[idx];
                    final qrCode = r['ma_qr_dinh_danh'] ?? 'TVU-${r['so_phong']}';
                    final qrUrl = 'https://api.qrserver.com/v1/create-qr-code/?size=180x180&data=$qrCode';

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Ảnh mã QR thực
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            color: Colors.white,
                            padding: const EdgeInsets.all(4),
                            child: Image.network(
                              qrUrl,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.qr_code, size: 36, color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Thông tin phòng & Nút chọn
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatRoom(r),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Mã: $qrCode',
                                style: const TextStyle(fontSize: 11.5, color: Color(0xFF0D47A1), fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 6),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0D47A1),
                                  foregroundColor: Colors.white,
                                  visualDensity: VisualDensity.compact,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                ),
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  _handleQrScanned(qrCode);
                                },
                                child: const Text('Áp dụng phòng này', style: TextStyle(fontSize: 11.5)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showInactiveRoomAlert(String roomName, {String? message}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.block, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Phòng Tạm Ngưng Hoạt Động',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message ?? 'Phòng $roomName hiện đang tạm ngưng hoạt động hoặc không còn sử dụng.',
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.error_outline, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Hệ thống không cho phép gửi báo cáo sự cố cho phòng đã ngưng hoạt động!',
                      style: TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _selectedRoomId = null;
                _selectedRoomData = null;
                _roomInputCtrl.clear();
              });
            },
            child: const Text('Đã hiểu'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleQrScanned(String qrCode) async {
    final clean = qrCode.replaceAll(RegExp(r'^(TVU-|B21\.|B21-)', caseSensitive: false), '').trim().toLowerCase();
    Map<String, dynamic>? room = _rooms.cast<Map<String, dynamic>?>().firstWhere(
      (r) {
        if (r == null) return false;
        final qr = (r['ma_qr_dinh_danh'] ?? '').toString().toLowerCase();
        final sp = (r['so_phong'] ?? '').toString().toLowerCase();
        final spdd = (r['so_phong_day_du'] ?? '').toString().toLowerCase();
        return qr == qrCode.toLowerCase() || sp == clean || spdd == clean || qr.contains(clean);
      },
      orElse: () => null,
    );

    if (room != null) {
      if (room['dang_su_dung'] == 0 || room['dang_su_dung'] == false) {
        _showInactiveRoomAlert(room['so_phong_day_du'] ?? room['so_phong'] ?? qrCode);
        return;
      }
      if (mounted) {
        setState(() {
          _applySelectedRoom(room!);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Đã nhận diện: ${_formatRoom(room)}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('🔍 Đang kiểm tra mã QR: $qrCode...'), duration: const Duration(seconds: 1)),
    );
    final checkRes = await _api.checkRoomQr(qrCode);

    if (!mounted) return;

    if (checkRes['status'] == 'inactive') {
      _showInactiveRoomAlert(qrCode, message: checkRes['message']);
      return;
    }

    if (checkRes['status'] == 'success' && checkRes['data'] != null) {
      final roomData = checkRes['data'] as Map<String, dynamic>;
      if (roomData['dang_su_dung'] == 0 || roomData['dang_su_dung'] == false) {
        _showInactiveRoomAlert(roomData['so_phong_day_du'] ?? roomData['so_phong'] ?? qrCode);
        return;
      }
      setState(() {
        _applySelectedRoom(roomData);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Đã nhận diện: ${_formatRoom(roomData)}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(checkRes['message'] ?? '❌ Không tìm thấy phòng với mã QR: "$qrCode"!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Gửi báo cáo sự cố kèm tối đa 5 ảnh
  Future<void> _handleSubmit() async {
    final desc = _descCtrl.text.trim();
    if (_selectedRoomId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập hoặc chọn phòng học!')),
      );
      return;
    }
    if (_selectedRoomData != null && (_selectedRoomData!['dang_su_dung'] == 0 || _selectedRoomData!['dang_su_dung'] == false)) {
      _showInactiveRoomAlert(_selectedRoomData!['so_phong_day_du'] ?? 'Phòng này');
      return;
    }
    if (desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập mô tả sự cố hư hỏng!')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final res = await _api.createIncident(
      roomId: _selectedRoomId!,
      typeId: _selectedTypeId ?? 1,
      description: desc,
      location: _locationCtrl.text.trim(),
      imagesBytesList: _imagesBytes,
      imagesNamesList: _imagesNames,
    );
    setState(() => _isSubmitting = false);

    if (mounted) {
      if (res['status'] == 'inactive') {
        _showInactiveRoomAlert(_selectedRoomData?['so_phong_day_du'] ?? 'Phòng này', message: res['message']);
      } else if (res['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 Gửi báo cáo thành công kèm ${_imagesBytes.length} ảnh!'),
            backgroundColor: Colors.green,
          ),
        );
        _descCtrl.clear();
        _locationCtrl.clear();
        setState(() {
          _imagesBytes.clear();
          _imagesNames.clear();
        });
        widget.onReportCreated();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Thất bại'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Hướng dẫn
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF0D47A1), Color(0xFF1976D2)]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.report_problem_outlined, color: Colors.white, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Báo Cáo Sự Cố Cơ Sở Vật Chất',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Nhập số phòng (VD: B21.101) hoặc quét QR, chụp ảnh hiện trường để gửi yêu cầu.',
                        style: TextStyle(color: Colors.white70, fontSize: 11.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // BƯỚC 1: NHẬP SỐ PHÒNG TRỰC TIẾP & QUÉT MÃ QR (ĐÃ BỎ BỘ LỌC RỐI MẮT)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '1. Vị trí phòng học:',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
              ),
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF0D47A1),
                  visualDensity: VisualDensity.compact,
                ),
                icon: const Icon(Icons.qr_code, size: 18),
                label: const Text('Xem mã QR mẫu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                onPressed: _showSampleQrDialog,
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Ô NHẬP TRỰC TIẾP SỐ PHÒNG (B21.101) + NÚT QUÉT MÃ QR
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _roomInputCtrl,
                  decoration: InputDecoration(
                    labelText: 'Số phòng (Gõ B21.101, B21.102, 101...) *',
                    hintText: 'B21.101',
                    prefixIcon: const Icon(Icons.meeting_room, color: Color(0xFF0D47A1)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                  onChanged: _handleRoomInputChanged,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D47A1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                  icon: const Icon(Icons.qr_code_scanner, size: 22),
                  label: const Text('Quét QR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  onPressed: _openQrScanner,
                ),
              ),
            ],
          ),

          // Hiển thị thông tin phòng đã nhận diện
          if (_selectedRoomData != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Color(0xFF0D47A1), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Đã chọn: ${_formatRoom(_selectedRoomData)} • Mã: ${_selectedRoomData!['ma_qr_dinh_danh']} • '
                      'Trang bị: ${_selectedRoomData!['so_may_lanh']} máy lạnh, ${_selectedRoomData!['so_quat']} quạt, ${_selectedRoomData!['so_tivi']} TV'
                      '${(int.tryParse('${_selectedRoomData!['so_may_tinh']}') ?? 0) > 0 ? ', ${_selectedRoomData!['so_may_tinh']} máy tính, ${_selectedRoomData!['so_ban_phim']} phím, ${_selectedRoomData!['so_cpu']} CPU' : ''}',
                      style: TextStyle(fontSize: 12, color: Colors.blue.shade900, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          // BƯỚC 2: CHỤP ẢNH HIỆN TRƯỜNG / TẢI ẢNH (TỐI ĐA 5 ẢNH)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '2. Hình ảnh hiện trường sự cố:',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _imagesBytes.length >= 5 ? Colors.orange.shade100 : Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_imagesBytes.length}/5 ảnh',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _imagesBytes.length >= 5 ? Colors.deepOrange : const Color(0xFF0D47A1),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Chụp trực tiếp từ camera hoặc tải ảnh từ điện thoại (hỗ trợ tối đa 5 ảnh):',
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
          const SizedBox(height: 10),

          // Hiển thị danh sách các ảnh đã chọn (Thumbnail List có nút xóa)
          if (_imagesBytes.isNotEmpty) ...[
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _imagesBytes.length,
                separatorBuilder: (c, i) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.memory(
                          _imagesBytes[index],
                          height: 110,
                          width: 110,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: InkWell(
                          onTap: () => _removeImageAt(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '#${index + 1}',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
          ],

          // 2 Nút mở Camera và Tải ảnh to, nổi bật
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D47A1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 2,
                    ),
                    icon: const Icon(Icons.camera_alt, size: 22),
                    label: const Text('MỞ CAMERA CHỤP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    onPressed: _imagesBytes.length >= 5 ? null : _captureFromCamera,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0D47A1),
                      side: const BorderSide(color: Color(0xFF0D47A1), width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.photo_library, size: 22),
                    label: const Text('TẢI ẢNH TỪ ĐT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    onPressed: _imagesBytes.length >= 5 ? null : _pickFromGallery,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // BƯỚC 3: CHỌN LOẠI SỰ CỐ & MÔ TẢ
          const Text(
            '3. Loại sự cố & Mô tả hư hỏng:',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
          ),
          const SizedBox(height: 8),

          // Dropdown loại sự cố
          DropdownButtonFormField<int>(
            value: _selectedTypeId,
            decoration: InputDecoration(
              labelText: 'Loại sự cố',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              isDense: true,
            ),
            items: _types.map<DropdownMenuItem<int>>((t) {
              return DropdownMenuItem<int>(
                value: t['ma_loai_su_co'],
                child: Text(t['ten_loai_su_co']),
              );
            }).toList(),
            onChanged: (val) => setState(() => _selectedTypeId = val),
          ),

          const SizedBox(height: 12),

          // Vị trí trong phòng
          TextField(
            controller: _locationCtrl,
            decoration: InputDecoration(
              labelText: 'Vị trí trong phòng (tùy chọn)',
              hintText: 'VD: Bàn 3 dãy trái, gần cửa sổ...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              isDense: true,
            ),
          ),

          const SizedBox(height: 12),

          // Mô tả hư hỏng chi tiết
          TextField(
            controller: _descCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Mô tả chi tiết hư hỏng *',
              hintText: 'VD: Máy chiếu mất tín hiệu, quạt trần kêu to không quay, máy lạnh chảy nước...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),

          const SizedBox(height: 24),

          // BƯỚC 4: NÚT GỬI BÁO CÁO
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D47A1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 2,
              ),
              icon: _isSubmitting
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.send, size: 20),
              label: Text(
                _isSubmitting ? 'ĐANG GỬI BÁO CÁO...' : 'GỬI BÁO CÁO SỰ CỐ',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
              onPressed: _isSubmitting ? null : _handleSubmit,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
