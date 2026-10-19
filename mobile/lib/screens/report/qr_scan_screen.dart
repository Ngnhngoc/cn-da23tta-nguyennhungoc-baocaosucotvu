import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../constants/api_constants.dart';
import '../../services/api_service.dart';
import 'create_report_screen.dart';

class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  final MobileScannerController _cameraController = MobileScannerController();
  bool _isProcessing = false;
  final TextEditingController _manualInputController = TextEditingController();

  Future<void> _handleQrDetected(String rawCode) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    final cleanCode = rawCode.trim();

    // Query backend to lookup room by QR
    final room = await ApiService.getRoomByQr(cleanCode);

    if (!mounted) return;

    if (room != null) {
      // Navigate to Create Report Screen with room pre-filled
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => CreateReportScreen(preselectedRoom: room),
        ),
      );
    } else {
      setState(() => _isProcessing = false);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Mã QR Không Hợp Lệ'),
          content: Text('Không tìm thấy thông tin phòng học tương ứng với mã "$cleanCode" tại Đại học Trà Vinh.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }
  }

  void _showManualInputDialog() {
    _manualInputController.text = 'TVU-B1-201'; // Sample QR for testing
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nhập Mã QR Phòng'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dành cho trường hợp camera không quét được hoặc đang chạy trên máy ảo:',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _manualInputController,
              decoration: InputDecoration(
                labelText: 'Mã QR phòng (VD: TVU-B1-201)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              if (_manualInputController.text.isNotEmpty) {
                _handleQrDetected(_manualInputController.text);
              }
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _manualInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Quét Mã QR Phòng Học'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => _cameraController.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () => _cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera Scanner
          MobileScanner(
            controller: _cameraController,
            onDetect: (capture) {
              final barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _handleQrDetected(barcode.rawValue!);
                  break;
                }
              }
            },
          ),

          // Viewfinder Overlay
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.accent, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          // Instructions at bottom
          Positioned(
            left: 20,
            right: 20,
            bottom: 40,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Hướng camera về phía mã QR dán tại cửa phòng hoặc thiết bị để tự động định danh vị trí sự cố',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white70),
                    backgroundColor: Colors.black45,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  icon: const Icon(Icons.keyboard),
                  label: const Text('Nhập mã định danh thủ công'),
                  onPressed: _showManualInputDialog,
                ),
              ],
            ),
          ),

          // Processing Indicator
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.accent),
                    SizedBox(height: 16),
                    Text(
                      'Đang tra cứu thông tin phòng tại TVU...',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
