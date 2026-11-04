import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/qr_scanner_modal.dart';
import 'create_report_screen.dart';
import 'login_screen.dart';

class TeacherStudentScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const TeacherStudentScreen({super.key, required this.user});

  @override
  State<TeacherStudentScreen> createState() => _TeacherStudentScreenState();
}

class _TeacherStudentScreenState extends State<TeacherStudentScreen> {
  final ApiService _api = ApiService();
  int _currentTabIndex = 0; // 0: Trang chủ (Danh sách sự cố), 1: Biểu mẫu báo cáo
  List<dynamic> _incidents = [];
  bool _isLoading = true;

  // Phòng được quét từ mã QR để chuyển sang tab Báo Cáo
  Map<String, dynamic>? _scannedRoom;

  // Bộ lọc trạng thái: 'all', 'Chờ tiếp nhận', 'Đã phân công', 'Đang xử lý', 'Hoàn thành'
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final incidents = await _api.getMyIncidents();
    if (mounted) {
      setState(() {
        _incidents = incidents;
        _isLoading = false;
      });
    }
  }

  // Mở Camera Quét Mã QR -> Tự động chuyển sang Báo Cáo Mới theo phòng vừa quét
  Future<void> _openQrScannerAndCreateReport() async {
    final rooms = await _api.getRooms();
    if (!mounted) return;

    QrScannerModal.show(
      context: context,
      availableRooms: rooms,
      onScanned: (qrCode) async {
        final clean = qrCode.replaceAll(RegExp(r'^(TVU-|B21\.|B21-)', caseSensitive: false), '').trim().toLowerCase();
        Map<String, dynamic>? foundRoom = rooms.cast<Map<String, dynamic>?>().firstWhere(
          (r) {
            if (r == null) return false;
            final qr = (r['ma_qr_dinh_danh'] ?? '').toString().toLowerCase();
            final sp = (r['so_phong'] ?? '').toString().toLowerCase();
            final spdd = (r['so_phong_day_du'] ?? '').toString().toLowerCase();
            return qr == qrCode.toLowerCase() || sp == clean || spdd == clean || qr.contains(clean);
          },
          orElse: () => null,
        );

        if (foundRoom == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('🔍 Đang kiểm tra mã QR: $qrCode...'),
              duration: const Duration(seconds: 1),
            ),
          );
          foundRoom = await _api.getRoomByQr(qrCode);
        }

        if (mounted) {
          if (foundRoom != null) {
            final roomName = foundRoom['so_phong_day_du'] ?? 'Phòng ${foundRoom['so_phong']}';
            setState(() {
              _scannedRoom = foundRoom;
              _currentTabIndex = 1;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✅ Đã nhận diện: $roomName! Hãy nhập mô tả sự cố để gửi.'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
          } else {
            setState(() => _currentTabIndex = 1);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('⚠️ Mã QR "$qrCode" không khớp phòng nào. Vui lòng chọn từ danh sách.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      },
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

  // Lọc danh sách sự cố theo bộ lọc
  List<dynamic> _getFilteredIncidents() {
    if (_selectedFilter == 'all') return _incidents;
    if (_selectedFilter == 'Đã phân công') {
      return _incidents.where((item) => item['ktv_info'] != null).toList();
    }
    return _incidents.where((item) => item['trang_thai'] == _selectedFilter).toList();
  }

  // Xem lịch sử chi tiết tiến độ xử lý của phiếu sự cố
  void _showIncidentHistoryModal(Map<String, dynamic> item) {
    final historyList = (item['lich_su_list'] as List<dynamic>?) ?? [];
    final room = item['phong_hoc'];
    final soPhong = room != null ? (room['so_phong_day_du'] ?? 'B21.${room['so_phong']}') : '${item['ma_phong_hoc']}';
    var khu = room != null ? (room['ten_khu'] ?? 'Tòa B').toString() : 'Tòa B';
    if (khu.startsWith('Khu ')) khu = khu.replaceFirst('Khu ', 'Tòa ');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thanh gạt modal
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),

            // Tiêu đề phiếu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lịch Sử Phiếu: ${item['ma_phieu_su_co'] ?? 'Sự Cố'}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
                      ),
                      const SizedBox(height: 2),
                      Text('Phòng $soPhong ($khu)', style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(item['trang_thai']).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item['trang_thai'] ?? 'Chờ tiếp nhận',
                    style: TextStyle(color: _getStatusColor(item['trang_thai']), fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Chi tiết mô tả ban đầu
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Mô tả hư hỏng báo cáo:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                  const SizedBox(height: 4),
                  Text(item['mo_ta_hu_hong'] ?? '', style: const TextStyle(fontSize: 13.5)),
                  if (item['ktv_info'] != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.engineering, size: 16, color: Color(0xFF0D47A1)),
                        const SizedBox(width: 6),
                        Text(
                          'KTV phụ trách: ${item['ktv_info']['ho_va_ten']} (SĐT: ${item['ktv_info']['so_dien_thoai']})',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0D47A1)),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),
            const Text('Tiến độ xử lý:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            // Timeline các bước xử lý
            Expanded(
              child: historyList.isEmpty
                  ? Center(
                      child: Text(
                        'Đã ghi nhận báo cáo vào hệ thống.\nĐang chờ Ban Quản lý tiếp nhận & phân công KTV.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    )
                  : ListView.builder(
                      itemCount: historyList.length,
                      itemBuilder: (context, idx) {
                        final h = historyList[idx];
                        final timeStr = h['thoi_gian_cap_nhat'] != null
                            ? h['thoi_gian_cap_nhat'].toString().replaceAll('T', ' ').split('.').first
                            : '';
                        final isLast = idx == historyList.length - 1;

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: isLast ? const Color(0xFF0D47A1) : Colors.grey[400],
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                ),
                                if (!isLast)
                                  Container(
                                    width: 2,
                                    height: 50,
                                    color: Colors.grey[300],
                                  ),
                              ],
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          h['trang_thai_moi'] ?? 'Cập nhật',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                                        ),
                                        Text(timeStr, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      h['noi_dung_ghi_chu'] ?? '',
                                      style: TextStyle(color: Colors.grey[800], fontSize: 12.5),
                                    ),
                                    if (h['nguoi_thuc_hien_ten'] != null)
                                      Text(
                                        'Thực hiện: ${h['nguoi_thuc_hien_ten']} (${h['nguoi_thuc_hien_vaitro'] ?? 'BQL'})',
                                        style: TextStyle(color: Colors.grey[500], fontSize: 11),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),

            // Nút đóng
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1), foregroundColor: Colors.white),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('ĐÓNG'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userName = widget.user['ho_va_ten'] ?? 'Người dùng';
    final userRole = widget.user['vai_tro'] ?? 'Sinh viên';
    final userUnit = widget.user['lop_don_vi'] ?? 'TVU';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: Text(
          '$userRole TVU',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Làm mới dữ liệu',
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
      body: _currentTabIndex == 0
          ? _buildHomeScreen(userName, userRole, userUnit)
          : CreateReportScreen(
              user: widget.user,
              initialRoom: _scannedRoom,
              onReportCreated: () {
                _loadData();
                setState(() {
                  _scannedRoom = null;
                  _currentTabIndex = 0;
                });
              },
            ),

      // NÚT QUÉT MÃ QR NẰM Ở GIỮA CUỐI MÀN HÌNH - MỞ CAMERA QUÉT TRỰC TIẾP
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(),
        tooltip: 'Quét Mã QR & Báo Cáo Sự Cố',
        onPressed: _openQrScannerAndCreateReport,
        child: const Icon(Icons.qr_code_scanner, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // THANH ĐIỀU HƯỚNG DƯỚI ĐÁY CÓ RÃNH KHOÉT
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.white,
        elevation: 10,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Nút 1: Trang chủ sự cố đã báo cáo
              InkWell(
                onTap: () => setState(() => _currentTabIndex = 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.assignment,
                      color: _currentTabIndex == 0 ? const Color(0xFF0D47A1) : Colors.grey,
                      size: 24,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Sự Cố Của Tôi',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: _currentTabIndex == 0 ? FontWeight.bold : FontWeight.normal,
                        color: _currentTabIndex == 0 ? const Color(0xFF0D47A1) : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 48), // Khoảng trống cho nút QR ở giữa

              // Nút 2: Báo cáo sự cố mới
              InkWell(
                onTap: () => setState(() => _currentTabIndex = 1),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      color: _currentTabIndex == 1 ? const Color(0xFF0D47A1) : Colors.grey,
                      size: 24,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Báo Cáo Mới',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: _currentTabIndex == 1 ? FontWeight.bold : FontWeight.normal,
                        color: _currentTabIndex == 1 ? const Color(0xFF0D47A1) : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Giao diện Trang chủ: Danh sách các sự cố đã báo cáo kèm bộ lọc
  Widget _buildHomeScreen(String userName, String userRole, String userUnit) {
    final filteredList = _getFilteredIncidents();

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Thông tin Người dùng
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: const Color(0xFF0D47A1),
                      child: Icon(
                        userRole == 'Giảng viên' ? Icons.school : Icons.person,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(userName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text('Vai trò: $userRole • $userUnit', style: TextStyle(color: Colors.grey[700], fontSize: 12.5)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // TIÊU ĐỀ & BỘ LỌC TRẠNG THÁI
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Sự cố đã báo cáo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('${filteredList.length}/${_incidents.length} phiếu', style: TextStyle(color: Colors.grey[600], fontSize: 12.5, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 8),

            // THANH FILTER CHIPS: Tất cả, Chờ tiếp nhận, Đã phân công, Đang xử lý, Hoàn thành
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Tất cả', 'all', _incidents.length),
                  _buildFilterChip('Chờ tiếp nhận', 'Chờ tiếp nhận', _incidents.where((i) => i['trang_thai'] == 'Chờ tiếp nhận').length),
                  _buildFilterChip('Đã phân công', 'Đã phân công', _incidents.where((i) => i['ktv_info'] != null).length),
                  _buildFilterChip('Đang xử lý', 'Đang xử lý', _incidents.where((i) => i['trang_thai'] == 'Đang xử lý').length),
                  _buildFilterChip('Hoàn thành', 'Hoàn thành', _incidents.where((i) => i['trang_thai'] == 'Hoàn thành').length),
                ],
              ),
            ),

            const SizedBox(height: 12),

            if (_isLoading)
              const Center(child: Padding(padding: EdgeInsets.all(40.0), child: CircularProgressIndicator()))
            else if (filteredList.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    Icon(Icons.assignment_outlined, size: 50, color: Colors.grey[400]),
                    const SizedBox(height: 10),
                    Text(
                      _selectedFilter == 'all'
                          ? 'Bạn chưa gửi báo cáo sự cố nào'
                          : 'Không có sự cố nào ở trạng thái "$_selectedFilter"',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D47A1),
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.qr_code_scanner, size: 18),
                      label: const Text('Quét QR Báo Cáo Ngay'),
                      onPressed: _openQrScannerAndCreateReport,
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  final item = filteredList[index];
                  final status = item['trang_thai'] ?? 'Chờ tiếp nhận';
                  final room = item['phong_hoc'];
                  String roomText;
                  if (room != null) {
                    final soPhong = room['so_phong_day_du'] ?? 'B21.${room['so_phong']}';
                    var khu = (room['ten_khu'] ?? 'Tòa B').toString();
                    if (khu.startsWith('Khu ')) khu = khu.replaceFirst('Khu ', 'Tòa ');
                    roomText = 'Phòng $soPhong ($khu)';
                  } else {
                    roomText = 'Phòng #${item['ma_phong_hoc']}';
                  }
                  final dateText = item['ngay_gui_bao_cao'] ?? '';
                  final imagesList = (item['hinh_anh_list'] as List<dynamic>?) ?? [];

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
                              Text(item['ma_phieu_su_co'] ?? 'Phiếu SC', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(status).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  status,
                                  style: TextStyle(color: _getStatusColor(status), fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 16),
                          Text(item['mo_ta_hu_hong'] ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.meeting_room_outlined, size: 16, color: Color(0xFF0D47A1)),
                              const SizedBox(width: 4),
                              Text(roomText, style: const TextStyle(color: Color(0xFF0D47A1), fontSize: 12.5, fontWeight: FontWeight.bold)),
                              if (item['vi_tri_trong_phong'] != null && (item['vi_tri_trong_phong'] as String).isNotEmpty) ...[
                                const SizedBox(width: 8),
                                const Icon(Icons.place_outlined, size: 15, color: Colors.grey),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    item['vi_tri_trong_phong'],
                                    style: TextStyle(color: Colors.grey[700], fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ],
                          ),

                          // Ảnh chụp hiện trường nếu có (hỗ trợ hiển thị nhiều ảnh)
                          if (imagesList.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 70,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: imagesList.length,
                                itemBuilder: (context, imgIdx) {
                                  final imgUrl = imagesList[imgIdx];
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        imgUrl,
                                        height: 70,
                                        width: 70,
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, e, s) => Container(
                                          width: 70,
                                          height: 70,
                                          color: Colors.grey.shade200,
                                          child: const Icon(Icons.image, size: 20, color: Colors.grey),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],

                          // Thông tin KTV phụ trách
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: (item['ktv_info'] != null) ? Colors.blue.shade50 : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: (item['ktv_info'] != null) ? Colors.blue.shade200 : Colors.grey.shade300,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  (item['ktv_info'] != null) ? Icons.engineering : Icons.access_time,
                                  size: 15,
                                  color: (item['ktv_info'] != null) ? Colors.blue.shade800 : Colors.grey.shade600,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    (item['ktv_info'] != null)
                                        ? 'KTV phụ trách: ${item['ktv_info']['ho_va_ten']} • SĐT: ${item['ktv_info']['so_dien_thoai']}'
                                        : 'Đang chờ Ban Quản lý phân công KTV...',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: (item['ktv_info'] != null) ? FontWeight.bold : FontWeight.normal,
                                      color: (item['ktv_info'] != null) ? Colors.blue.shade900 : Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Nút Xem Lịch Sử Báo Cáo & Ngày gửi
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                dateText.isNotEmpty ? 'Ngày gửi: ${dateText.toString().split('T').first}' : '',
                                style: TextStyle(color: Colors.grey[500], fontSize: 11),
                              ),
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF0D47A1),
                                  side: const BorderSide(color: Color(0xFF0D47A1)),
                                  visualDensity: VisualDensity.compact,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                ),
                                icon: const Icon(Icons.timeline, size: 16),
                                label: const Text('Xem Lịch Sử Báo Cáo', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                                onPressed: () => _showIncidentHistoryModal(item),
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

  Widget _buildFilterChip(String label, String filterKey, int count) {
    final isSelected = _selectedFilter == filterKey;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text('$label ($count)'),
        selected: isSelected,
        onSelected: (val) {
          setState(() {
            _selectedFilter = filterKey;
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
}
