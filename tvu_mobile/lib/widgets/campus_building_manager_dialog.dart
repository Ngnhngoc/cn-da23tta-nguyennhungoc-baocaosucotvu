import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CampusBuildingManagerDialog extends StatefulWidget {
  final VoidCallback onChanged;

  const CampusBuildingManagerDialog({super.key, required this.onChanged});

  @override
  State<CampusBuildingManagerDialog> createState() => _CampusBuildingManagerDialogState();
}

class _CampusBuildingManagerDialogState extends State<CampusBuildingManagerDialog> with SingleTickerProviderStateMixin {
  final ApiService _api = ApiService();
  late TabController _tabController;
  bool _isLoading = true;
  List<dynamic> _campuses = [];
  List<dynamic> _buildings = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final res = await Future.wait([_api.getCampuses(), _api.getBuildings()]);
    if (!mounted) return;
    setState(() {
      _campuses = res[0];
      _buildings = res[1];
      _isLoading = false;
    });
  }

  void _showCampusForm({Map<String, dynamic>? campus}) {
    final isEdit = campus != null;
    final nameCtrl = TextEditingController(text: campus?['ten_khuon_vien'] ?? '');
    final codeCtrl = TextEditingController(text: campus?['ma_viet_tat'] ?? '');
    final addrCtrl = TextEditingController(text: campus?['dia_chi'] ?? 'Đại học Trà Vinh');
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Text(isEdit ? 'Sửa Thông Tin Khu' : 'Thêm Khuôn Viên Mới',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 380,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Tên khuôn viên *', border: OutlineInputBorder(), isDense: true),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: codeCtrl,
                  decoration: const InputDecoration(labelText: 'Mã viết tắt (VD: Khu I, Khu II) *', border: OutlineInputBorder(), isDense: true),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: addrCtrl,
                  decoration: const InputDecoration(labelText: 'Địa chỉ', border: OutlineInputBorder(), isDense: true),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: isSaving
                  ? null
                  : () async {
                      if (nameCtrl.text.trim().isEmpty || codeCtrl.text.trim().isEmpty) return;
                      setModalState(() => isSaving = true);
                      final res = isEdit
                          ? await _api.updateCampus(campus['ma_khuon_vien'], {
                              'ten_khuon_vien': nameCtrl.text.trim(),
                              'ma_viet_tat': codeCtrl.text.trim(),
                              'dia_chi': addrCtrl.text.trim(),
                            })
                          : await _api.addCampus(
                              name: nameCtrl.text.trim(),
                              shortCode: codeCtrl.text.trim(),
                              address: addrCtrl.text.trim(),
                            );
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      if (res['status'] == 'success') {
                        await _loadData();
                        widget.onChanged();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(res['message'] ?? 'Thành công!'), backgroundColor: Colors.green),
                          );
                        }
                      } else if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(res['message'] ?? 'Có lỗi xảy ra'), backgroundColor: Colors.red),
                        );
                      }
                    },
              child: Text(isSaving ? 'Đang lưu...' : (isEdit ? 'Lưu Thay Đổi' : 'Thêm Khu')),
            ),
          ],
        ),
      ),
    );
  }

  void _showBuildingForm({Map<String, dynamic>? building}) {
    if (_campuses.isEmpty) return;
    final isEdit = building != null;
    int selectedCampusId = building?['ma_khuon_vien'] ?? _campuses.first['ma_khuon_vien'];
    final codeCtrl = TextEditingController(text: building?['ma_toa'] ?? '');
    final nameCtrl = TextEditingController(text: building?['ten_day_nha'] ?? '');
    final floorsCtrl = TextEditingController(text: (building?['tong_so_tang'] ?? 4).toString());
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Text(isEdit ? 'Sửa Thông Tin Tòa Nhà' : 'Thêm Tòa Nhà Mới',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 380,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  value: _campuses.any((c) => c['ma_khuon_vien'] == selectedCampusId) ? selectedCampusId : _campuses.first['ma_khuon_vien'],
                  decoration: const InputDecoration(labelText: 'Thuộc Khu *', border: OutlineInputBorder(), isDense: true),
                  items: _campuses
                      .map<DropdownMenuItem<int>>((c) => DropdownMenuItem<int>(
                            value: c['ma_khuon_vien'],
                            child: Text('${c['ten_khuon_vien']} (${c['ma_viet_tat']})'),
                          ))
                      .toList(),
                  onChanged: (v) => setModalState(() => selectedCampusId = v ?? selectedCampusId),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: codeCtrl,
                  decoration: const InputDecoration(labelText: 'Mã tòa (VD: B21, A24) *', border: OutlineInputBorder(), isDense: true),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Tên tòa nhà', border: OutlineInputBorder(), isDense: true),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: floorsCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Tổng số tầng', border: OutlineInputBorder(), isDense: true),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: isSaving
                  ? null
                  : () async {
                      if (codeCtrl.text.trim().isEmpty) return;
                      setModalState(() => isSaving = true);
                      final res = isEdit
                          ? await _api.updateBuilding(building['ma_day_nha'], {
                              'ma_khuon_vien': selectedCampusId,
                              'ma_toa': codeCtrl.text.trim(),
                              'ten_day_nha': nameCtrl.text.trim(),
                              'tong_so_tang': int.tryParse(floorsCtrl.text.trim()) ?? 4,
                            })
                          : await _api.addBuilding(
                              campusId: selectedCampusId,
                              buildingCode: codeCtrl.text.trim(),
                              buildingName: nameCtrl.text.trim(),
                              floorCount: int.tryParse(floorsCtrl.text.trim()) ?? 4,
                            );
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      if (res['status'] == 'success') {
                        await _loadData();
                        widget.onChanged();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(res['message'] ?? 'Thành công!'), backgroundColor: Colors.green),
                          );
                        }
                      } else if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(res['message'] ?? 'Có lỗi xảy ra'), backgroundColor: Colors.red),
                        );
                      }
                    },
              child: Text(isSaving ? 'Đang lưu...' : (isEdit ? 'Lưu Thay Đổi' : 'Thêm Tòa')),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: SizedBox(
        width: 680,
        height: 560,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF0D47A1),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_city, color: Colors.white),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text('Quản Lý Khuôn Viên & Tòa Nhà (Thêm / Sửa / Ẩn / Xóa)',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                  IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
            TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF0D47A1),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF0D47A1),
              tabs: [
                Tab(text: 'Khuôn viên (${_campuses.length})'),
                Tab(text: 'Tòa nhà (${_buildings.length})'),
              ],
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildCampusTab(),
                        _buildBuildingTab(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampusTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: () => _showCampusForm(),
                icon: const Icon(Icons.add, size: 17),
                label: const Text('Thêm Khu Mới'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: _campuses.length,
            itemBuilder: (ctx, i) {
              final c = _campuses[i] as Map<String, dynamic>;
              final isActive = c['dang_su_dung'] == null || c['dang_su_dung'] == 1 || c['dang_su_dung'] == true;
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isActive ? Colors.indigo.shade50 : Colors.grey.shade200,
                    child: Icon(Icons.apartment, color: isActive ? Colors.indigo : Colors.grey),
                  ),
                  title: Row(
                    children: [
                      Expanded(child: Text('${c['ten_khuon_vien']} (${c['ma_viet_tat']})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isActive ? Colors.green.shade50 : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(isActive ? 'Đang hoạt động' : 'Đã ẩn',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isActive ? Colors.green.shade700 : Colors.red.shade700)),
                      ),
                    ],
                  ),
                  subtitle: Text(c['dia_chi'] ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(isActive ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.orange),
                        tooltip: isActive ? 'Ẩn khu này' : 'Hiện khu này',
                        onPressed: () async {
                          final res = await _api.toggleCampusStatus(c['ma_khuon_vien']);
                          if (res['status'] == 'success') {
                            await _loadData();
                            widget.onChanged();
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                        tooltip: 'Sửa khu',
                        onPressed: () => _showCampusForm(campus: c),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        tooltip: 'Xóa khu',
                        onPressed: () async {
                          final res = await _api.deleteCampus(c['ma_khuon_vien']);
                          if (!mounted) return;
                          if (res['status'] == 'success') {
                            await _loadData();
                            widget.onChanged();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Đã xóa'), backgroundColor: Colors.green));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Không thể xóa'), backgroundColor: Colors.red));
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBuildingTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: () => _showBuildingForm(),
                icon: const Icon(Icons.add, size: 17),
                label: const Text('Thêm Tòa Mới'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: _buildings.length,
            itemBuilder: (ctx, i) {
              final b = _buildings[i] as Map<String, dynamic>;
              final isActive = b['dang_su_dung'] == null || b['dang_su_dung'] == 1 || b['dang_su_dung'] == true;
              final kv = b['khuon_vien'] ?? b['khuonVien'];
              final campusLabel = kv is Map ? (kv['ma_viet_tat'] ?? kv['ten_khuon_vien'] ?? '') : '';
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isActive ? Colors.blue.shade50 : Colors.grey.shade200,
                    child: Icon(Icons.domain, color: isActive ? Colors.blue.shade700 : Colors.grey),
                  ),
                  title: Row(
                    children: [
                      Expanded(child: Text('${b['ten_day_nha']} (${b['ma_toa']})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isActive ? Colors.green.shade50 : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(isActive ? 'Đang hoạt động' : 'Đã ẩn',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isActive ? Colors.green.shade700 : Colors.red.shade700)),
                      ),
                    ],
                  ),
                  subtitle: Text('Thuộc: $campusLabel • ${b['tong_so_tang'] ?? 4} tầng'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(isActive ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.orange),
                        tooltip: isActive ? 'Ẩn tòa này' : 'Hiện tòa này',
                        onPressed: () async {
                          final res = await _api.toggleBuildingStatus(b['ma_day_nha']);
                          if (res['status'] == 'success') {
                            await _loadData();
                            widget.onChanged();
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                        tooltip: 'Sửa tòa',
                        onPressed: () => _showBuildingForm(building: b),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        tooltip: 'Xóa tòa',
                        onPressed: () async {
                          final res = await _api.deleteBuilding(b['ma_day_nha']);
                          if (!mounted) return;
                          if (res['status'] == 'success') {
                            await _loadData();
                            widget.onChanged();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Đã xóa'), backgroundColor: Colors.green));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Không thể xóa'), backgroundColor: Colors.red));
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
