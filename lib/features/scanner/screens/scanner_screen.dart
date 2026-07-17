import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/api_service.dart';
import 'package:flutter/services.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
  );
  final ApiService _apiService = ApiService();

  bool _isScanned = false;
  String? _trackingBarcode;
  DateTime? _trackingStartTime;

  void _onDetect(BarcodeCapture capture) async {
    if (_isScanned) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) {
      _trackingBarcode = null;
      _trackingStartTime = null;
      return;
    }

    final barcode = barcodes.first;
    if (barcode.rawValue == null) return;
    
    final rawValue = barcode.rawValue!;
    
    if (_trackingBarcode != rawValue) {
      _trackingBarcode = rawValue;
      _trackingStartTime = DateTime.now();
      return;
    }
    
    if (DateTime.now().difference(_trackingStartTime!).inSeconds >= 2) {
      setState(() => _isScanned = true);
      HapticFeedback.heavyImpact();
      
      final qrCode = rawValue;
        
        // Backendga so'rov yuborish
        final token = await _apiService.getToken();
        Map<String, dynamic> response;
        if (token != null) {
          response = await _apiService.activateQR(qrCode);
        } else {
          response = await _apiService.checkPublicQR(qrCode);
        }
        
        if (!mounted) return;
        
        if (response['success']) {
          if (token != null) {
            final points = response['data']['pointsEarned'] ?? 0;
            final message = response['data']['message'] ?? 'QR kod muvaffaqiyatli faollashtirildi!';
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$message (+$points ball)'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
          } else {
            // Unregistered user scanning
            final data = response['data'];
            final productName = data['name'] ?? 'Mahsulot';
            final desc = data['description'] ?? '';
            final points = data['bonusPoints'] ?? 0;
            
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text("QR Kod ma'lumoti", style: TextStyle(fontWeight: FontWeight.bold)),
                content: Text("Mahsulot: $productName\nTa'rif: $desc\nBonus: +$points ball\n\nUshbu ballarni hisobingizga qo'shish uchun tizimga kiring!"),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Yopish")),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pop(context); // Go back to LoginScreen
                    }, 
                    child: const Text("Tizimga kirish")
                  ),
                ]
              )
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Xatolik yuz berdi'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }

        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _isScanned = false;
              _trackingBarcode = null;
              _trackingStartTime = null;
            });
          }
        });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: localeNotifier,
      builder: (context, locale, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('scanner'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
            actions: [
          IconButton(
            icon: const Icon(Icons.flash_on, color: Colors.yellow),
            onPressed: () => controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: () => controller.switchCamera(),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final scanWindowSize = MediaQuery.of(context).size.width * 0.7;
          final scanWindow = Rect.fromCenter(
            center: Offset(constraints.maxWidth / 2, constraints.maxHeight / 2),
            width: scanWindowSize,
            height: scanWindowSize,
          );

          return Stack(
            children: [
              MobileScanner(
                controller: controller,
                scanWindow: scanWindow,
                onDetect: _onDetect,
              ),
              Container(
                decoration: ShapeDecoration(
                  shape: QrScannerOverlayShape(
                    borderColor: Theme.of(context).colorScheme.primary,
                    borderRadius: 12,
                    borderLength: 40,
                    borderWidth: 8,
                    cutOutSize: scanWindowSize,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
      },
    );
  }
}

class QrScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  const QrScannerOverlayShape({
    this.borderColor = Colors.red,
    this.borderWidth = 3.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 150),
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
  });

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path getLeftTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.top)
        ..lineTo(rect.right, rect.top);
    }
    return getLeftTopPath(rect)
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..lineTo(rect.left, rect.top);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final borderWidthSize = width / 2;
    final height = rect.height;
    final borderOffset = borderWidth / 2;
    final bLength = borderLength > cutOutSize / 2 + borderWidthSize ? cutOutSize / 2 + borderOffset : borderLength;
    final cSize = cutOutSize;

    final backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final boxPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOut;

    final cutOutRect = Rect.fromLTWH(
      rect.left + width / 2 - cSize / 2 + borderOffset,
      rect.top + height / 2 - cSize / 2 + borderOffset,
      cSize - borderOffset * 2,
      cSize - borderOffset * 2,
    );

    canvas
      ..saveLayer(rect, backgroundPaint)
      ..drawRect(rect, backgroundPaint)
      ..drawRRect(
        RRect.fromRectAndRadius(cutOutRect, Radius.circular(borderRadius)),
        boxPaint,
      )
      ..restore();

    canvas.drawPath(
      Path()
        ..moveTo(cutOutRect.left, cutOutRect.top + bLength)
        ..lineTo(cutOutRect.left, cutOutRect.top + borderRadius)
        ..arcToPoint(
          Offset(cutOutRect.left + borderRadius, cutOutRect.top),
          radius: Radius.circular(borderRadius),
        )
        ..lineTo(cutOutRect.left + bLength, cutOutRect.top)
        ..moveTo(cutOutRect.right - bLength, cutOutRect.top)
        ..lineTo(cutOutRect.right - borderRadius, cutOutRect.top)
        ..arcToPoint(
          Offset(cutOutRect.right, cutOutRect.top + borderRadius),
          radius: Radius.circular(borderRadius),
        )
        ..lineTo(cutOutRect.right, cutOutRect.top + bLength)
        ..moveTo(cutOutRect.right, cutOutRect.bottom - bLength)
        ..lineTo(cutOutRect.right, cutOutRect.bottom - borderRadius)
        ..arcToPoint(
          Offset(cutOutRect.right - borderRadius, cutOutRect.bottom),
          radius: Radius.circular(borderRadius),
        )
        ..lineTo(cutOutRect.right - bLength, cutOutRect.bottom)
        ..moveTo(cutOutRect.left + bLength, cutOutRect.bottom)
        ..lineTo(cutOutRect.left + borderRadius, cutOutRect.bottom)
        ..arcToPoint(
          Offset(cutOutRect.left, cutOutRect.bottom - borderRadius),
          radius: Radius.circular(borderRadius),
        )
        ..lineTo(cutOutRect.left, cutOutRect.bottom - bLength),
      borderPaint,
    );
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth * t,
      overlayColor: overlayColor,
      borderRadius: borderRadius * t,
      borderLength: borderLength * t,
      cutOutSize: cutOutSize * t,
    );
  }
}
