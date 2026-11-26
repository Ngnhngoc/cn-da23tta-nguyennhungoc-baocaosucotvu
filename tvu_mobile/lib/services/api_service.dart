import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      final host = Uri.base.host;
      if (host.isNotEmpty) {
        return 'http://$host:8000/api';
      }
    }
    return 'http://172.20.10.2:8000/api';
  }

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late final Dio _dio;
  String? _token;

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      ),
    );
  }

  void setToken(String token) {
    _token = token;
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearToken() {
    _token = null;
    _dio.options.headers.remove('Authorization');
  }

  bool get isAuthenticated => _token != null;

  // 1. Đăng nhập
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '/login',
        data: {'username': username, 'password': password},
      );
      if (response.data['status'] == 'success' && response.data['token'] != null) {
        setToken(response.data['token']);
      }
      return response.data;
    } on DioException catch (e) {
      if (e.response != null && e.response?.data is Map<String, dynamic>) {
        return e.response!.data;
      }
      return {'status': 'error', 'message': 'Không thể kết nối đến máy chủ: ${e.message}'};
    }
  }

  // 2. Lấy danh sách phòng học
  Future<List<dynamic>> getRooms() async {
    try {
      final response = await _dio.get('/rooms');
      if (response.data['status'] == 'success') {
        return response.data['data'] as List<dynamic>;
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // 3. Lấy danh mục loại sự cố
  Future<List<dynamic>> getIncidentTypes() async {
    try {
      final response = await _dio.get('/incident-types');
      if (response.data['status'] == 'success') {
        return response.data['data'] as List<dynamic>;
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // 4. Lấy thông tin phòng qua mã QR
  Future<Map<String, dynamic>?> getRoomByQr(String qrCode) async {
    try {
      final code = Uri.encodeComponent(qrCode.trim());
      final response = await _dio.get('/room/$code');
      if (response.data['status'] == 'success') {
        return response.data['data'] as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // 5. Gửi báo cáo sự cố mới (Hỗ trợ tối đa 5 ảnh chụp/chọn)
  Future<Map<String, dynamic>> createIncident({
    required int roomId,
    required int typeId,
    required String description,
    String? location,
    dynamic imageBytes,
    String? imageName,
    List<dynamic>? imagesBytesList,
    List<String>? imagesNamesList,
  }) async {
    try {
      final Map<String, dynamic> map = {
        'ma_phong_hoc': roomId,
        'ma_loai_su_co': typeId,
        'mo_ta_hu_hong': description,
        'vi_tri_trong_phong': location ?? '',
      };

      // Đính kèm danh sách nhiều ảnh (tối đa 5 ảnh)
      if (imagesBytesList != null && imagesBytesList.isNotEmpty) {
        for (int i = 0; i < imagesBytesList.length && i < 5; i++) {
          final bytes = imagesBytesList[i];
          final name = (imagesNamesList != null && i < imagesNamesList.length)
              ? imagesNamesList[i]
              : 'incident_img_$i.jpg';
          map['hinh_anh_$i'] = MultipartFile.fromBytes(
            bytes,
            filename: name,
          );
        }
      } else if (imageBytes != null && imageName != null) {
        map['hinh_anh_0'] = MultipartFile.fromBytes(
          imageBytes,
          filename: imageName,
        );
      }

      final formData = FormData.fromMap(map);
      final response = await _dio.post('/incidents', data: formData);
      return response.data;
    } on DioException catch (e) {
      if (e.response != null && e.response?.data is Map<String, dynamic>) {
        return e.response!.data;
      }
      return {'status': 'error', 'message': 'Gửi báo cáo thất bại: ${e.message}'};
    }
  }

  // 6. Lấy danh sách sự cố của tôi
  Future<List<dynamic>> getMyIncidents() async {
    try {
      final response = await _dio.get('/my-incidents');
      if (response.data['status'] == 'success') {
        return response.data['data'] as List<dynamic>;
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // 7. Lấy tất cả sự cố (Dành cho Admin & Kỹ thuật viên)
  Future<List<dynamic>> getAllIncidents({bool? assignedToMe}) async {
    try {
      final response = await _dio.get(
        '/all-incidents',
        queryParameters: assignedToMe == true ? {'assigned_to_me': 'true'} : null,
      );
      if (response.data['status'] == 'success') {
        return response.data['data'] as List<dynamic>;
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // 8. Lấy danh sách nhân viên kỹ thuật
  Future<List<dynamic>> getTechnicians() async {
    try {
      final response = await _dio.get('/technicians');
      if (response.data['status'] == 'success') {
        return response.data['data'] as List<dynamic>;
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // 9. Admin phân công sự cố cho KTV
  Future<Map<String, dynamic>> assignTechnician(int incidentId, int technicianId) async {
    try {
      final response = await _dio.post(
        '/incidents/$incidentId/assign',
        data: {'ky_thuat_vien_id': technicianId},
      );
      return response.data;
    } catch (e) {
      return {'status': 'error', 'message': 'Lỗi phân công: $e'};
    }
  }

  // 10. KTV cập nhật trạng thái sự cố (Kèm danh sách ảnh nghiệm thu tối đa 5 ảnh)
  Future<Map<String, dynamic>> updateIncidentStatus(
    int incidentId,
    String status, {
    String? note,
    dynamic imageBytes,
    String? imageName,
    List<dynamic>? imagesBytesList,
    List<String>? imagesNamesList,
  }) async {
    try {
      final Map<String, dynamic> map = {
        'trang_thai': status,
        'ghi_chu': note ?? 'Cập nhật bởi kỹ thuật viên',
      };

      if (imagesBytesList != null && imagesBytesList.isNotEmpty) {
        for (int i = 0; i < imagesBytesList.length && i < 5; i++) {
          final bytes = imagesBytesList[i];
          final name = (imagesNamesList != null && i < imagesNamesList.length)
              ? imagesNamesList[i]
              : 'proof_resolved_$i.jpg';
          map['hinh_anh_nghiem_thu_$i'] = MultipartFile.fromBytes(
            bytes,
            filename: name,
          );
        }
      } else if (imageBytes != null && imageName != null) {
        map['hinh_anh_nghiem_thu'] = MultipartFile.fromBytes(
          imageBytes,
          filename: imageName,
        );
      }

      final formData = FormData.fromMap(map);
      final response = await _dio.post(
        '/incidents/$incidentId/update-status',
        data: formData,
      );
      return response.data;
    } catch (e) {
      return {'status': 'error', 'message': 'Lỗi cập nhật: $e'};
    }
  }

  // 11. Thống kê
  Future<Map<String, dynamic>?> getStats() async {
    try {
      final response = await _dio.get('/stats');
      if (response.data['status'] == 'success') {
        return response.data['data'] as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // 12.0 Admin: Lấy danh sách Khu & Thêm Khu
  Future<List<dynamic>> getCampuses() async {
    try {
      final response = await _dio.get('/admin/campuses');
      if (response.data['status'] == 'success') {
        return response.data['data'] as List<dynamic>;
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, dynamic>> addCampus({
    required String name,
    required String shortCode,
    String? address,
    String? description,
  }) async {
    try {
      final response = await _dio.post('/admin/campuses', data: {
        'ten_khuon_vien': name,
        'ma_viet_tat': shortCode,
        'dia_chi': address ?? 'Đại học Trà Vinh',
        'mo_ta': description,
      });
      return response.data;
    } catch (e) {
      return {'status': 'error', 'message': 'Lỗi thêm khu: $e'};
    }
  }

  // 12.1 Admin: Lấy danh sách Tòa & Thêm Tòa
  Future<List<dynamic>> getBuildings() async {
    try {
      final response = await _dio.get('/admin/buildings');
      if (response.data['status'] == 'success') {
        return response.data['data'] as List<dynamic>;
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, dynamic>> addBuilding({
    required String buildingCode,
    required int campusId,
    String? buildingName,
    int floorCount = 4,
  }) async {
    try {
      final response = await _dio.post('/admin/buildings', data: {
        'ma_toa': buildingCode.toUpperCase(),
        'ma_khuon_vien': campusId,
        'ten_day_nha': buildingName ?? 'Tòa nhà ${buildingCode.toUpperCase()}',
        'tong_so_tang': floorCount,
      });
      return response.data;
    } catch (e) {
      return {'status': 'error', 'message': 'Lỗi thêm tòa: $e'};
    }
  }

  // 12.2 Admin: Thêm phòng học & Sinh mã QR định danh
  Future<Map<String, dynamic>> addRoom({
    required String roomNumber,
    int? floor,
    int? buildingId,
    String? buildingCode,
    int? campusId,
    String roomType = 'Lý thuyết',
    int acCount = 2,
    int fanCount = 2,
    int tvCount = 1,
    int hdmiCount = 1,
    int boardCount = 1,
    int studentDeskCount = 20,
    int teacherDeskCount = 1,
  }) async {
    try {
      final response = await _dio.post('/admin/rooms', data: {
        'so_phong': roomNumber,
        'tang_so': floor,
        if (buildingId != null) 'ma_day_nha': buildingId,
        if (buildingCode != null) 'ma_toa': buildingCode,
        if (campusId != null) 'ma_khuon_vien': campusId,
        'loai_phong': roomType,
        'so_may_lanh': acCount,
        'so_quat': fanCount,
        'so_tivi': tvCount,
        'so_cong_hdmi': hdmiCount,
        'so_bang_viet': boardCount,
        'so_ban_sinh_vien': studentDeskCount,
        'so_ban_giao_vien': teacherDeskCount,
      });
      return response.data;
    } catch (e) {
      return {'status': 'error', 'message': 'Lỗi thêm phòng: $e'};
    }
  }

  // 12.3 Admin: Xóa phòng học
  Future<Map<String, dynamic>> deleteRoom(int roomId) async {
    try {
      final response = await _dio.delete('/admin/rooms/$roomId');
      return response.data;
    } catch (e) {
      return {'status': 'error', 'message': 'Lỗi xóa phòng: $e'};
    }
  }

  // 13. Admin: Thêm / Cập nhật thiết bị cho phòng học
  Future<Map<String, dynamic>> updateRoomEquipments(
    int roomId, {
    required int acCount,
    required int fanCount,
    required int tvCount,
    int hdmiCount = 1,
    int boardCount = 1,
  }) async {
    try {
      final response = await _dio.post('/admin/rooms/$roomId/equipments', data: {
        'so_may_lanh': acCount,
        'so_quat': fanCount,
        'so_tivi': tvCount,
        'so_cong_hdmi': hdmiCount,
        'so_bang_viet': boardCount,
      });
      return response.data;
    } catch (e) {
      return {'status': 'error', 'message': 'Lỗi cập nhật thiết bị: $e'};
    }
  }

  // 14. Admin: Thêm người dùng (Giảng viên, Sinh viên, Kỹ thuật viên)
  Future<Map<String, dynamic>> addUser({
    required String username,
    required String fullName,
    required String role,
    String? phone,
    String? unitOrClass,
    String? password,
  }) async {
    try {
      final response = await _dio.post('/admin/users', data: {
        'ten_dang_nhap': username,
        'ho_va_ten': fullName,
        'vai_tro': role,
        'so_dien_thoai': phone ?? '0987654321',
        'lop_hoac_don_vi': unitOrClass ?? 'TVU',
        'mat_khau': password ?? '123456',
      });
      return response.data;
    } catch (e) {
      return {'status': 'error', 'message': 'Lỗi thêm người dùng: $e'};
    }
  }

  // 15. Đăng xuất
  Future<void> logout() async {
    try {
      await _dio.post('/logout');
    } catch (_) {}
    clearToken();
  }
}
