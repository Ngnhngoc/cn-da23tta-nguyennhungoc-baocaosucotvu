import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../constants/api_constants.dart';
import '../../models/incident_model.dart';
import '../../services/api_service.dart';
import '../../widgets/status_badge.dart';
import '../tracking/incident_detail_screen.dart';

class TechnicianTasksScreen extends StatefulWidget {
  const TechnicianTasksScreen({super.key});

  @override
  State<TechnicianTasksScreen> createState() => _TechnicianTasksScreenState();
}

class _TechnicianTasksScreenState extends State<TechnicianTasksScreen> {
  List<IncidentListItem> _tasks = [];
  bool _isLoading = true;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    setState(() => _isLoading = true);
    final tasks = await ApiService.getAssignedTasks();
    setState(() {
      _tasks = tasks;
      _isLoading = false;
    });
  }

  Future<void> _startRepair(int incidentId) async {
    final success = await ApiService.updateStatus(
      incidentId,
      'InProgress',
      note: 'Kỹ thuật viên đã có mặt tại hiện trường và đang tiến hành khắc phục.',
    );
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã cập nhật trạng thái: Đang xử lý')),
      );
      _fetchTasks();
    }
  }

  Future<void> _completeRepair(int incidentId) async {
    // Technician takes photo of fixed equipment
    final photo = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    String? uploadedUrl;
    if (photo != null) {
      uploadedUrl = await ApiService.uploadImage(photo.path);
    }

    final success = await ApiService.updateStatus(
      incidentId,
      'Resolved',
      note: 'Kỹ thuật viên đã kiểm tra và khắc phục xong sự cố thiết bị.',
      resolutionImageUrls: uploadedUrl != null ? [uploadedUrl] : [],
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã hoàn tất khắc phục sự cố!')),
      );
      _fetchTasks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Nhiệm Vụ Bảo Trì Được Giao'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tasks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.task_alt, size: 64, color: Colors.green.shade400),
                      const SizedBox(height: 12),
                      const Text(
                        'Tuyệt vời! Hiện không còn nhiệm vụ tồn đọng.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchTasks,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _tasks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, idx) {
                      final item = _tasks[idx];
                      final dateStr = DateFormat('dd/MM HH:mm').format(item.createdAt.toLocal());

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item.incidentCode,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary),
                                ),
                                StatusBadge(status: item.status, display: item.statusDisplay, color: item.statusColor),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(Icons.room, size: 16, color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    '${item.roomNumber} - ${item.buildingName}',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Text(dateStr, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                              ],
                            ),
                            const Divider(height: 20),

                            // Action buttons
                            Row(
                              children: [
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(builder: (_) => IncidentDetailScreen(incidentId: item.id)),
                                    );
                                  },
                                  child: const Text('Chi tiết'),
                                ),
                                const Spacer(),
                                if (item.status == 'Assigned' || item.status == 'Pending')
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    icon: const Icon(Icons.play_arrow, size: 18),
                                    label: const Text('Bắt đầu xử lý'),
                                    onPressed: () => _startRepair(item.id),
                                  ),
                                if (item.status == 'InProgress')
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    icon: const Icon(Icons.camera_alt, size: 18),
                                    label: const Text('Đã khắc phục'),
                                    onPressed: () => _completeRepair(item.id),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
