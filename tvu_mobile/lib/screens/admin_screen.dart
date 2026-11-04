import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class AdminScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const AdminScreen({super.key, required this.user});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final ApiService _api = ApiService();
  Map<String, dynamic>? _stats;
  List<dynamic> _incidents = [];
  List<dynamic> _technicians = [];
  List<dynamic> _rooms = [];
  List<dynamic> _campuses = [];
  List<dynamic> _buildings = [];
  bool _isLoading = true;

  // Tab quản trị: 0: Sự cố, 1: Quản lý Phòng & Thiết bị, 2: Người dùng & KTV
  int _currentAdminTab = 0;

  // Bộ lọc sự cố
  String _selectedFilter = 'Tất cả';

  // Bộ lọc & tìm kiếm phòng học
  String _roomSearchQuery = '';
  String _roomBuildingFilter = 'Tất cả';

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    final stats = await _api.getStats();
    final incidents = await _api.getAllIncidents();
    final technicians = await _api.getTechnicians();
    final rooms = await _api.getRooms();
    final campuses = await _api.getCampuses();
    final buildings = await _api.getBuildings();

    if (mounted) {
      setState(() {
        _stats = stats;
        _incidents = incidents;
        _technicians = technicians;
        _rooms = rooms;
        _campuses = campuses;
        _buildings = buildings;
        _isLoading = false;
      });
    }
  }

  // Hàm trích xuất tên phòng chuẩn 100% không bị hardcode B21
  String _getRoomDisplayName(Map<String, dynamic> r) {
    final full = r['so_phong_day_du']?.toString();
    if (full != null && full.isNotEmpty && full != 'null') return full;

    final maToa = (r['ma_toa'] ?? (r['day_nha'] != null ? r['day_nha']['ma_toa'] : null))?.toString();
    final soPhong = (r['so_phong'] ?? '').toString();
    if (maToa != null && maToa.isNotEmpty) return '$maToa.$soPhong';

    final qr = (r['ma_qr_dinh_danh'] ?? '').toString();
    final match = RegExp(r'^TVU-([A-Z0-9]+)-(.+)$', caseSensitive: false).firstMatch(qr);
    if (match != null) return '${match.group(1)}.${match.group(2)}';

    return soPhong;
  }

  String _getRoomBuildingName(Map<String, dynamic> r) {
    if (r['ten_day_nha'] != null && r['ten_day_nha'].toString().isNotEmpty) {
      return r['ten_day_nha'].toString();
    }
    if (r['day_nha'] != null && r['day_nha']['ten_day_nha'] != null) {
      return r['day_nha']['ten_day_nha'].toString();
    }
    final qr = (r['ma_qr_dinh_danh'] ?? '').toString();
    final match = RegExp(r'^TVU-([A-Z0-9]+)-', caseSensitive: false).firstMatch(qr);
    if (match != null) {
      return 'Tòa nhà ${match.group(1)}';
    }
    return 'Tòa nhà B21';
  }

  String _getRoomCampusName(Map<String, dynamic> r) {
    if (r['ten_khu'] != null && r['ten_khu'].toString().isNotEmpty) {
      return r['ten_khu'].toString();
    }
    if (r['day_nha'] != null && r['day_nha']['khuon_vien'] != null && r['day_nha']['khuon_vien']['ma_viet_tat'] != null) {
      return r['day_nha']['khuon_vien']['ma_viet_tat'].toString();
    }
    return 'Khu I';
  }

  List<dynamic> get _filteredIncidents {
    if (_selectedFilter == 'Tất cả') return _incidents;
    return _incidents.where((i) => (i['trang_thai'] ?? '') == _selectedFilter).toList();
  }

  List<dynamic> get _filteredRooms {
    return _rooms.where((r) {
      final name = _getRoomDisplayName(r).toLowerCase();
      final qr = (r['ma_qr_dinh_danh'] ?? '').toString().toLowerCase();
      final q = _roomSearchQuery.trim().toLowerCase();
      final matchesSearch = q.isEmpty || name.contains(q) || qr.contains(q);
      if (!matchesSearch) return false;

      if (_roomBuildingFilter == 'Tất cả') return true;
      final buildingName = _getRoomBuildingName(r).toLowerCase();
      final maToa = (r['ma_toa'] ?? '').toString().toLowerCase();
      final filterLower = _roomBuildingFilter.toLowerCase();

      return buildingName.contains(filterLower) ||
             maToa == filterLower ||
             'tòa $maToa' == filterLower;
    }).toList();
  }

  // 1. MODAL: PHÂN CÔNG KỸ THUẬT VIÊN
  void _showAssignDialog(Map<String, dynamic> incident) {
    int? selectedKtvId = _technicians.isNotEmpty ? _technicians.first['ma_nguoi_dung'] : null;
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          title: const Text('PHÂN CÔNG KỸ THUẬT VIÊN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Phiếu: ${incident['ma_phieu_su_co']}', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('Nội dung: ${incident['mo_ta_hu_hong']}'),
              const SizedBox(height: 14),
              const Text('Chọn Kỹ thuật viên phụ trách:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              DropdownButtonFormField<int>(
                value: selectedKtvId,
                decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                items: _technicians.map<DropdownMenuItem<int>>((ktv) {
                  return DropdownMenuItem<int>(
                    value: ktv['ma_nguoi_dung'],
                    child: Text('${ktv['ho_va_ten']} (${ktv['so_dien_thoai'] ?? 'KTV'})'),
                  );
                }).toList(),
                onChanged: (val) => setDlgState(() => selectedKtvId = val),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1)),
              onPressed: (selectedKtvId == null || isSaving)
                  ? null
                  : () async {
                      setDlgState(() => isSaving = true);
                      final res = await _api.assignTechnician(incident['ma_su_co_id'], selectedKtvId!);
                      setDlgState(() => isSaving = false);

                      if (!mounted) return;
                      Navigator.pop(ctx);
                      if (res['status'] == 'success') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('🎉 ${res['message']}'), backgroundColor: Colors.green),
                        );
                        _loadAllData();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(res['message'] ?? 'Thất bại'), backgroundColor: Colors.red),
                        );
                      }
                    },
              child: isSaving
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Xác nhận phân công', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // 2. MODAL: XEM THÔNG TIN NGƯỜI BÁO CÁO
  void _showReporterDialog(Map<String, dynamic> incident) {
    final reporter = incident['nguoiBaoCao'] ?? incident['nguoi_bao_cao'];
    final phone = reporter != null ? reporter['so_dien_thoai'] : '0987654321';
    final unit = reporter != null ? reporter['lop_hoac_don_vi'] : 'Trường ĐH Trà Vinh';
    final email = reporter != null ? reporter['email_tvu'] : 'nguoidung@tvu.edu.vn';
    final name = reporter != null ? reporter['ho_va_ten'] : 'Sinh viên TVU';
    final role = reporter != null ? reporter['vai_tro'] : 'Sinh viên';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.person, color: Color(0xFF0D47A1)),
            const SizedBox(width: 8),
            Text('NGƯỜI BÁO CÁO SỰ CỐ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Họ và tên:', name),
            _buildInfoRow('Vai trò:', role),
            _buildInfoRow('Lớp / Đơn vị:', unit ?? 'Chưa cập nhật'),
            _buildInfoRow('Số điện thoại:', phone ?? 'Chưa cập nhật'),
            _buildInfoRow('Email TVU:', email ?? 'Chưa cập nhật'),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1)),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // 2.1 MODAL: THÊM KHU / KHUÔN VIÊN MỚI
  void _showAddCampusDialog() {
    final nameCtrl = TextEditingController(text: 'Khu I - Trường Đại học Trà Vinh');
    final codeCtrl = TextEditingController(text: 'Khu I');
    final addressCtrl = TextEditingController(text: '126 Nguyễn Thiện Thành, Phường 5, TP. Trà Vinh');
    final descCtrl = TextEditingController();
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.location_city, color: Color(0xFF0D47A1)),
              SizedBox(width: 8),
              Text('THÊM KHU / KHUÔN VIÊN MỚI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Tên khuôn viên (VD: Khu I - ĐH Trà Vinh, Khu II...) *',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: codeCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Mã viết tắt (VD: Khu I, Khu II, Khu III) *',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: addressCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Địa chỉ khuôn viên',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Ghi chú / Mô tả',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1), foregroundColor: Colors.white),
              onPressed: isSaving
                  ? null
                  : () async {
                      if (nameCtrl.text.trim().isEmpty || codeCtrl.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập tên và mã khu!')));
                        return;
                      }
                      setDlgState(() => isSaving = true);
                      final res = await _api.addCampus(
                        name: nameCtrl.text.trim(),
                        shortCode: codeCtrl.text.trim(),
                        address: addressCtrl.text.trim(),
                        description: descCtrl.text.trim(),
                      );
                      setDlgState(() => isSaving = false);
                      if (!mounted) return;
                      Navigator.pop(ctx);
                      if (res['status'] == 'success') {
                        _loadAllData();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Thành công!'), backgroundColor: Colors.green));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Thất bại'), backgroundColor: Colors.red));
                      }
                    },
              child: isSaving
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Lưu Khu'),
            ),
          ],
        ),
      ),
    );
  }

  // 2.2 MODAL: THÊM TÒA NHÀ MỚI THUỘC KHU
  void _showAddBuildingDialog() {
    int selectedCampusId = _campuses.isNotEmpty ? _campuses.first['ma_khuon_vien'] : 1;
    final codeCtrl = TextEditingController(text: 'D71');
    final nameCtrl = TextEditingController(text: 'Tòa nhà D71');
    final floorsCtrl = TextEditingController(text: '4');
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.domain, color: Color(0xFF0D47A1)),
              SizedBox(width: 8),
              Text('THÊM TÒA NHÀ MỚI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_campuses.isNotEmpty) ...[
                  const Text('Chọn Khuôn viên / Khu:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<int>(
                    value: selectedCampusId,
                    decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                    items: _campuses.map<DropdownMenuItem<int>>((c) {
                      return DropdownMenuItem<int>(
                        value: c['ma_khuon_vien'],
                        child: Text('${c['ten_khuon_vien']} (${c['ma_viet_tat']})'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setDlgState(() => selectedCampusId = val);
                    },
                  ),
                  const SizedBox(height: 12),
                ],
                TextField(
                  controller: codeCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Mã tòa (VD: B21, B31, D71, A11...) *',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (val) {
                    final clean = val.trim().toUpperCase();
                    nameCtrl.text = clean.isNotEmpty ? 'Tòa nhà $clean' : '';
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Tên tòa nhà (VD: Tòa nhà D71)',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: floorsCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Tổng số tầng',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1), foregroundColor: Colors.white),
              onPressed: isSaving
                  ? null
                  : () async {
                      if (codeCtrl.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập mã tòa!')));
                        return;
                      }
                      setDlgState(() => isSaving = true);
                      final res = await _api.addBuilding(
                        buildingCode: codeCtrl.text.trim(),
                        campusId: selectedCampusId,
                        buildingName: nameCtrl.text.trim(),
                        floorCount: int.tryParse(floorsCtrl.text) ?? 4,
                      );
                      setDlgState(() => isSaving = false);
                      if (!mounted) return;
                      Navigator.pop(ctx);
                      if (res['status'] == 'success') {
                        _loadAllData();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Thành công!'), backgroundColor: Colors.green));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Thất bại'), backgroundColor: Colors.red));
                      }
                    },
              child: isSaving
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Lưu Tòa Nhà'),
            ),
          ],
        ),
      ),
    );
  }

  // 3. MODAL: TẠO PHÒNG HỌC MỚI (CHỌN TÒA, KÈM MÃ QR VÀ THIẾT BỊ)
  void _showAddRoomDialog() {
    int? selectedBuildingId = _buildings.isNotEmpty ? _buildings.first['ma_day_nha'] : null;
    String selectedBuildingCode = _buildings.isNotEmpty ? (_buildings.first['ma_toa'] ?? 'B21') : 'B21';
    final roomNumberCtrl = TextEditingController(text: '102');
    final floorCtrl = TextEditingController(text: '1');
    String selectedRoomType = 'Lý thuyết';
    final acCtrl = TextEditingController(text: '2');
    final fanCtrl = TextEditingController(text: '2');
    final tvCtrl = TextEditingController(text: '1');
    final hdmiCtrl = TextEditingController(text: '1');
    final boardCtrl = TextEditingController(text: '1');
    final deskCtrl = TextEditingController(text: '20');
    final teacherDeskCtrl = TextEditingController(text: '1');
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) {
          // Chuẩn hóa số phòng nhập vào
          final rawInput = roomNumberCtrl.text.trim().replaceAll('TVU-', '');
          String pureRoomNum = rawInput;
          if (rawInput.contains('.')) {
            final parts = rawInput.split('.');
            pureRoomNum = parts.length > 1 ? parts[1] : parts[0];
          }

          final previewFullRoom = '$selectedBuildingCode.$pureRoomNum';
          final previewQr = 'TVU-$selectedBuildingCode-$pureRoomNum';
          final previewQrUrl = 'https://api.qrserver.com/v1/create-qr-code/?size=160x160&data=$previewQr';

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.add_home_work, color: Color(0xFF0D47A1)),
                SizedBox(width: 8),
                Text('TẠO PHÒNG & SINH MÃ QR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            content: SizedBox(
              width: 440,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. CHỌN TÒA NHÀ
                    const Text('1. Vị trí Tòa nhà & Khuôn viên: *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0D47A1))),
                    const SizedBox(height: 6),
                    if (_buildings.isNotEmpty)
                      DropdownButtonFormField<int>(
                        value: selectedBuildingId ?? _buildings.first['ma_day_nha'],
                        decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                        items: _buildings.map<DropdownMenuItem<int>>((b) {
                          final maToa = b['ma_toa'] ?? '';
                          final tenDay = b['ten_day_nha'] ?? 'Tòa $maToa';
                          final tenKhu = b['khuon_vien'] != null ? b['khuon_vien']['ma_viet_tat'] : 'Khu I';
                          return DropdownMenuItem<int>(
                            value: b['ma_day_nha'],
                            child: Text('$tenDay ($maToa) • $tenKhu'),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDlgState(() {
                              selectedBuildingId = val;
                              final found = _buildings.firstWhere((b) => b['ma_day_nha'] == val, orElse: () => null);
                              if (found != null) {
                                selectedBuildingCode = found['ma_toa'] ?? 'B21';
                              }
                            });
                          }
                        },
                      )
                    else
                      Row(
                        children: [
                          const Expanded(child: Text('Chưa có tòa nhà nào trong hệ thống.', style: TextStyle(color: Colors.red, fontSize: 12))),
                          TextButton(onPressed: () { Navigator.pop(ctx); _showAddBuildingDialog(); }, child: const Text('+ Thêm Tòa Ngay')),
                        ],
                      ),

                    const SizedBox(height: 12),

                    // 2. SỐ PHÒNG & TẦNG & LOẠI PHÒNG
                    const Text('2. Thông tin số phòng & tầng số: *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0D47A1))),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: roomNumberCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Số phòng (VD: 101, 102, 201...) *',
                              hintText: '102',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            onChanged: (val) {
                              setDlgState(() {
                                final clean = val.trim();
                                if (clean.isNotEmpty) {
                                  // Tự suy tầng số từ ký tự đầu tiên nếu là số
                                  final numPart = clean.contains('.') ? clean.split('.')[1] : clean;
                                  if (numPart.isNotEmpty && int.tryParse(numPart[0]) != null) {
                                    floorCtrl.text = numPart[0];
                                  }
                                }
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: floorCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Tầng số *',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedRoomType,
                      decoration: const InputDecoration(labelText: 'Loại phòng', border: OutlineInputBorder(), isDense: true),
                      items: const [
                        DropdownMenuItem(value: 'Lý thuyết', child: Text('Phòng Lý thuyết')),
                        DropdownMenuItem(value: 'Thực hành Máy tính', child: Text('Phòng Thực hành Máy tính')),
                        DropdownMenuItem(value: 'Thí nghiệm / Lab', child: Text('Phòng Thí nghiệm / Lab')),
                        DropdownMenuItem(value: 'Hội trường', child: Text('Hội trường / Phòng họp')),
                      ],
                      onChanged: (val) {
                        if (val != null) setDlgState(() => selectedRoomType = val);
                      },
                    ),

                    const SizedBox(height: 12),

                    // 3. XEM TRƯỚC MÃ QR ĐỊNH DANH (TỰ ĐỘNG SINH THEO TÒA & PHÒNG)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.blue.shade300),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              previewQrUrl,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => Container(
                                width: 60,
                                height: 60,
                                color: Colors.white,
                                child: const Icon(Icons.qr_code, color: Color(0xFF0D47A1), size: 30),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('MÃ QR SẼ TẠO:', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.grey)),
                                Text(
                                  previewQr,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0D47A1)),
                                ),
                                Text(
                                  'Tên phòng: Phòng $previewFullRoom ($selectedRoomType)',
                                  style: TextStyle(fontSize: 11.5, color: Colors.blue.shade900),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // 4. TRANG THIẾT BỊ BAN ĐẦU CỦA PHÒNG
                    const Text('3. Trang thiết bị ban đầu của phòng:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0D47A1))),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: acCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: '❄️ Máy lạnh', border: OutlineInputBorder(), isDense: true),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: fanCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: '🌀 Quạt', border: OutlineInputBorder(), isDense: true),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: tvCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: '📺 TV/Chiếu', border: OutlineInputBorder(), isDense: true),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: hdmiCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: '🔌 HDMI', border: OutlineInputBorder(), isDense: true),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: boardCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: '📋 Bảng viết', border: OutlineInputBorder(), isDense: true),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: deskCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: '🪑 Bàn SV', border: OutlineInputBorder(), isDense: true),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1), foregroundColor: Colors.white),
                icon: const Icon(Icons.qr_code_scanner, size: 18),
                onPressed: isSaving
                    ? null
                    : () async {
                        final roomText = roomNumberCtrl.text.trim();
                        if (roomText.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập số phòng!')));
                          return;
                        }

                        setDlgState(() => isSaving = true);
                        final res = await _api.addRoom(
                          roomNumber: pureRoomNum,
                          buildingId: selectedBuildingId,
                          buildingCode: selectedBuildingCode,
                          floor: int.tryParse(floorCtrl.text) ?? 1,
                          roomType: selectedRoomType,
                          acCount: int.tryParse(acCtrl.text) ?? 2,
                          fanCount: int.tryParse(fanCtrl.text) ?? 2,
                          tvCount: int.tryParse(tvCtrl.text) ?? 1,
                          hdmiCount: int.tryParse(hdmiCtrl.text) ?? 1,
                          boardCount: int.tryParse(boardCtrl.text) ?? 1,
                          studentDeskCount: int.tryParse(deskCtrl.text) ?? 20,
                          teacherDeskCount: int.tryParse(teacherDeskCtrl.text) ?? 1,
                        );
                        setDlgState(() => isSaving = false);

                        if (!mounted) return;
                        Navigator.pop(ctx);
                        if (res['status'] == 'success') {
                          _loadAllData();
                          final createdQr = res['qr_code'] ?? previewQr;
                          final fullRoomName = res['so_phong_full'] ?? previewFullRoom;
                          _showCreatedQrResultDialog(
                            createdQr,
                            fullRoomName,
                            int.tryParse(acCtrl.text) ?? 2,
                            int.tryParse(fanCtrl.text) ?? 2,
                            int.tryParse(tvCtrl.text) ?? 1,
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(res['message'] ?? 'Thất bại'), backgroundColor: Colors.red),
                          );
                        }
                      },
                label: isSaving
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Tạo Phòng & Sinh Mã QR'),
              ),
            ],
          );
        },
      ),
    );
  }

  // 4. HỘP THOẠI HIỂN THỊ KẾT QUẢ TẠO PHÒNG & NÚT IN MÃ QR
  void _showCreatedQrResultDialog(String qrCode, String fullRoom, int ac, int fan, int tv) {
    final qrUrl = 'https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=$qrCode';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 26),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'ĐÃ TẠO PHÒNG $fullRoom THÀNH CÔNG!',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0D47A1)),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200, width: 2),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
              ),
              child: Column(
                children: [
                  Image.network(
                    qrUrl,
                    width: 190,
                    height: 190,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    qrCode,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0D47A1), letterSpacing: 1),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('🏢 Phòng: $fullRoom', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text('📦 Thiết bị: $ac máy lạnh, $fan quạt, $tv TV/máy chiếu', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                  const SizedBox(height: 2),
                  const Text('✅ Mã QR đã sẵn sàng để in dán cửa phòng & quét báo sự cố!', style: TextStyle(fontSize: 11.5, color: Colors.green, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF0D47A1),
              side: const BorderSide(color: Color(0xFF0D47A1)),
            ),
            icon: const Icon(Icons.print, size: 18),
            label: const Text('In Mã QR Này'),
            onPressed: () {
              Navigator.pop(ctx);
              final found = _rooms.firstWhere(
                (r) => (r['ma_qr_dinh_danh'] ?? '') == qrCode,
                orElse: () => {
                  'ma_phong_hoc': 1,
                  'so_phong': fullRoom,
                  'so_phong_day_du': fullRoom,
                  'ma_qr_dinh_danh': qrCode,
                  'so_may_lanh': ac,
                  'so_quat': fan,
                  'so_tivi': tv,
                  'tang_so': 1,
                },
              );
              _openPrintPreview(found);
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1), foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Xong'),
          ),
        ],
      ),
    );
  }

  // 5. MODAL XEM TRƯỚC VÀ IN MÃ QR CHÍNH THỨC TVU (HỖ TRỢ CTRL+P)
  void _openPrintPreview(Map<String, dynamic> room) {
    final soPhong = _getRoomDisplayName(room);
    final qrCode = (room['ma_qr_dinh_danh'] ?? 'TVU-$soPhong').toString();
    final tenDayNha = _getRoomBuildingName(room);
    final tenKhu = _getRoomCampusName(room);
    final qrUrl = 'https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=$qrCode';
    final roomId = room['ma_phong_hoc'] ?? 1;
    final printUrl = '${ApiService.baseUrl.replaceAll('/api', '')}/admin/rooms/$roomId/print';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.print, color: Color(0xFF0D47A1), size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'BẢN IN MÃ QR - $soPhong',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 360,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF0D47A1), width: 3),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'TRƯỜNG ĐẠI HỌC TRÀ VINH',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0D47A1), letterSpacing: 0.5),
                      ),
                      const Text(
                        'BAN QUẢN LÝ CƠ SỞ VẬT CHẤT',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 10.5, color: Colors.grey),
                      ),
                      const Divider(height: 16, thickness: 1.5, color: Color(0xFF0D47A1)),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          qrUrl,
                          width: 190,
                          height: 190,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(
                            width: 190,
                            height: 190,
                            color: Colors.grey.shade100,
                            child: const Icon(Icons.qr_code, size: 60, color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        qrCode,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0D47A1), letterSpacing: 1),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Phòng $soPhong',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 19, color: Color(0xFF0F172A)),
                      ),
                      Text(
                        '$tenDayNha ($tenKhu) • Tầng ${room['tang_so'] ?? 1}',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5, color: Color(0xFF334155)),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(6)),
                        child: Text(
                          '📦 Trang bị: ${room['so_may_lanh'] ?? 2} máy lạnh • ${room['so_quat'] ?? 2} quạt • ${room['so_tivi'] ?? 1} TV',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 11, color: Colors.blue.shade900, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const Text(
                          '📷 Quét mã QR bằng Camera điện thoại để báo sự cố',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 10, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Đóng')),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D47A1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.print, size: 18),
            label: const Text('Mở Trang In & In Ngay (Ctrl + P)', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () async {
              final uri = Uri.parse(printUrl);
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            },
          ),
        ],
      ),
    );
  }

  // 5.1 XÁC NHẬN XÓA PHÒNG HỌC
  void _confirmDeleteRoom(Map<String, dynamic> room) {
    final name = _getRoomDisplayName(room);
    final id = room['ma_phong_hoc'];
    if (id == null) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text('XÁC NHẬN XÓA PHÒNG', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Text('Bạn có chắc chắn muốn xóa Phòng $name khỏi hệ thống quản lý?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              final res = await _api.deleteRoom(id);
              if (res['status'] == 'success') {
                _loadAllData();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Đã xóa phòng'), backgroundColor: Colors.green));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Xóa thất bại'), backgroundColor: Colors.red));
              }
            },
            child: const Text('Xóa Phòng'),
          ),
        ],
      ),
    );
  }

  // 6. CẬP NHẬT / SỬA TOÀN BỘ TRANG THIẾT BỊ CỦA PHÒNG HỌC
  void _showEditEquipmentDialog(Map<String, dynamic> room) {
    final soPhong = _getRoomDisplayName(room);
    final acCtrl = TextEditingController(text: '${room['so_may_lanh'] ?? 2}');
    final fanCtrl = TextEditingController(text: '${room['so_quat'] ?? 2}');
    final tvCtrl = TextEditingController(text: '${room['so_tivi'] ?? 1}');
    final hdmiCtrl = TextEditingController(text: '${room['so_cong_hdmi'] ?? 1}');
    final boardCtrl = TextEditingController(text: '${room['so_bang_viet'] ?? 1}');
    final deskCtrl = TextEditingController(text: '${room['so_ban_sinh_vien'] ?? 20}');
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.edit_note, color: Color(0xFF0D47A1), size: 26),
              const SizedBox(width: 8),
              Expanded(
                child: Text('CẬP NHẬT THIẾT BỊ: PHÒNG $soPhong', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Điều chỉnh số lượng thiết bị thực tế đang có trong phòng:', style: TextStyle(fontSize: 12, color: Colors.black87)),
                const SizedBox(height: 12),

                // Hàng 1: Máy lạnh, Quạt
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: acCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: '❄️ Số máy lạnh', border: OutlineInputBorder(), isDense: true),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: fanCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: '🌀 Số quạt', border: OutlineInputBorder(), isDense: true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Hàng 2: TV, HDMI
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: tvCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: '📺 TV / Màn chiếu', border: OutlineInputBorder(), isDense: true),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: hdmiCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: '🔌 Cổng HDMI', border: OutlineInputBorder(), isDense: true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Hàng 3: Bảng viết, Bàn sinh viên
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: boardCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: '📋 Bảng viết', border: OutlineInputBorder(), isDense: true),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: deskCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: '🪑 Bàn sinh viên', border: OutlineInputBorder(), isDense: true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D47A1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: isSaving
                  ? null
                  : () async {
                      setDlgState(() => isSaving = true);
                      final res = await _api.updateRoomEquipments(
                        room['ma_phong_hoc'],
                        acCount: int.tryParse(acCtrl.text) ?? 0,
                        fanCount: int.tryParse(fanCtrl.text) ?? 0,
                        tvCount: int.tryParse(tvCtrl.text) ?? 0,
                        hdmiCount: int.tryParse(hdmiCtrl.text) ?? 1,
                        boardCount: int.tryParse(boardCtrl.text) ?? 1,
                      );
                      setDlgState(() => isSaving = false);

                      if (!mounted) return;
                      Navigator.pop(ctx);
                      if (res['status'] == 'success') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('✅ ${res['message']}'), backgroundColor: Colors.green),
                        );
                        _loadAllData();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(res['message'] ?? 'Thất bại'), backgroundColor: Colors.red),
                        );
                      }
                    },
              child: isSaving
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Lưu Thay Đổi'),
            ),
          ],
        ),
      ),
    );
  }

  // 7. MODAL THÊM TÀI KHOẢN (GV, SV, KTV)
  void _showAddUserDialog() {
    String selectedRole = 'Sinh viên';
    final userCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final unitCtrl = TextEditingController(text: 'Khoa CNTT - TVU');
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('THÊM TÀI KHOẢN MỚI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: const InputDecoration(labelText: 'Vai trò tài khoản *', border: OutlineInputBorder(), isDense: true),
                  items: ['Sinh viên', 'Giảng viên', 'Kỹ thuật viên'].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                  onChanged: (val) => setDlgState(() => selectedRole = val!),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: userCtrl,
                  decoration: InputDecoration(
                    labelText: selectedRole == 'Sinh viên' ? 'Mã số sinh viên (MSSV) *' : 'Tên đăng nhập (Username) *',
                    hintText: selectedRole == 'Sinh viên' ? '110123001' : 'ktv_dien1',
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Họ và tên *', hintText: 'Nguyễn Văn A', border: OutlineInputBorder(), isDense: true),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Số điện thoại', hintText: '0987654321', border: OutlineInputBorder(), isDense: true),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: unitCtrl,
                  decoration: InputDecoration(
                    labelText: selectedRole == 'Sinh viên' ? 'Lớp học (VD: DA23TTA)' : 'Khoa / Đơn vị công tác',
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 8),
                const Text('Mật khẩu mặc định: 123456', style: TextStyle(fontSize: 11.5, color: Colors.grey)),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1), foregroundColor: Colors.white),
              onPressed: isSaving
                  ? null
                  : () async {
                      final uName = userCtrl.text.trim();
                      final fName = nameCtrl.text.trim();
                      if (uName.isEmpty || fName.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng điền đủ mã và tên!')));
                        return;
                      }
                      setDlgState(() => isSaving = true);
                      final res = await _api.addUser(
                        username: uName,
                        fullName: fName,
                        role: selectedRole,
                        phone: phoneCtrl.text.trim(),
                        unitOrClass: unitCtrl.text.trim(),
                      );
                      setDlgState(() => isSaving = false);

                      if (!mounted) return;
                      Navigator.pop(ctx);
                      if (res['status'] == 'success') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('🎉 ${res['message']}'), backgroundColor: Colors.green),
                        );
                        _loadAllData();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(res['message'] ?? 'Thất bại'), backgroundColor: Colors.red),
                        );
                      }
                    },
              child: isSaving
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Tạo Tài Khoản'),
            ),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // TAB 1: GIAO DIỆN CHUYÊN DỤNG QUẢN LÝ PHÒNG & THIẾT BỊ BÊN ADMIN
  // ==============================================================
  Widget _buildRoomManagementTab() {
    final filtered = _filteredRooms;
    final totalRooms = _rooms.length;
    final totalAc = _rooms.fold<int>(0, (sum, r) => sum + (int.tryParse('${r['so_may_lanh']}') ?? 0));
    final totalFan = _rooms.fold<int>(0, (sum, r) => sum + (int.tryParse('${r['so_quat']}') ?? 0));
    final totalTv = _rooms.fold<int>(0, (sum, r) => sum + (int.tryParse('${r['so_tivi']}') ?? 0));

    return RefreshIndicator(
      onRefresh: _loadAllData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Quản Lý Phòng & Thiết Bị
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF0D47A1), Color(0xFF1565C0)]),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF0D47A1).withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 3)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.account_tree, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'QUẢN LÝ KHU • TÒA • PHÒNG & THIẾT BỊ',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.5),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Thêm Khuôn viên -> Thêm Tòa nhà -> Tạo Phòng kèm Mã QR & Quản lý thiết bị',
                              style: TextStyle(color: Colors.white70, fontSize: 11.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // 3 Nút quy trình quản lý: Thêm Khu -> Thêm Tòa -> Tạo Phòng
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF0D47A1),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(Icons.location_city, size: 16),
                        label: const Text('+ Thêm Khu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        onPressed: _showAddCampusDialog,
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF0D47A1),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(Icons.domain, size: 16),
                        label: const Text('+ Thêm Tòa', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        onPressed: _showAddBuildingDialog,
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade400,
                          foregroundColor: const Color(0xFF0D47A1),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(Icons.add_home_work, size: 16),
                        label: const Text('+ Tạo Phòng & QR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        onPressed: _showAddRoomDialog,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // 4 Thẻ thống kê tổng quan thiết bị
            Row(
              children: [
                _buildStatMiniCard('Tổng phòng', '$totalRooms', Icons.door_front_door, Colors.indigo),
                const SizedBox(width: 8),
                _buildStatMiniCard('Máy lạnh', '$totalAc', Icons.ac_unit, Colors.cyan.shade800),
                const SizedBox(width: 8),
                _buildStatMiniCard('Quạt gió', '$totalFan', Icons.mode_fan_off_outlined, Colors.teal),
                const SizedBox(width: 8),
                _buildStatMiniCard('TV/Chiếu', '$totalTv', Icons.tv, Colors.deepPurple),
              ],
            ),

            const SizedBox(height: 14),

            // Thanh tìm kiếm phòng học
            TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm số phòng (VD: B21.101, D71.102, 101...)...',
                prefixIcon: const Icon(Icons.search, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                isDense: true,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              onChanged: (val) {
                setState(() {
                  _roomSearchQuery = val;
                });
              },
            ),

            const SizedBox(height: 10),

            // Bộ lọc chip theo Tòa lấy động từ cơ sở dữ liệu
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildBuildingFilterChip('Tất cả'),
                  ..._buildings.map<Widget>((b) {
                    final code = b['ma_toa'] ?? '';
                    return _buildBuildingFilterChip('Tòa $code');
                  }),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Danh sách phòng học
            if (filtered.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 10),
                    Text(
                      'Không tìm thấy phòng nào phù hợp với bộ lọc.',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13.5),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                separatorBuilder: (c, i) => const SizedBox(height: 12),
                itemBuilder: (context, idx) {
                  final r = filtered[idx];
                  return _buildRoomCard(r);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBuildingFilterChip(String label) {
    final isSelected = _roomBuildingFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (val) {
          setState(() {
            _roomBuildingFilter = label;
          });
        },
        selectedColor: const Color(0xFF0D47A1),
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
        backgroundColor: Colors.white,
        side: BorderSide(color: isSelected ? const Color(0xFF0D47A1) : Colors.grey.shade300),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      ),
    );
  }

  Widget _buildStatMiniCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 10.5, color: Colors.grey[600]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomCard(Map<String, dynamic> r) {
    final soPhong = _getRoomDisplayName(r);
    final tenDayNha = _getRoomBuildingName(r);
    final tenKhu = _getRoomCampusName(r);
    final qrCode = (r['ma_qr_dinh_danh'] ?? 'TVU-$soPhong').toString();
    final qrUrl = 'https://api.qrserver.com/v1/create-qr-code/?size=180x180&data=$qrCode';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề phòng & huy hiệu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D47A1).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.meeting_room, color: Color(0xFF0D47A1), size: 20),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Phòng $soPhong',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0D47A1)),
                        ),
                        Text(
                          '$tenDayNha ($tenKhu) • Tầng ${r['tang_so'] ?? 1} • ${r['loai_phong'] ?? 'Lý thuyết'}',
                          style: TextStyle(color: Colors.grey[700], fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Text(
                    (r['dang_su_dung'] == 1 || r['dang_su_dung'] == true) ? '● Đang sử dụng' : 'Tạm khóa',
                    style: TextStyle(color: Colors.green.shade800, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            const Divider(height: 18),

            // Thân thẻ: QR bên trái, bảng thiết bị bên phải
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ảnh mã QR kèm mã
                InkWell(
                  onTap: () => _openPrintPreview(r),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.blue.shade200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Image.network(
                          qrUrl,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey.shade100,
                            child: const Icon(Icons.qr_code, size: 36),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          qrCode,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Lưới thiết bị hiện có
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _buildEquipChip('❄️ Máy lạnh', '${r['so_may_lanh'] ?? 0} cái', Colors.cyan.shade50, Colors.cyan.shade800),
                      _buildEquipChip('🌀 Quạt', '${r['so_quat'] ?? 0} cái', Colors.teal.shade50, Colors.teal.shade800),
                      _buildEquipChip('📺 TV/Chiếu', '${r['so_tivi'] ?? 0} cái', Colors.purple.shade50, Colors.purple.shade800),
                      _buildEquipChip('🔌 HDMI', '${r['so_cong_hdmi'] ?? 1} cổng', Colors.blue.shade50, Colors.blue.shade800),
                      _buildEquipChip('📋 Bảng', '${r['so_bang_viet'] ?? 1} cái', Colors.amber.shade50, Colors.amber.shade900),
                      _buildEquipChip('🪑 Bàn SV', '${r['so_ban_sinh_vien'] ?? 20} bàn', Colors.indigo.shade50, Colors.indigo.shade800),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // CÁC NÚT HÀNH ĐỘNG: IN MÃ QR, SỬA THIẾT BỊ, XÓA PHÒNG
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0D47A1),
                      side: const BorderSide(color: Color(0xFF0D47A1)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.print, size: 17),
                    label: const Text('In Mã QR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    onPressed: () => _openPrintPreview(r),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D47A1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.edit, size: 17),
                    label: const Text('Sửa Thiết Bị', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    onPressed: () => _showEditEquipmentDialog(r),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red.shade700,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.red.shade200)),
                  ),
                  tooltip: 'Xóa phòng này',
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: () => _confirmDeleteRoom(r),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEquipChip(String name, String value, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: textColor.withValues(alpha: 0.2)),
      ),
      child: Text(
        '$name: $value',
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor),
      ),
    );
  }

  // ==============================================================
  // TAB 2: QUẢN LÝ TÀI KHOẢN & KỸ THUẬT VIÊN
  // ==============================================================
  Widget _buildUserManagementTab() {
    return RefreshIndicator(
      onRefresh: _loadAllData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Người Dùng
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF880E4F), Color(0xFFAD1457)]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.people, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TÀI KHOẢN & KỸ THUẬT VIÊN',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Quản lý danh sách KTV, Giảng viên và Sinh viên TVU',
                          style: TextStyle(color: Colors.white70, fontSize: 11.5),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF880E4F),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.person_add, size: 18),
                    label: const Text('Thêm Mới', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                    onPressed: _showAddUserDialog,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            const Text('Danh Sách Kỹ Thuật Viên Tiếp Nhận Xử Lý:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
            const SizedBox(height: 10),

            if (_technicians.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('Chưa có kỹ thuật viên nào')))
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _technicians.length,
                separatorBuilder: (c, i) => const SizedBox(height: 8),
                itemBuilder: (context, idx) {
                  final ktv = _technicians[idx];
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF0D47A1),
                        foregroundColor: Colors.white,
                        child: Text(ktv['ho_va_ten'] != null && ktv['ho_va_ten'].isNotEmpty ? ktv['ho_va_ten'][0] : 'K'),
                      ),
                      title: Text(ktv['ho_va_ten'] ?? 'KTV', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text('SĐT: ${ktv['so_dien_thoai'] ?? 'Chưa có'} • ${ktv['lop_hoac_don_vi'] ?? 'Bộ phận kỹ thuật TVU'}'),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(6)),
                        child: const Text('Kỹ thuật viên', style: TextStyle(color: Color(0xFF0D47A1), fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // TAB 0: QUẢN LÝ SỰ CỐ & PHÂN CÔNG (GIAO DIỆN HIỆN TẠI)
  // ==============================================================
  Widget _buildIncidentsTab(String userName) {
    final filtered = _filteredIncidents;
    final total = _stats?['total'] ?? _incidents.length;
    final pending = _stats?['pending'] ?? 0;
    final processing = _stats?['processing'] ?? 0;
    final resolved = _stats?['resolved'] ?? 0;

    return RefreshIndicator(
      onRefresh: _loadAllData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Chào mừng Admin
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF0D47A1), Color(0xFF1976D2)]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.admin_panel_settings, color: Colors.white, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Ban Quản Lý: $userName',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.5),
                      ),
                    ],
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white70),
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    ),
                    icon: const Icon(Icons.meeting_room, size: 16),
                    label: const Text('Xem Phòng & QR', style: TextStyle(fontSize: 12)),
                    onPressed: () => setState(() => _currentAdminTab = 1),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Tiêu đề & nút bỏ lọc
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Thống kê & Bộ lọc trạng thái',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                ),
                if (_selectedFilter != 'Tất cả')
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    icon: const Icon(Icons.close, size: 14),
                    label: const Text('Xóa lọc', style: TextStyle(fontSize: 12)),
                    onPressed: () => setState(() => _selectedFilter = 'Tất cả'),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Thẻ thống kê
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 500) {
                  return Row(
                    children: [
                      Expanded(
                        child: _buildCompactStatCard(
                          title: 'TẤT CẢ SỰ CỐ',
                          filterKey: 'Tất cả',
                          count: total,
                          color: Colors.blue.shade900,
                          icon: Icons.list_alt,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildCompactStatCard(
                          title: 'CHỜ TIẾP NHẬN',
                          filterKey: 'Chờ tiếp nhận',
                          count: pending,
                          color: Colors.orange.shade800,
                          icon: Icons.access_time,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildCompactStatCard(
                          title: 'ĐANG XỬ LÝ',
                          filterKey: 'Đang xử lý',
                          count: processing,
                          color: Colors.blue.shade700,
                          icon: Icons.engineering,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildCompactStatCard(
                          title: 'HOÀN THÀNH',
                          filterKey: 'Hoàn thành',
                          count: resolved,
                          color: Colors.green.shade700,
                          icon: Icons.check_circle,
                        ),
                      ),
                    ],
                  );
                } else {
                  return GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 2.7,
                    children: [
                      _buildCompactStatCard(
                        title: 'TẤT CẢ SỰ CỐ',
                        filterKey: 'Tất cả',
                        count: total,
                        color: Colors.blue.shade900,
                        icon: Icons.list_alt,
                      ),
                      _buildCompactStatCard(
                        title: 'CHỜ TIẾP NHẬN',
                        filterKey: 'Chờ tiếp nhận',
                        count: pending,
                        color: Colors.orange.shade800,
                        icon: Icons.access_time,
                      ),
                      _buildCompactStatCard(
                        title: 'ĐANG XỬ LÝ',
                        filterKey: 'Đang xử lý',
                        count: processing,
                        color: Colors.blue.shade700,
                        icon: Icons.engineering,
                      ),
                      _buildCompactStatCard(
                        title: 'HOÀN THÀNH',
                        filterKey: 'Hoàn thành',
                        count: resolved,
                        color: Colors.green.shade700,
                        icon: Icons.check_circle,
                      ),
                    ],
                  );
                }
              },
            ),

            const SizedBox(height: 18),

            // Danh sách sự cố
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('Danh sách sự cố', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFF0D47A1).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                      child: Text(
                        _selectedFilter == 'Tất cả' ? 'Toàn bộ' : _selectedFilter,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
                      ),
                    ),
                  ],
                ),
                Text('${filtered.length} phiếu', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 8),

            if (filtered.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    Icon(Icons.inbox_outlined, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      _selectedFilter == 'Tất cả'
                          ? 'Chưa có sự cố nào trong hệ thống'
                          : 'Không có sự cố nào ở trạng thái "$_selectedFilter"',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13.5),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final item = filtered[index];
                  final status = item['trang_thai'] ?? 'Chờ tiếp nhận';
                  final room = item['phongHoc'] ?? item['phong_hoc'];
                  String roomText;
                  if (room != null) {
                    final soPhong = room['so_phong_day_du'] ?? 'B21.${room['so_phong']}';
                    final clean = soPhong.replaceAll('phòng', '').trim();
                    final firstChar = clean.isNotEmpty ? clean[0].toUpperCase() : 'B';
                    var khu = (room['ten_khu'] ?? 'Tòa $firstChar').toString();
                    if (khu.startsWith('Khu ')) khu = khu.replaceFirst('Khu ', 'Tòa ');
                    roomText = 'Phòng $soPhong ($khu)';
                  } else {
                    roomText = 'Phòng #${item['ma_phong_hoc']}';
                  }
                  final ktvTen = item['ktv_ten'] ?? 'Chưa phân công';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 1.5,
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(item['ma_phieu_su_co'] ?? 'Phiếu SC', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(status).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(status, style: TextStyle(color: _getStatusColor(status), fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(item['mo_ta_hu_hong'] ?? '', style: const TextStyle(fontSize: 13.5)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.meeting_room_outlined, size: 15, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(roomText, style: const TextStyle(fontSize: 12.5, color: Colors.grey)),
                              const SizedBox(width: 12),
                              const Icon(Icons.engineering_outlined, size: 15, color: Colors.grey),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'KTV: $ktvTen',
                                  style: TextStyle(
                                    color: ktvTen == 'Chưa phân công' ? Colors.orange.shade800 : Colors.blue.shade900,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),

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

                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF0D47A1),
                                  side: const BorderSide(color: Color(0xFF0D47A1)),
                                  visualDensity: VisualDensity.compact,
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                ),
                                icon: const Icon(Icons.person_outline, size: 14),
                                label: const Text('Người Báo', style: TextStyle(fontSize: 11)),
                                onPressed: () => _showReporterDialog(item),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0D47A1),
                                  foregroundColor: Colors.white,
                                  visualDensity: VisualDensity.compact,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                ),
                                icon: const Icon(Icons.person_add, size: 14),
                                label: const Text('Phân Công KTV', style: TextStyle(fontSize: 11)),
                                onPressed: () => _showAssignDialog(item),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
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
          height: 64,
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
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        width: 64,
                        height: 64,
                        color: Colors.grey.shade100,
                        child: const Icon(Icons.broken_image, size: 22, color: Colors.grey),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13, color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Chờ tiếp nhận':
        return Colors.orange.shade800;
      case 'Đang xử lý':
        return Colors.blue.shade700;
      case 'Hoàn thành':
        return Colors.green.shade700;
      default:
        return const Color(0xFF0D47A1);
    }
  }

  Widget _buildCompactStatCard({
    required String title,
    required String filterKey,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    final bool isSelected = _selectedFilter == filterKey;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilter = filterKey;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.12) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? color : Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userName = widget.user['ho_va_ten'] ?? 'Quản Trị Viên';

    String appTitle;
    if (_currentAdminTab == 0) {
      appTitle = 'Quản Trị Sự Cố TVU';
    } else if (_currentAdminTab == 1) {
      appTitle = 'Quản Lý Phòng & Thiết Bị';
    } else {
      appTitle = 'Tài Khoản & KTV TVU';
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text(appTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllData,
            tooltip: 'Làm mới',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final nav = Navigator.of(context);
              await _api.logout();
              if (!mounted) return;
              nav.pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (_currentAdminTab == 0
              ? _buildIncidentsTab(userName)
              : (_currentAdminTab == 1 ? _buildRoomManagementTab() : _buildUserManagementTab())),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentAdminTab,
        selectedItemColor: const Color(0xFF0D47A1),
        unselectedItemColor: Colors.grey.shade600,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 11.5),
        backgroundColor: Colors.white,
        elevation: 8,
        onTap: (index) {
          setState(() {
            _currentAdminTab = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Quản Lý Sự Cố',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.meeting_room),
            label: 'Phòng & Thiết Bị',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Người Dùng & KTV',
          ),
        ],
      ),
    );
  }
}
