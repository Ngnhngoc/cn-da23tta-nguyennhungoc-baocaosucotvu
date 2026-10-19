import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ApiConstants {
  // Tự động nhận diện host: Khi mở trên web (cả PC và điện thoại qua Wi-Fi) tự lấy IP đang kết nối
  static String get serverHost {
    if (kIsWeb) {
      return Uri.base.origin;
    }
    return 'http://10.0.2.2:5209';
  }

  static String get baseUrl => '$serverHost/api';

  // Endpoints
  static String get login => '$baseUrl/auth/login';
  static String get register => '$baseUrl/auth/register';
  static String get currentUser => '$baseUrl/auth/me';
  static String get technicians => '$baseUrl/auth/technicians';

  static String get campuses => '$baseUrl/masterdata/campuses';
  static String get categories => '$baseUrl/masterdata/categories';
  static String get dashboard => '$baseUrl/masterdata/dashboard';

  static String get rooms => '$baseUrl/rooms';
  static String roomByQr(String qr) => '$baseUrl/rooms/by-qr/$qr';

  static String get incidents => '$baseUrl/incidents';
  static String get myReports => '$baseUrl/incidents/my-reports';
  static String get assignedToMe => '$baseUrl/incidents/assigned-to-me';
  static String incidentDetail(int id) => '$baseUrl/incidents/$id';
  static String incidentStatus(int id) => '$baseUrl/incidents/$id/status';
  static String incidentFeedback(int id) => '$baseUrl/incidents/$id/feedback';

  static String get uploadImage => '$baseUrl/uploads';
}

class AppColors {
  // Màu sắc nhận diện thương hiệu Đại học Trà Vinh (TVU)
  static const Color primary = Color(0xFF0055A5); // Xanh dương TVU
  static const Color primaryDark = Color(0xFF003B73);
  static const Color primaryLight = Color(0xFFE6F0FA);
  static const Color accent = Color(0xFFFFB800); // Vàng kim TVU

  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);

  // Trạng thái sự cố
  static const Color pending = Color(0xFFF59E0B);    // Chờ tiếp nhận (Vàng)
  static const Color assigned = Color(0xFF3B82F6);   // Đã giao (Xanh lam)
  static const Color inProgress = Color(0xFF8B5CF6); // Đang xử lý (Tím)
  static const Color resolved = Color(0xFF10B981);   // Đã giải quyết (Xanh lá)
  static const Color closed = Color(0xFF6B7280);     // Đã đóng (Xám đậm)
  static const Color rejected = Color(0xFFEF4444);   // Từ chối (Đỏ)

  // Độ ưu tiên
  static const Color priorityLow = Color(0xFF10B981);
  static const Color priorityMedium = Color(0xFFF59E0B);
  static const Color priorityHigh = Color(0xFFF97316);
  static const Color priorityCritical = Color(0xFFEF4444);
}
