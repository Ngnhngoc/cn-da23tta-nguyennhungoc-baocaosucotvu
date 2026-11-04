import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const TvuFacilityApp());
}

class TvuFacilityApp extends StatelessWidget {
  const TvuFacilityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TVU Facility',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Màu chủ đạo: Xanh dương TVU
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D47A1)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

// Đổi từ StatelessWidget sang StatefulWidget để dùng được hàm Delay
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Hẹn giờ: Tự động chuyển sang LoginScreen sau đúng 2 giây
    Future.delayed(const Duration(seconds: 2), () {
      // Dùng pushReplacement để xóa Splash Screen khỏi lịch sử (nhấn nút Back không quay lại được trang xanh này)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0D47A1), // Nền màu xanh TVU
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school, size: 100, color: Colors.white), // Logo tạm
            SizedBox(height: 20),
            Text(
              'TVU FACILITY',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Hệ thống báo cáo sự cố CSVC',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}