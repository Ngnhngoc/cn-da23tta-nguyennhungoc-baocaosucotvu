import 'package:flutter/material.dart';
import '../constants/api_constants.dart';

class IncidentListItem {
  final int id;
  final String incidentCode;
  final String title;
  final String description;
  final String priority;
  final String status;
  final DateTime createdAt;
  final int roomId;
  final String roomNumber;
  final String buildingName;
  final String campusName;
  final int categoryId;
  final String categoryName;
  final String? categoryIcon;
  final String reportedByFullName;
  final String? assignedToFullName;
  final String? thumbnailUrl;

  IncidentListItem({
    required this.id,
    required this.incidentCode,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.createdAt,
    required this.roomId,
    required this.roomNumber,
    required this.buildingName,
    required this.campusName,
    required this.categoryId,
    required this.categoryName,
    this.categoryIcon,
    required this.reportedByFullName,
    this.assignedToFullName,
    this.thumbnailUrl,
  });

  factory IncidentListItem.fromJson(Map<String, dynamic> json) {
    return IncidentListItem(
      id: json['id'] ?? 0,
      incidentCode: json['incidentCode'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      priority: json['priority'] ?? 'Medium',
      status: json['status'] ?? 'Pending',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      roomId: json['roomId'] ?? 0,
      roomNumber: json['roomNumber'] ?? '',
      buildingName: json['buildingName'] ?? '',
      campusName: json['campusName'] ?? '',
      categoryId: json['categoryId'] ?? 0,
      categoryName: json['categoryName'] ?? '',
      categoryIcon: json['categoryIcon'],
      reportedByFullName: json['reportedByFullName'] ?? '',
      assignedToFullName: json['assignedToFullName'],
      thumbnailUrl: json['thumbnailUrl'],
    );
  }

  String get fullImageUrl {
    if (thumbnailUrl == null || thumbnailUrl!.isEmpty) return '';
    if (thumbnailUrl!.startsWith('http')) return thumbnailUrl!;
    return '${ApiConstants.serverHost}$thumbnailUrl';
  }

  String get statusDisplay {
    switch (status) {
      case 'Pending':
        return 'Chờ tiếp nhận';
      case 'Assigned':
        return 'Đã phân công';
      case 'InProgress':
        return 'Đang xử lý';
      case 'Resolved':
        return 'Đã khắc phục';
      case 'Closed':
        return 'Đã hoàn thành';
      case 'Rejected':
        return 'Từ chối';
      default:
        return status;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'Pending':
        return AppColors.pending;
      case 'Assigned':
        return AppColors.assigned;
      case 'InProgress':
        return AppColors.inProgress;
      case 'Resolved':
        return AppColors.resolved;
      case 'Closed':
        return AppColors.closed;
      case 'Rejected':
        return AppColors.rejected;
      default:
        return Colors.grey;
    }
  }

  String get priorityDisplay {
    switch (priority) {
      case 'Low':
        return 'Thấp';
      case 'Medium':
        return 'Trung bình';
      case 'High':
        return 'Cao';
      case 'Critical':
        return 'Khẩn cấp';
      default:
        return priority;
    }
  }

  Color get priorityColor {
    switch (priority) {
      case 'Low':
        return AppColors.priorityLow;
      case 'Medium':
        return AppColors.priorityMedium;
      case 'High':
        return AppColors.priorityHigh;
      case 'Critical':
        return AppColors.priorityCritical;
      default:
        return Colors.grey;
    }
  }
}

class IncidentDetailModel {
  final int id;
  final String incidentCode;
  final String title;
  final String description;
  final String? specificLocation;
  final String priority;
  final String status;
  final DateTime createdAt;
  final DateTime? assignedAt;
  final DateTime? resolvedAt;
  final DateTime? closedAt;

  final int roomId;
  final String roomNumber;
  final String roomType;
  final String qrCode;
  final String buildingName;
  final String campusName;

  final int categoryId;
  final String categoryName;
  final String? categoryIcon;

  final String reportedByFullName;
  final String reportedByEmail;
  final String reportedByPhone;

  final String? assignedToFullName;
  final String? assignedToPhone;

  final List<IncidentImageItem> images;
  final List<IncidentHistoryItem> histories;
  final int? rating;
  final String? feedbackComment;

