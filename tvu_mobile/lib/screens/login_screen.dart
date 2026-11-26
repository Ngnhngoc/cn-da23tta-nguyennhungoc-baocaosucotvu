import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'teacher_student_screen.dart';
import 'technician_screen.dart';
import 'admin_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  void _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin!')),
      );
      return;
    }

    setState(() { _isLoading = true; });

    try {
      final result = await _apiService.login(username, password);

      if (!mounted) return;
      setState(() { _isLoading = false; });

      if (result['status'] == 'success') {
        final user = result['user'];
        final role = user['vai_tro'] ?? 'Sinh viên';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Xin chào: ${user['ho_va_ten']} ($role)'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        Widget targetScreen;
        if (role == 'Admin' || role == 'Quản trị viên') {
          targetScreen = AdminScreen(user: user);
        } else if (role == 'Kỹ thuật viên' || role == 'Nhân viên') {
          targetScreen = TechnicianScreen(user: user);
        } else {
          targetScreen = TeacherStudentScreen(user: user);
        }

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => targetScreen),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Đăng nhập thất bại'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() { _isLoading = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _showServerConfigDialog() {
    final hostCtrl = TextEditingController(
      text: ApiService.baseUrl.replaceAll('http://', '').replaceAll('/api', ''),
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cấu hình máy chủ API'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chọn nhanh hoặc nhập địa chỉ máy tính:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                ActionChip(
                  label: const Text('192.168.2.29:8000 (Khuyên dùng cho LDPlayer)'),
                  onPressed: () => hostCtrl.text = '192.168.2.29:8000',
                ),
                ActionChip(
                  label: const Text('10.0.2.2:8000 (Android Studio)'),
                  onPressed: () => hostCtrl.text = '10.0.2.2:8000',
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: hostCtrl,
              decoration: const InputDecoration(
                labelText: 'Địa chỉ IP:Port máy chủ',
                hintText: '192.168.2.29:8000',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await _apiService.setCustomServerHost('');
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đã đặt lại mặc định: ${ApiService.baseUrl}')),
                );
              }
            },
            child: const Text('Mặc định'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _apiService.setCustomServerHost(hostCtrl.text);
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đã lưu máy chủ: ${ApiService.baseUrl}')),
                );
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.settings_ethernet, color: Colors.grey),
                tooltip: 'Cấu hình địa chỉ Server',
                onPressed: _showServerConfigDialog,
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.school, size: 80, color: Color(0xFF0D47A1)),
                    const SizedBox(height: 20),
                    const Text(
                      'ĐĂNG NHẬP',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
                    ),
                    const SizedBox(height: 40),
                    TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Mã SV / Email / Tên đăng nhập',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Mật khẩu',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D47A1),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _isLoading ? null : _handleLogin,
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('ĐĂNG NHẬP', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Server: ${ApiService.baseUrl}',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}