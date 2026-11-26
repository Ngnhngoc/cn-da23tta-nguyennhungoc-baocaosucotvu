import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerModal extends StatefulWidget {
  final Function(String code) onScanned;
  final List<dynamic>? availableRooms;

  const QrScannerModal({
    super.key,
    required this.onScanned,
    this.availableRooms,
  });

  /// Hàm tiện ích mở Scanner dưới dạng Dialog đẹp mắt
  static Future<void> show({
    required BuildContext context,
    required Function(String code) onScanned,
    List<dynamic>? availableRooms,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => QrScannerModal(
        onScanned: onScanned,
        availableRooms: availableRooms,
      ),
    );
  }

  @override
  State<QrScannerModal> createState() => _QrScannerModalState();
}

class _QrScannerModalState extends State<QrScannerModal>
    with SingleTickerProviderStateMixin {
  late final MobileScannerController _scannerController;
  late final AnimationController _animController;
  late final Animation<double> _scanLineAnimation;

  final TextEditingController _quickInputCtrl = TextEditingController();
  bool _hasDetected = false;
  bool _torchEnabled = false;

  @override
  void initState() {
    super.initState();

    // Khởi tạo camera - webcam trước trên Web, camera sau trên Android/LDPlayer
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: kIsWeb ? CameraFacing.front : CameraFacing.back,
      returnImage: false,
    );

    // Hiệu ứng tia laser quét lên xuống
    _animController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _scanLineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _scannerController.dispose();
    _quickInputCtrl.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasDetected) return;

    for (final barcode in capture.barcodes) {
      final code = barcode.rawValue?.trim();
      if (code != null && code.isNotEmpty) {
        _hasDetected = true;
        Navigator.of(context).pop();
        widget.onScanned(code);
        break;
      }
    }
  }

  void _selectCode(String code) {
    if (_hasDetected) return;
    _hasDetected = true;
    Navigator.of(context).pop();
    widget.onScanned(code.trim());
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth > 500 ? 460.0 : screenWidth * 0.92;
    const boxSize = 220.0;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: Colors.white,
      child: SizedBox(
        width: dialogWidth,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. THANH TIÊU ĐỀ
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: const BoxDecoration(
                  color: Color(0xFF0D47A1),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'QUÉT MÃ QR PHÒNG HỌC',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            'Đưa camera vào mã QR dán tại phòng học',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 22),
                      tooltip: 'Đóng',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              // 2. KHUNG CAMERA SCANNER CÓ KHUNG NGẮM & TIA LASER
              Container(
                color: Colors.black,
                height: 280,
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Camera stream
                    MobileScanner(
                      controller: _scannerController,
                      onDetect: _onDetect,
                      errorBuilder: (context, error, child) {
                        return Container(
                          color: const Color(0xFF1E293B),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.videocam_off_outlined,
                                color: Colors.amber,
                                size: 40,
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Không thể kết nối Camera / Webcam',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Vui lòng kiểm tra quyền truy cập máy ảnh của trình duyệt hoặc sử dụng các nút chọn phòng nhanh bên dưới.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    // Lớp phủ tối xung quanh khung quét (Overlay)
                    IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                        ),
                      ),
                    ),

                    // Khung ngắm quét mã (Viewfinder Box)
                    SizedBox(
                      width: boxSize,
                      height: boxSize,
                      child: Stack(
                        children: [
                          // 4 Góc bo viền xanh lá / cyan phong cách scanner
                          Positioned(
                            top: 0,
                            left: 0,
                            child: _buildCorner(isTop: true, isLeft: true),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: _buildCorner(isTop: true, isLeft: false),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            child: _buildCorner(isTop: false, isLeft: true),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: _buildCorner(isTop: false, isLeft: false),
                          ),

                          // Tia laser quét chuyển động lên xuống
                          AnimatedBuilder(
                            animation: _scanLineAnimation,
                            builder: (context, child) {
                              return Positioned(
                                top: _scanLineAnimation.value * (boxSize - 4),
                                left: 8,
                                right: 8,
                                child: Container(
                                  height: 3,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        Color(0xFF00E5FF),
                                        Colors.white,
                                        Color(0xFF00E5FF),
                                        Colors.transparent,
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF00E5FF).withValues(alpha: 0.8),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    // Nút điều khiển camera: Đổi camera & Bật/Tắt flash
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: IconButton(
                              icon: Icon(
                                _torchEnabled ? Icons.flash_on : Icons.flash_off,
                                color: _torchEnabled ? Colors.amber : Colors.white,
                                size: 20,
                              ),
                              tooltip: 'Bật/Tắt đèn Flash',
                              onPressed: () async {
                                await _scannerController.toggleTorch();
                                setState(() {
                                  _torchEnabled = !_torchEnabled;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.flip_camera_ios,
                                color: Colors.white,
                                size: 20,
                              ),
                              tooltip: 'Đổi Camera (Trước / Sau / Webcam)',
                              onPressed: () => _scannerController.switchCamera(),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Gợi ý bên dưới khung quét
                    Positioned(
                      bottom: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.center_focus_strong, color: Color(0xFF00E5FF), size: 14),
                            SizedBox(width: 4),
                            Text(
                              'Căn chỉnh mã QR vào giữa khung',
                              style: TextStyle(color: Colors.white, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 3. KHU VỰC CHỌN NHANH & NHẬP TAY (HỖ TRỢ THỬ NGHIỆM)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Danh sách mã phòng mẫu TVU để test nhanh
                    if (widget.availableRooms != null &&
                        widget.availableRooms!.isNotEmpty) ...[
                      const Row(
                        children: [
                          Icon(Icons.touch_app, size: 15, color: Color(0xFF0D47A1)),
                          SizedBox(width: 4),
                          Text(
                            'Hoặc bấm chọn nhanh phòng học mẫu TVU:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0D47A1),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: widget.availableRooms!
                            .where((r) => r['dang_su_dung'] != 0 && r['dang_su_dung'] != false)
                            .take(6)
                            .map((r) {
                          final qr = r['ma_qr_dinh_danh'] ?? 'TVU-${r['so_phong']}';
                          final shortName = r['so_phong_day_du'] ??
                              (r['so_phong'] != null ? 'B21.${r['so_phong']}' : qr);
                          return ActionChip(
                            avatar: const Icon(Icons.qr_code, size: 15, color: Color(0xFF0D47A1)),
                            label: Text(
                              shortName,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0D47A1),
                              ),
                            ),
                            backgroundColor: Colors.blue.shade50,
                            side: BorderSide(color: Colors.blue.shade200),
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                            onPressed: () => _selectCode(qr),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Ô nhập tay số phòng nếu quét không tiện
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _quickInputCtrl,
                            decoration: InputDecoration(
                              labelText: 'Gõ số phòng (VD: B21.101)',
                              hintText: 'B21.101 hoặc TVU-B21-101',
                              prefixIcon: const Icon(Icons.meeting_room, size: 18),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            ),
                            onSubmitted: (val) {
                              if (val.trim().isNotEmpty) _selectCode(val.trim());
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D47A1),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.check, size: 16),
                          label: const Text('Chọn', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                          onPressed: () {
                            final val = _quickInputCtrl.text.trim();
                            if (val.isNotEmpty) _selectCode(val);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Vẽ 4 góc khung ngắm quét mã
  Widget _buildCorner({required bool isTop, required bool isLeft}) {
    const size = 26.0;
    const thickness = 4.0;
    const color = Color(0xFF00E5FF);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: Border(
          top: isTop ? const BorderSide(color: color, width: thickness) : BorderSide.none,
          bottom: !isTop ? const BorderSide(color: color, width: thickness) : BorderSide.none,
          left: isLeft ? const BorderSide(color: color, width: thickness) : BorderSide.none,
          right: !isLeft ? const BorderSide(color: color, width: thickness) : BorderSide.none,
        ),
      ),
    );
  }
}
