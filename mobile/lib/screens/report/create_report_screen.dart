import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../constants/api_constants.dart';
import '../../models/category_model.dart';
import '../../models/room_model.dart';
import '../../services/api_service.dart';
import '../tracking/incident_detail_screen.dart';

class CreateReportScreen extends StatefulWidget {
  final RoomModel? preselectedRoom;

  const CreateReportScreen({super.key, this.preselectedRoom});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationDetailController = TextEditingController();

  RoomModel? _selectedRoom;
  List<RoomModel> _roomsList = [];
  List<CategoryModel> _categories = [];
  int? _selectedCategoryId;
  String _selectedPriority = 'Medium';

  final List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedRoom = widget.preselectedRoom;
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    final categories = await ApiService.getCategories();
    final rooms = await ApiService.getRooms();

    setState(() {
      _categories = categories;
      _roomsList = rooms;
      if (_categories.isNotEmpty) {
        _selectedCategoryId = _categories.first.id;
      }
      if (_selectedRoom == null && _roomsList.isNotEmpty) {
        _selectedRoom = _roomsList.first;
      }
      _isLoading = false;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1200,
      );
      if (picked != null) {
        setState(() {
          _selectedImages.add(picked);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi chọn ảnh: $e')),
      );
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRoom == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn phòng học xảy ra sự cố')),
      );
      return;
    }
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn danh mục sự cố')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // 1. Upload photos first
    List<String> uploadedUrls = [];
    for (final img in _selectedImages) {
      final url = await ApiService.uploadImage(img.path);
      if (url != null) {
        uploadedUrls.add(url);
      }
    }

    // 2. Submit incident
    final result = await ApiService.createIncident(
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      roomId: _selectedRoom!.id,
      categoryId: _selectedCategoryId!,
      priority: _selectedPriority,
      specificLocation: _locationDetailController.text.trim(),
      imageUrls: uploadedUrls,
    );

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (result['success'] == true) {
      final data = result['data'];
      final incidentId = data['id'];
      final incidentCode = data['incidentCode'] ?? '';

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 54),
          title: const Text('Báo Cáo Thành Công!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Mã sự cố: $incidentCode', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              const Text(
                'Thông tin đã được chuyển đến Ban Quản trị CSVC TVU để tiếp nhận và điều phối kỹ thuật viên.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => IncidentDetailScreen(incidentId: incidentId),
                  ),
                );
              },
              child: const Text('Xem Tiến Độ Xử Lý'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Lỗi gửi sự cố')),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationDetailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Báo Cáo Sự Cố CSVC'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Location Banner Card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, color: AppColors.primary, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Vị trí xảy ra sự cố',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _selectedRoom?.fullLocationText ?? 'Chưa chọn phòng',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                ),
                                if (_selectedRoom != null)
                                  Text(
                                    'Mã QR: ${_selectedRoom!.qrCode}',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                  ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: _showChangeRoomDialog,
                            child: const Text('Đổi phòng'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Category Selection
                    const Text(
                      'Loại sự cố (*)',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          value: _selectedCategoryId,
                          items: _categories.map((c) {
                            return DropdownMenuItem<int>(
                              value: c.id,
                              child: Row(
                                children: [
                                  Icon(c.iconData, size: 20, color: AppColors.primary),
                                  const SizedBox(width: 10),
                                  Expanded(child: Text(c.name, style: const TextStyle(fontSize: 14))),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedCategoryId = val),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Priority Selection
                    const Text(
                      'Mức độ ưu tiên / Khẩn cấp',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildPriorityChip('Low', 'Thấp', AppColors.priorityLow),
                        const SizedBox(width: 8),
                        _buildPriorityChip('Medium', 'Trung bình', AppColors.priorityMedium),
                        const SizedBox(width: 8),
                        _buildPriorityChip('High', 'Cao', AppColors.priorityHigh),
                        const SizedBox(width: 8),
                        _buildPriorityChip('Critical', 'Khẩn cấp', AppColors.priorityCritical),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Title
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Tiêu đề sự cố (*)',
                        hintText: 'VD: Máy lạnh không lạnh, Quạt trần kêu to...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập tiêu đề' : null,
                    ),
                    const SizedBox(height: 14),

                    // Specific Location
                    TextFormField(
                      controller: _locationDetailController,
                      decoration: InputDecoration(
                        labelText: 'Vị trí cụ thể trong phòng (nếu có)',
                        hintText: 'VD: Bàn số 5 dãy giữa, góc phải cửa ra vào...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Description
                    TextFormField(
                      controller: _descController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Mô tả chi tiết tình trạng hư hỏng (*)',
                        hintText: 'Mô tả hiện tượng xảy ra, thiết bị lỗi để kỹ thuật viên chuẩn bị phụ tùng thay thế phù hợp...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập mô tả' : null,
                    ),
                    const SizedBox(height: 20),

                    // Photos
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Ảnh chụp hiện trường sự cố',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        Text(
                          '${_selectedImages.length} ảnh đã chọn',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Image selector buttons & thumbnails
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        // Camera Button
                        InkWell(
                          onTap: () => _pickImage(ImageSource.camera),
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.primary, width: 1.5),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.camera_alt, color: AppColors.primary, size: 26),
                                SizedBox(height: 4),
                                Text('Chụp ảnh', style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),

                        // Gallery Button
                        InkWell(
                          onTap: () => _pickImage(ImageSource.gallery),
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.photo_library, color: AppColors.textSecondary, size: 26),
                                SizedBox(height: 4),
                                Text('Thư viện', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                        ),

                        // Preview of selected images
                        ..._selectedImages.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final img = entry.value;
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  File(img.path),
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 2,
                                right: 2,
                                child: GestureDetector(
                                  onTap: () => setState(() => _selectedImages.removeAt(idx)),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(2),
                                    child: const Icon(Icons.close, color: Colors.white, size: 16),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 3,
                        ),
                        icon: _isSubmitting
                            ? const SizedBox.shrink()
                            : const Icon(Icons.send_rounded),
                        label: _isSubmitting
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Gửi Báo Cáo Đến CSVC TVU',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                        onPressed: _isSubmitting ? null : _handleSubmit,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPriorityChip(String key, String label, Color color) {
    final isSelected = _selectedPriority == key;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPriority = key),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSelected ? color : AppColors.border),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  void _showChangeRoomDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Chọn Phòng Học'),
        content: SizedBox(
          width: double.maxFinite,
          height: 350,
          child: ListView.builder(
            itemCount: _roomsList.length,
            itemBuilder: (_, idx) {
              final room = _roomsList[idx];
              return ListTile(
                leading: const Icon(Icons.room, color: AppColors.primary),
                title: Text(room.roomNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${room.buildingName} - ${room.campusName}'),
                onTap: () {
                  setState(() => _selectedRoom = room);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
