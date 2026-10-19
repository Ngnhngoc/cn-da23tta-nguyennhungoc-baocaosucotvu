import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import '../../constants/api_constants.dart';
import '../../models/incident_model.dart';
import '../../services/api_service.dart';
import '../../widgets/status_badge.dart';

class IncidentDetailScreen extends StatefulWidget {
  final int incidentId;

  const IncidentDetailScreen({super.key, required this.incidentId});

  @override
  State<IncidentDetailScreen> createState() => _IncidentDetailScreenState();
}

class _IncidentDetailScreenState extends State<IncidentDetailScreen> {
  IncidentDetailModel? _detail;
  bool _isLoading = true;
  final TextEditingController _feedbackController = TextEditingController();
  double _userRating = 5.0;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() => _isLoading = true);
    final detail = await ApiService.getIncidentDetail(widget.incidentId);
    setState(() {
      _detail = detail;
      _isLoading = false;
    });
  }

  void _showFeedbackDialog() {
    _userRating = 5.0;
    _feedbackController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            const Text(
              'Đánh Giá Kết Quả Xử Lý',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            const Text(
              'Vui lòng đánh giá mức độ hài lòng về chất lượng khắc phục sự cố của đội ngũ kỹ thuật TVU:',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 18),
            RatingBar.builder(
              initialRating: 5,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: false,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(
                Icons.star_rounded,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                _userRating = rating;
              },
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _feedbackController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Nhận xét thêm (VD: Kỹ thuật viên sửa nhanh, bàn giao gọn gàng...)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () async {
                  Navigator.pop(ctx);
                  final success = await ApiService.submitFeedback(
                    widget.incidentId,
                    _userRating.toInt(),
                    _feedbackController.text.trim(),
                  );
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã gửi đánh giá thành công!')),
                    );
                    _fetchDetail();
                  }
                },
                child: const Text('Gửi Đánh Giá & Nghiệm Thu', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_detail == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi Tiết Sự Cố')),
        body: const Center(child: Text('Không tìm thấy thông tin sự cố.')),
      );
    }

    final d = _detail!;
    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(d.createdAt.toLocal());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(d.incidentCode),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchDetail,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StatusBadge(status: d.status, display: _getStatusDisplay(d.status), color: _getStatusColor(d.status)),
                      Text(dateStr, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    d.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    d.description,
                    style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Location & Category Info
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _buildInfoRow(Icons.room, 'Vị trí', '${d.roomNumber} - ${d.buildingName}'),
                  const Divider(height: 16),
                  _buildInfoRow(Icons.domain, 'Khuôn viên', d.campusName),
                  if (d.specificLocation != null && d.specificLocation!.isNotEmpty) ...[
                    const Divider(height: 16),
                    _buildInfoRow(Icons.place, 'Vị trí chi tiết', d.specificLocation!),
                  ],
                  const Divider(height: 16),
                  _buildInfoRow(Icons.category, 'Danh mục', d.categoryName),
                  const Divider(height: 16),
                  _buildInfoRow(
                    Icons.handyman,
                    'Kỹ thuật viên phụ trách',
                    d.assignedToFullName ?? 'Chờ phân công',
                    valueColor: d.assignedToFullName != null ? AppColors.primary : Colors.orange,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Images Gallery
            if (d.images.isNotEmpty) ...[
              const Text('Hình Ảnh Minh Chứng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: d.images.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (_, idx) {
                    final img = d.images[idx];
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        img.fullUrl,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 120,
                          height: 120,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Timeline History
            const Text('Tiến Trình Xử Lý (Timeline)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: d.histories.length,
                itemBuilder: (_, idx) {
                  final h = d.histories[idx];
                  final hDate = DateFormat('dd/MM HH:mm').format(h.createdAt.toLocal());
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: idx == 0 ? AppColors.primary : Colors.grey.shade400,
                              shape: BoxShape.circle,
                            ),
                          ),
                          if (idx < d.histories.length - 1)
                            Container(width: 2, height: 40, color: Colors.grey.shade300),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              h.actionNote,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: idx == 0 ? FontWeight.bold : FontWeight.normal,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$hDate - Bởi ${h.updatedByFullName}',
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 14),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Rating / Feedback Section
            if (d.status == 'Resolved' && d.rating == null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.verified, color: Colors.green, size: 36),
                    const SizedBox(height: 8),
                    const Text(
                      'Sự cố đã được khắc phục!',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Vui lòng đánh giá nghiệm thu để hệ thống hoàn tất đóng hồ sơ sự cố.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.star),
                      label: const Text('Đánh Giá & Nghiệm Thu'),
                      onPressed: _showFeedbackDialog,
                    ),
                  ],
                ),
              ),

            if (d.rating != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ...List.generate(5, (index) => Icon(
                          index < d.rating! ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 20,
                        )),
                        const SizedBox(width: 8),
                        Text('(${d.rating}/5 sao)', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    if (d.feedbackComment != null && d.feedbackComment!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text('Nhận xét: "${d.feedbackComment}"', style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 13)),
                    ],
                  ],
                ),
              ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const Spacer(),
        Text(
          value,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: valueColor ?? AppColors.textPrimary),
        ),
      ],
    );
  }

  String _getStatusDisplay(String status) {
    switch (status) {
      case 'Pending': return 'Chờ tiếp nhận';
      case 'Assigned': return 'Đã phân công';
      case 'InProgress': return 'Đang xử lý';
      case 'Resolved': return 'Đã khắc phục';
      case 'Closed': return 'Đã hoàn thành';
      case 'Rejected': return 'Từ chối';
      default: return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending': return AppColors.pending;
      case 'Assigned': return AppColors.assigned;
      case 'InProgress': return AppColors.inProgress;
      case 'Resolved': return AppColors.resolved;
      case 'Closed': return AppColors.closed;
      case 'Rejected': return AppColors.rejected;
      default: return Colors.grey;
    }
  }
}
