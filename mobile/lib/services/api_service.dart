import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/category_model.dart';
import '../models/incident_model.dart';
import '../models/room_model.dart';
import 'auth_service.dart';

class ApiService {
  static Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.getToken();
    final headers = {'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // 1. Categories
  static Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await http.get(Uri.parse(ApiConstants.categories));
      if (response.statusCode == 200) {
        final List list = jsonDecode(response.body);
        return list.map((item) => CategoryModel.fromJson(item)).toList();
      }
    } catch (_) {}
    return [];
  }

  // 2. Lookup room by QR Code
  static Future<RoomModel?> getRoomByQr(String qrCode) async {
    try {
      final uri = Uri.parse(ApiConstants.roomByQr(Uri.encodeComponent(qrCode.trim())));
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return RoomModel.fromJson(jsonDecode(response.body));
      }
    } catch (_) {}
    return null;
  }

  // 3. Get all rooms
  static Future<List<RoomModel>> getRooms({int? buildingId}) async {
    try {
      var url = ApiConstants.rooms;
      if (buildingId != null) url += '?buildingId=$buildingId';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List list = jsonDecode(response.body);
        return list.map((item) => RoomModel.fromJson(item)).toList();
      }
    } catch (_) {}
    return [];
  }

  // 4. Upload photo from mobile
  static Future<String?> uploadImage(String filePath) async {
    try {
      final token = await AuthService.getToken();
      final request = http.MultipartRequest('POST', Uri.parse(ApiConstants.uploadImage));
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['url'];
      }
    } catch (_) {}
    return null;
  }

  // 5. Create Incident Report
  static Future<Map<String, dynamic>> createIncident({
    required String title,
    required String description,
    required int roomId,
    required int categoryId,
    required String priority,
    String? specificLocation,
    List<String> imageUrls = const [],
  }) async {
    try {
      final headers = await _getHeaders();
      final body = jsonEncode({
        'title': title,
        'description': description,
        'roomId': roomId,
        'categoryId': categoryId,
        'priority': priority,
        'specificLocation': specificLocation,
        'imageUrls': imageUrls,
      });

      final response = await http.post(
        Uri.parse(ApiConstants.incidents),
        headers: headers,
        body: body,
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Không thể gửi báo cáo.'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // 6. Get My Incidents
  static Future<List<IncidentListItem>> getMyIncidents() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(ApiConstants.myReports), headers: headers);
      if (response.statusCode == 200) {
        final List list = jsonDecode(response.body);
        return list.map((item) => IncidentListItem.fromJson(item)).toList();
      }
    } catch (_) {}
    return [];
  }

  // 7. Get Technician Assigned Tasks
  static Future<List<IncidentListItem>> getAssignedTasks() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(ApiConstants.assignedToMe), headers: headers);
      if (response.statusCode == 200) {
        final List list = jsonDecode(response.body);
        return list.map((item) => IncidentListItem.fromJson(item)).toList();
      }
    } catch (_) {}
    return [];
  }

  // 8. Incident Detail
  static Future<IncidentDetailModel?> getIncidentDetail(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(ApiConstants.incidentDetail(id)), headers: headers);
      if (response.statusCode == 200) {
        return IncidentDetailModel.fromJson(jsonDecode(response.body));
      }
    } catch (_) {}
    return null;
  }

  // 9. Update status (Technician / Admin)
  static Future<bool> updateStatus(
    int id,
    String status, {
    String? note,
    List<String>? resolutionImageUrls,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = jsonEncode({
        'status': status,
        'actionNote': note,
        'resolutionImageUrls': resolutionImageUrls ?? [],
      });

      final response = await http.put(
        Uri.parse(ApiConstants.incidentStatus(id)),
        headers: headers,
        body: body,
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // 10. Submit feedback rating
  static Future<bool> submitFeedback(int id, int rating, String? comment) async {
    try {
      final headers = await _getHeaders();
      final body = jsonEncode({
        'rating': rating,
        'comment': comment,
      });

      final response = await http.post(
        Uri.parse(ApiConstants.incidentFeedback(id)),
        headers: headers,
        body: body,
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
