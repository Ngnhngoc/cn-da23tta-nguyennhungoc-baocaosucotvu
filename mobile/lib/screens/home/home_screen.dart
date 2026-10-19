import 'package:flutter/material.dart';
import '../../constants/api_constants.dart';
import '../../models/incident_model.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/status_badge.dart';
import '../auth/login_screen.dart';
import '../report/create_report_screen.dart';
import '../report/qr_scan_screen.dart';
import '../technician/technician_tasks_screen.dart';
import '../tracking/incident_detail_screen.dart';
import '../tracking/incident_list_screen.dart';

class HomeScreen extends StatefulWidget {
  final UserModel user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<IncidentListItem> _recentIncidents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecent();
  }

  Future<void> _fetchRecent() async {
    setState(() => _isLoading = true);
    final list = await ApiService.getMyIncidents();
    setState(() {
      _recentIncidents = list.take(3).toList();
      _isLoading = false;
    });
  }

  void _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Đăng Xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi hệ thống TVU không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Đăng Xuất'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService.logout();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTech = widget.user.isTechnician || widget.user.isAdmin;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TVU App Bar Banner
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 22,
                              child: Text(
                                widget.user.fullName.isNotEmpty ? widget.user.fullName[0].toUpperCase() : 'U',
                                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.user.fullName,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                Text(
                                  widget.user.departmentOrClass ?? widget.user.role,
                                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.logout, color: Colors.white70),
                          tooltip: 'Đăng xuất',
                          onPressed: _handleLogout,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Quick QR Code Scan Hero Box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.qr_code_scanner, color: AppColors.primary, size: 36),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Quét Mã QR Phòng Học',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Tự động định danh phòng & tạo báo cáo nhanh',
                                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const QrScanScreen()),
                              ).then((_) => _fetchRecent());
                            },
                            child: const Text('Quét Ngay'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Action shortcuts grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Chức Năng Nhanh', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildActionCard(
                          icon: Icons.add_photo_alternate,
                          title: 'Tạo Báo Cáo',
                          subtitle: 'Nhập thủ công',
                          color: Colors.blue,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const CreateReportScreen()),
                            ).then((_) => _fetchRecent());
                          },
                        ),
                        const SizedBox(width: 12),
                        _buildActionCard(
                          icon: Icons.list_alt,
                          title: 'Sự Cố Của Tôi',
                          subtitle: 'Xem tiến trình',
                          color: Colors.orange,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const IncidentListScreen()),
                            ).then((_) => _fetchRecent());
                          },
                        ),
                      ],
                    ),

                    if (isTech) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildActionCard(
                            icon: Icons.build_circle,
                            title: 'Nhiệm Vụ Bảo Trì',
                            subtitle: 'Dành cho KTV',
                            color: Colors.teal,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const TechnicianTasksScreen()),
                              ).then((_) => _fetchRecent());
                            },
                          ),
                          const SizedBox(width: 12),
                          _buildActionCard(
                            icon: Icons.help_outline,
                            title: 'Hướng Dẫn',
                            subtitle: 'Quy trình xử lý',
                            color: Colors.purple,
                            onTap: () {
                              _showHelpDialog();
                            },
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Recent incidents of logged in user
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Sự Cố Gần Đây', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const IncidentListScreen()),
                            );
                          },
                          child: const Text('Xem tất cả'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    if (_isLoading)
                      const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
                    else if (_recentIncidents.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Center(
                          child: Text(
                            'Bạn chưa gửi báo cáo sự cố nào.',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _recentIncidents.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, idx) {
                          final item = _recentIncidents[idx];
                          return InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => IncidentDetailScreen(incidentId: item.id),
                                ),
                              ).then((_) => _fetchRecent());
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: item.statusColor.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(Icons.warning_amber_rounded, color: item.statusColor),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${item.roomNumber} - ${item.buildingName}',
                                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                  StatusBadge(status: item.status, display: item.statusDisplay, color: item.statusColor),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        onTap: (idx) {
          if (idx == 1) {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const IncidentListScreen()));
          } else if (idx == 2 && isTech) {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TechnicianTasksScreen()));
          } else if (idx == 2 && !isTech) {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const QrScanScreen()));
          }
        },
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          const BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Sự cố của tôi'),
          BottomNavigationBarItem(
            icon: Icon(isTech ? Icons.handyman : Icons.qr_code_scanner),
            label: isTech ? 'Nhiệm vụ' : 'Quét QR',
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 10),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Quy Trình Xử Lý Sự Cố CSVC'),
        content: const SingleChildScrollView(
          child: Text(
            '1. Người dùng quét mã QR tại phòng hoặc chọn phòng thủ công.\n'
            '2. Chụp ảnh sự cố, chọn danh mục và gửi báo cáo.\n'
            '3. Ban Quản trị CSVC tiếp nhận và phân công cho Kỹ thuật viên phù hợp.\n'
            '4. Kỹ thuật viên đến hiện trường, bấm "Bắt đầu xử lý".\n'
            '5. Sau khi khắc phục xong, KTV chụp ảnh nghiệm thu và bấm "Đã khắc phục".\n'
            '6. Người báo cáo nghiệm thu và đánh giá 1-5 sao để đóng sự cố.',
            style: TextStyle(fontSize: 13, height: 1.5),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đã hiểu')),
        ],
      ),
    );
  }
}
