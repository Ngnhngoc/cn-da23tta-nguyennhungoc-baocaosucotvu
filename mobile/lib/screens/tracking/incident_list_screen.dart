import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/api_constants.dart';
import '../../models/incident_model.dart';
import '../../services/api_service.dart';
import '../../widgets/status_badge.dart';
import 'incident_detail_screen.dart';

class IncidentListScreen extends StatefulWidget {
  const IncidentListScreen({super.key});

  @override
  State<IncidentListScreen> createState() => _IncidentListScreenState();
}

class _IncidentListScreenState extends State<IncidentListScreen> {
  List<IncidentListItem> _allIncidents = [];
  List<IncidentListItem> _filteredIncidents = [];
  String _selectedFilter = 'ALL';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchIncidents();
  }

  Future<void> _fetchIncidents() async {
    setState(() => _isLoading = true);
    final list = await ApiService.getMyIncidents();
    setState(() {
      _allIncidents = list;
      _applyFilter();
      _isLoading = false;
    });
  }

  void _applyFilter() {
    if (_selectedFilter == 'ALL') {
      _filteredIncidents = _allIncidents;
    } else {
      _filteredIncidents = _allIncidents.where((i) => i.status == _selectedFilter).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Theo Dõi Sự Cố Đã Báo'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _buildFilterChip('ALL', 'Tất cả (${_allIncidents.length})'),
                const SizedBox(width: 8),
                _buildFilterChip('Pending', 'Chờ tiếp nhận'),
                const SizedBox(width: 8),
                _buildFilterChip('InProgress', 'Đang xử lý'),
                const SizedBox(width: 8),
                _buildFilterChip('Resolved', 'Đã khắc phục'),
                const SizedBox(width: 8),
                _buildFilterChip('Closed', 'Đã đóng'),
              ],
            ),
          ),

          // Incident List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredIncidents.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            const Text(
                              'Không có sự cố nào trong mục này',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchIncidents,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: _filteredIncidents.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (_, idx) {
                            final item = _filteredIncidents[idx];
                            final dateStr = DateFormat('dd/MM HH:mm').format(item.createdAt.toLocal());

                            return InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => IncidentDetailScreen(incidentId: item.id),
                                  ),
                                ).then((_) => _fetchIncidents());
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.border),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2)),
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Thumbnail / Icon
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: item.thumbnailUrl != null && item.thumbnailUrl!.isNotEmpty
                                          ? Image.network(
                                              item.fullImageUrl,
                                              width: 60,
                                              height: 60,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => _buildPlaceholderIcon(),
                                            )
                                          : _buildPlaceholderIcon(),
                                    ),
                                    const SizedBox(width: 12),

                                    // Content
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                item.incidentCode,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                              Text(dateStr, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            item.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(Icons.room, size: 14, color: AppColors.textSecondary),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  '${item.roomNumber} - ${item.buildingName}',
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          StatusBadge(
                                            status: item.status,
                                            display: item.statusDisplay,
                                            color: item.statusColor,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderIcon() {
    return Container(
      width: 60,
      height: 60,
      color: AppColors.primaryLight,
      child: const Icon(Icons.build_circle_outlined, color: AppColors.primary, size: 28),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _selectedFilter == key;
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : AppColors.textPrimary)),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: Colors.white,
      onSelected: (val) {
        setState(() {
          _selectedFilter = key;
          _applyFilter();
        });
      },
    );
  }
}