  IncidentDetailModel({
    required this.id,
    required this.incidentCode,
    required this.title,
    required this.description,
    this.specificLocation,
    required this.priority,
    required this.status,
    required this.createdAt,
    this.assignedAt,
    this.resolvedAt,
    this.closedAt,
    required this.roomId,
    required this.roomNumber,
    required this.roomType,
    required this.qrCode,
    required this.buildingName,
    required this.campusName,
    required this.categoryId,
    required this.categoryName,
    this.categoryIcon,
    required this.reportedByFullName,
    required this.reportedByEmail,
    required this.reportedByPhone,
    this.assignedToFullName,
    this.assignedToPhone,
    required this.images,
    required this.histories,
    this.rating,
    this.feedbackComment,
  });

  factory IncidentDetailModel.fromJson(Map<String, dynamic> json) {
    var reportedBy = json['reportedBy'] ?? {};
    var assignedTo = json['assignedTo'];

    var imagesList = (json['images'] as List? ?? [])
        .map((img) => IncidentImageItem.fromJson(img))
        .toList();

    var historyList = (json['histories'] as List? ?? [])
        .map((h) => IncidentHistoryItem.fromJson(h))
        .toList();

    var feedback = json['feedback'];

    return IncidentDetailModel(
      id: json['id'] ?? 0,
      incidentCode: json['incidentCode'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      specificLocation: json['specificLocation'],
      priority: json['priority'] ?? 'Medium',
      status: json['status'] ?? 'Pending',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      assignedAt: json['assignedAt'] != null ? DateTime.parse(json['assignedAt']) : null,
      resolvedAt: json['resolvedAt'] != null ? DateTime.parse(json['resolvedAt']) : null,
      closedAt: json['closedAt'] != null ? DateTime.parse(json['closedAt']) : null,
      roomId: json['roomId'] ?? 0,
      roomNumber: json['roomNumber'] ?? '',
      roomType: json['roomType'] ?? '',
      qrCode: json['qrCode'] ?? '',
      buildingName: json['buildingName'] ?? '',
      campusName: json['campusName'] ?? '',
      categoryId: json['categoryId'] ?? 0,
      categoryName: json['categoryName'] ?? '',
      categoryIcon: json['categoryIcon'],
      reportedByFullName: reportedBy['fullName'] ?? '',
      reportedByEmail: reportedBy['email'] ?? '',
      reportedByPhone: reportedBy['phoneNumber'] ?? '',
      assignedToFullName: assignedTo != null ? assignedTo['fullName'] : null,
      assignedToPhone: assignedTo != null ? assignedTo['phoneNumber'] : null,
      images: imagesList,
      histories: historyList,
      rating: feedback != null ? feedback['rating'] : null,
      feedbackComment: feedback != null ? feedback['comment'] : null,
    );
  }
}

class IncidentImageItem {
  final int id;
  final String imageUrl;
  final String imageType; // "Report" or "Resolution"
  final DateTime uploadedAt;

  IncidentImageItem({
    required this.id,
    required this.imageUrl,
    required this.imageType,
    required this.uploadedAt,
  });

  factory IncidentImageItem.fromJson(Map<String, dynamic> json) {
    return IncidentImageItem(
      id: json['id'] ?? 0,
      imageUrl: json['imageUrl'] ?? '',
      imageType: json['imageType'] ?? 'Report',
      uploadedAt: json['uploadedAt'] != null ? DateTime.parse(json['uploadedAt']) : DateTime.now(),
    );
  }

  String get fullUrl {
    if (imageUrl.startsWith('http')) return imageUrl;
    return '${ApiConstants.serverHost}$imageUrl';
  }
}

class IncidentHistoryItem {
  final int id;
  final String? previousStatus;
  final String newStatus;
  final String actionNote;
  final String updatedByFullName;
  final DateTime createdAt;

  IncidentHistoryItem({
    required this.id,
    this.previousStatus,
    required this.newStatus,
    required this.actionNote,
    required this.updatedByFullName,
    required this.createdAt,
  });

  factory IncidentHistoryItem.fromJson(Map<String, dynamic> json) {
    return IncidentHistoryItem(
      id: json['id'] ?? 0,
      previousStatus: json['previousStatus'],
      newStatus: json['newStatus'] ?? '',
      actionNote: json['actionNote'] ?? '',
      updatedByFullName: json['updatedByFullName'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }
}
