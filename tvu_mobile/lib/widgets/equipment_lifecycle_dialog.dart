import 'package:flutter/material.dart';
import '../services/api_service.dart';

class EquipmentLifecycleDialog extends StatefulWidget {
  final int roomId;
  final String roomName;
  final bool canEdit;

  const EquipmentLifecycleDialog({
    super.key,
    required this.roomId,
    required this.roomName,
    this.canEdit = true,
  });

  @override
  State<EquipmentLifecycleDialog> createState() => _EquipmentLifecycleDialogState();
}

class _EquipmentLifecycleDialogState extends State<EquipmentLifecycleDialog> with SingleTickerProviderStateMixin {
  final ApiService _api = ApiService();
  late TabController _tabController;
  bool _isLoading = true;
  List<dynamic> _equipments = [];
  List<dynamic> _incidents = [];

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
    final res = await _api.getRoomEquipments(widget.roomId);
    if (!mounted) return;
    setState(() {
      if (res['status'] == 'success' && res['data'] is Map) {
        _equipments = res['data']['equipments'] ?? [];
        _incidents = res['data']['incidents'] ?? [];
      }
      _isLoading = false;
    });
  }

  void _showAddEquipmentDialog() {
    final nameCtrl = TextEditingController();
    final codeCtrl = TextEditingController();
    final cycleCtrl = TextEditingController(text: '6');
    String selectedType = 'Máy lạnh';
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text('Thêm Thiết Bị Mới', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 380,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Tên thiết bị *', border: OutlineInputBorder(), isDense: true),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Loại thiết bị', border: OutlineInputBorder(), isDense: true),
                  items: ['Máy lạnh', 'Quạt', 'TV/Máy chiếu', 'Máy tính', 'Bảng', 'Khác']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setModalState(() => selectedType = v ?? 'Máy lạnh'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: codeCtrl,
                  decoration: const InputDecoration(labelText: 'Mã tài sản (tùy chọn)', border: OutlineInputBorder(), isDense: true),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: cycleCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Chu kỳ bảo trì định kỳ (tháng)', border: OutlineInputBorder(), isDense: true),
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
                      if (nameCtrl.text.trim().isEmpty) return;
                      setModalState(() => isSaving = true);
                      final res = await _api.addEquipment({
                        'ma_phong_hoc': widget.roomId,
                        'ten_thiet_bi': nameCtrl.text.trim(),
                        'loai_thiet_bi': selectedType,
                        'ma_tai_san': codeCtrl.text.trim().isNotEmpty ? codeCtrl.text.trim() : null,
                        'chu_ky_bao_tri_thang': int.tryParse(cycleCtrl.text.trim()) ?? 6,
                      });
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      if (res['status'] == 'success') {
                        _loadData();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã thêm thiết bị mới!'), backgroundColor: Colors.green),
                        );
                      }
                    },
              child: Text(isSaving ? 'Đang lưu...' : 'Thêm Thiết Bị'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMaintenanceDialog(Map<String, dynamic> eq) {
    final contentCtrl = TextEditingController();
    final costCtrl = TextEditingController(text: '0');
    String selectedActivity = 'Bảo trì định kỳ';
    String selectedStatus = 'Hoạt động tốt';
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Text('Ghi Nhận: ${eq['ten_thiet_bi']}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedActivity,
                    decoration: const InputDecoration(labelText: 'Loại hoạt động', border: OutlineInputBorder(), isDense: true),
                    items: ['Bảo trì định kỳ', 'Sửa chữa sự cố', 'Thay thế linh kiện', 'Kiểm tra']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setModalState(() => selectedActivity = v ?? 'Bảo trì định kỳ'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: contentCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Nội dung thực hiện *',
                      hintText: 'VD: Vệ sinh dàn lạnh, bơm gas, thay tụ...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: costCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Chi phí (VNĐ)', border: OutlineInputBorder(), isDense: true),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: const InputDecoration(labelText: 'Trạng thái sau xử lý', border: OutlineInputBorder(), isDense: true),
                    items: ['Hoạt động tốt', 'Cần bảo trì', 'Đang sửa chữa', 'Hỏng']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setModalState(() => selectedStatus = v ?? 'Hoạt động tốt'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
              onPressed: isSaving
                  ? null
                  : () async {
                      if (contentCtrl.text.trim().isEmpty) return;
                      setModalState(() => isSaving = true);
                      final res = await _api.addEquipmentMaintenance(eq['ma_thiet_bi'], {
                        'loai_hoat_dong': selectedActivity,
                        'noi_dung': contentCtrl.text.trim(),
                        'chi_phi': double.tryParse(costCtrl.text.trim()) ?? 0,
                        'trang_thai_moi': selectedStatus,
                        'ket_qua': selectedStatus,
                      });
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      if (res['status'] == 'success') {
                        _loadData();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã ghi nhận bảo trì/sửa chữa!'), backgroundColor: Colors.green),
                        );
                      }
                    },
              child: Text(isSaving ? 'Đang lưu...' : 'Lưu Lịch Sử'),
            ),
          ],
        ),
      ),
    );
  }

  Color _dueColor(String dueStatus) {
    if (dueStatus == 'Quá hạn') return Colors.red;
    if (dueStatus == 'Sắp đến hạn') return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: SizedBox(
        width: 720,
        height: 600,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF0D47A1),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.precision_manufacturing, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Vòng Đời & Bảo Trì Thiết Bị - ${widget.roomName}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15.5)),
                        const Text('Theo dõi tuổi thọ, lịch sử sửa chữa & bảo trì định kỳ',
                            style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                  if (widget.canEdit)
                    TextButton.icon(
                      style: TextButton.styleFrom(foregroundColor: Colors.white),
                      onPressed: _showAddEquipmentDialog,
                      icon: const Icon(Icons.add_circle_outline, size: 18),
                      label: const Text('Thêm TB', style: TextStyle(fontSize: 12.5)),
                    ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // TabBar
            TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF0D47A1),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF0D47A1),
              tabs: [
                Tab(text: 'Thiết bị & Bảo trì (${_equipments.length})'),
                Tab(text: 'Lịch sử Sự cố phòng (${_incidents.length})'),
              ],
            ),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildEquipmentListTab(),
                        _buildIncidentHistoryTab(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEquipmentListTab() {
    if (_equipments.isEmpty) {
      return const Center(child: Text('Chưa có thiết bị nào được ghi nhận vòng đời trong phòng này.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: _equipments.length,
      itemBuilder: (ctx, i) {
        final eq = _equipments[i] as Map<String, dynamic>;
        final dueStatus = (eq['tinh_trang_bao_tri'] ?? 'Bình thường').toString();
        final dueCol = _dueColor(dueStatus);
        final history = (eq['lich_su'] as List<dynamic>?) ?? [];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: dueStatus == 'Quá hạn' ? Colors.red.shade200 : Colors.grey.shade200),
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            leading: CircleAvatar(
              backgroundColor: dueCol.withValues(alpha: 0.12),
              child: Icon(Icons.build_circle_outlined, color: dueCol),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(eq['ten_thiet_bi'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: dueCol.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    dueStatus == 'Bình thường' ? (eq['trang_thai'] ?? 'Hoạt động tốt') : 'Bảo trì: $dueStatus',
                    style: TextStyle(color: dueCol, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Wrap(
                spacing: 12,
                runSpacing: 4,
                children: [
                  Text('🏷️ Mã: ${eq['ma_tai_san'] ?? 'N/A'}', style: const TextStyle(fontSize: 12)),
                  Text('⏳ Tuổi thọ: ${eq['tuoi_tho_thang'] ?? 0} tháng', style: const TextStyle(fontSize: 12)),
                  Text('🔧 Sửa chữa: ${eq['so_lan_sua_chua'] ?? 0} lần', style: const TextStyle(fontSize: 12)),
                  Text('📅 Bảo trì tiếp theo: ${eq['ngay_bao_tri_tiep_theo'] ?? 'Chưa đặt'}',
                      style: TextStyle(fontSize: 12, color: dueCol, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Lắp đặt: ${eq['ngay_lap_dat'] ?? 'N/A'} • Bảo hành đến: ${eq['han_bao_hanh'] ?? 'N/A'}',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                        ),
                        if (widget.canEdit)
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              visualDensity: VisualDensity.compact,
                            ),
                            onPressed: () => _showAddMaintenanceDialog(eq),
                            icon: const Icon(Icons.add_task, size: 15),
                            label: const Text('Ghi nhận Bảo trì / Sửa chữa', style: TextStyle(fontSize: 11.5)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text('📜 Timeline Vòng đời & Lịch sử Bảo trì:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    if (history.isEmpty)
                      const Text('Chưa có lịch sử bảo trì.', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic))
                    else
                      ...history.map((h) {
                        final act = (h['loai_hoat_dong'] ?? '').toString();
                        final isRepair = act.contains('Sửa') || act.contains('Thay');
                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isRepair ? Colors.orange.shade50 : Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isRepair ? Colors.orange.shade200 : Colors.blue.shade100),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(act, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: isRepair ? Colors.deepOrange : const Color(0xFF0D47A1))),
                                  Text((h['ngay_thuc_hien'] ?? '').toString(), style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(h['noi_dung'] ?? '', style: const TextStyle(fontSize: 12.5)),
                              const SizedBox(height: 3),
                              Text('Thực hiện: ${h['nguoi_thuc_hien'] ?? 'KTV'} • Kết quả: ${h['ket_qua'] ?? ''}',
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIncidentHistoryTab() {
    if (_incidents.isEmpty) {
      return const Center(child: Text('Phòng này chưa có sự cố nào được báo cáo.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: _incidents.length,
      itemBuilder: (ctx, i) {
        final inc = _incidents[i] as Map<String, dynamic>;
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.warning_amber_rounded, color: Colors.deepOrange),
            title: Text('${inc['ma_phieu_su_co']} - ${inc['trang_thai']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
            subtitle: Text('${inc['mo_ta_hu_hong']}\nNgày gửi: ${inc['ngay_gui_bao_cao'] ?? ''}'),
            isThreeLine: true,
          ),
        );
      },
    );
  }
}
