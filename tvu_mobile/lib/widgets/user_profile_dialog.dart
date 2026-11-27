import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class UserProfileDialog extends StatefulWidget {
  final Map<String, dynamic> user;
  final Function(String newAvatarUrl)? onAvatarUpdated;

  const UserProfileDialog({
    super.key,
    required this.user,
    this.onAvatarUpdated,
  });

  @override
  State<UserProfileDialog> createState() => _UserProfileDialogState();
}

class _UserProfileDialogState extends State<UserProfileDialog> {
  final ApiService _api = ApiService();
  final _oldPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _isUploadingAvatar = false;
  bool _isChangingPass = false;
  bool _obscureOld = true;
  bool _obscureNew = true;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _avatarUrl = widget.user['avatar']?.toString();
  }

  @override
  void dispose() {
    _oldPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80, maxWidth: 800);
    if (picked == null) return;

    setState(() => _isUploadingAvatar = true);
    final res = await _api.updateAvatar(picked);
    if (!mounted) return;
    setState(() => _isUploadingAvatar = false);

    if (res['status'] == 'success') {
      final newUrl = res['avatar']?.toString();
      setState(() => _avatarUrl = newUrl);
      if (newUrl != null) {
        widget.user['avatar'] = newUrl;
        widget.onAvatarUpdated?.call(newUrl);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật ảnh đại diện thành công!'), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? 'Lỗi cập nhật ảnh đại diện'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _handleChangePassword() async {
    final oldPass = _oldPassCtrl.text.trim();
    final newPass = _newPassCtrl.text.trim();
    final confirmPass = _confirmPassCtrl.text.trim();

    if (oldPass.isEmpty || newPass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ mật khẩu cũ và mới!'), backgroundColor: Colors.orange),
      );
      return;
    }
    if (newPass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu mới phải có ít nhất 6 ký tự!'), backgroundColor: Colors.orange),
      );
      return;
    }
    if (newPass != confirmPass) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Xác nhận mật khẩu mới không khớp!'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isChangingPass = true);
    final res = await _api.changePassword(oldPass, newPass);
    if (!mounted) return;
    setState(() => _isChangingPass = false);

    if (res['status'] == 'success') {
      _oldPassCtrl.clear();
      _newPassCtrl.clear();
      _confirmPassCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đổi mật khẩu thành công!'), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? 'Đổi mật khẩu thất bại'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final fullName = (widget.user['ho_va_ten'] ?? 'Người dùng').toString();
    final role = (widget.user['vai_tro'] ?? '').toString();
    final unit = (widget.user['lop_don_vi'] ?? widget.user['lop_hoac_don_vi'] ?? '').toString();
    final initial = fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U';

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const Icon(Icons.account_circle, color: Color(0xFF0D47A1)),
          const SizedBox(width: 8),
          const Expanded(
            child: Text('Hồ Sơ & Bảo Mật Tài Khoản', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar + Nút đổi ảnh
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: const Color(0xFF0D47A1).withValues(alpha: 0.12),
                    backgroundImage: (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                        ? NetworkImage(_avatarUrl!)
                        : null,
                    child: (_avatarUrl == null || _avatarUrl!.isEmpty)
                        ? Text(initial, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)))
                        : null,
                  ),
                  InkWell(
                    onTap: _isUploadingAvatar ? null : _pickAndUploadAvatar,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D47A1),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: _isUploadingAvatar
                          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.camera_alt, size: 15, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(fullName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                child: Text(
                  unit.isNotEmpty ? '$role • $unit' : role,
                  style: TextStyle(fontSize: 12, color: Colors.blue.shade800, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 6),
              TextButton.icon(
                onPressed: _isUploadingAvatar ? null : _pickAndUploadAvatar,
                icon: const Icon(Icons.photo_library_outlined, size: 16),
                label: const Text('Thay ảnh đại diện (Avatar)', style: TextStyle(fontSize: 12.5)),
              ),
              const Divider(height: 20),

              // Phần Đổi mật khẩu
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('🔒 Đổi mật khẩu cá nhân', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _oldPassCtrl,
                obscureText: _obscureOld,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu hiện tại',
                  border: const OutlineInputBorder(),
                  isDense: true,
                  suffixIcon: IconButton(
                    icon: Icon(_obscureOld ? Icons.visibility_off : Icons.visibility, size: 18),
                    onPressed: () => setState(() => _obscureOld = !_obscureOld),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _newPassCtrl,
                obscureText: _obscureNew,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu mới (tối thiểu 6 ký tự)',
                  border: const OutlineInputBorder(),
                  isDense: true,
                  suffixIcon: IconButton(
                    icon: Icon(_obscureNew ? Icons.visibility_off : Icons.visibility, size: 18),
                    onPressed: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _confirmPassCtrl,
                obscureText: _obscureNew,
                decoration: const InputDecoration(
                  labelText: 'Xác nhận mật khẩu mới',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D47A1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                  onPressed: _isChangingPass ? null : _handleChangePassword,
                  icon: _isChangingPass
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.lock_reset, size: 18),
                  label: Text(_isChangingPass ? 'Đang cập nhật...' : 'Lưu Mật Khẩu Mới'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
