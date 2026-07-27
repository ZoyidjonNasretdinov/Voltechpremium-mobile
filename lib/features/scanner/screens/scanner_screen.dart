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
  void _onDetect(BarcodeCapture capture) async {
    if (_isScanned) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    if (barcode.rawValue == null) return;
    
    setState(() => _isScanned = true);
    HapticFeedback.heavyImpact();
    
    _processQrCode(barcode.rawValue!);
  }

  Future<void> _processQrCode(String qrCode) async {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: Colors.green),
                  const SizedBox(height: 16),
                  Text('loading'.tr, style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface)),
                ],
              ),
            ),
          ),
        );
        
        // Backendga so'rov yuborish
        final token = await _apiService.getToken();
        Map<String, dynamic> response;
        if (token != null) {
          response = await _apiService.activateQR(qrCode);
        } else {
          response = await _apiService.checkPublicQR(qrCode);
        }
        
        if (!mounted) return;
        Navigator.of(context, rootNavigator: true).pop(); // Yuklanmoqda oynasini yopish
        
        if (!mounted) return;
        
        if (response['success']) {
          if (token != null) {
            num rawPoints = 0;
            if (response['data'] is Map) {
              final d = response['data'] as Map;
              rawPoints = d['pointsEarned'] ?? d['bonusPoints'] ?? d['points'] ?? d['bonus'] ?? d['amount'] ?? d['earnedPoints'] ?? d['reward'] ?? d['ball'] ?? 0;
              if (rawPoints == 0 && d['product'] is Map) {
                rawPoints = d['product']['bonusPoints'] ?? d['product']['points'] ?? d['product']['bonus'] ?? 0;
              }
              if (rawPoints == 0 && d['qrCode'] is Map) {
                rawPoints = d['qrCode']['bonusPoints'] ?? d['qrCode']['points'] ?? d['qrCode']['bonus'] ?? 0;
              }
            } else if (response['data'] is num) {
              rawPoints = response['data'];
            }
            int points = rawPoints.toInt();
            String rawMessage = (response['data'] is Map ? response['data']['message'] : null)?.toString() ?? 'QR kod muvaffaqiyatli faollashtirildi!';
            
            if (points == 0 && rawMessage.isNotEmpty) {
              var match = RegExp(r'(\d+)\s*(?:bonus|ball|point)', caseSensitive: false).firstMatch(rawMessage);
              match ??= RegExp(r'(?:sizga|berildi|qo\x27shildi|taqdim etildi|taqdim etiladi)\s+(\d+)', caseSensitive: false).firstMatch(rawMessage);
              match ??= RegExp(r'(\d+)\s+(?:taqdim|qo\x27shildi|berildi)', caseSensitive: false).firstMatch(rawMessage);
              
              if (match != null) {
                points = int.tryParse(match.group(1) ?? '0') ?? 0;
              } else {
                final matches = RegExp(r'(?<!\S|\d-)\b\d+\b(?!\S|-|\.)').allMatches(rawMessage);
                if (matches.isNotEmpty) {
                  points = int.tryParse(matches.last.group(0) ?? '0') ?? 0;
                }
              }
            }
            
            String displayMessage = rawMessage;
            displayMessage = displayMessage.replaceAll(RegExp(r'^Tabriklaymiz!\s*', caseSensitive: false), '');
            displayMessage = displayMessage.replaceAll(RegExp(r'\s*(?:uchun\s*)?(?:sizga\s*)?\d+\s*(?:bonus|ball|point)\s*(?:taqdim etildi|berildi|qo\x27shildi|taqdim etiladi)?\.?', caseSensitive: false), '');
            displayMessage = displayMessage.replaceAll(RegExp(r'\s*(?:sizga\s*)?\d+\s*(?:bonus|ball|point)\s*(?:taqdim etildi|berildi|qo\x27shildi|taqdim etiladi)?\.?', caseSensitive: false), '');
            
            if (displayMessage.trim().isEmpty) {
              displayMessage = 'product_activated'.tr;
            } else if (!displayMessage.trim().endsWith('.') && !displayMessage.trim().endsWith('!')) {
              displayMessage = "${displayMessage.trim()} ${'for_product_activated'.tr}";
            } else {
              displayMessage = displayMessage.trim();
            }
            
            showDialog(
              context: context,
              builder: (ctx) => Dialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                elevation: 0,
                backgroundColor: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_circle, size: 48, color: Colors.green),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'congratulations'.tr,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        displayMessage,
                        style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8)),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.green.shade500, Colors.lightGreen.shade400],
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ]
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.stars, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              "+$points ${'points'.tr}",
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: Text('great'.tr, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            );
          } else {
            // Unregistered user scanning
            final data = response['data'];
            final productName = data['name'] ?? 'Mahsulot';
            final desc = data['description'] ?? '';
            final points = data['bonusPoints'] ?? 0;
            final scanCount = data['scanCount'] ?? 0;
            
            showDialog(
              context: context,
              builder: (ctx) => Dialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                elevation: 0,
                backgroundColor: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon/Header
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.qr_code_scanner, size: 48, color: Theme.of(context).colorScheme.primary),
                      ),
                      const SizedBox(height: 20),
                      
                      // Product Name
                      Text(
                        productName,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      
                      // Description
                      if (desc.isNotEmpty)
                        Text(
                          desc,
                          style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                          textAlign: TextAlign.center,
                        ),
                      const SizedBox(height: 20),
                      
                      // Info row (Price & Scan Count)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Text('status'.tr, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
                              const SizedBox(height: 4),
                              Text(
                                scanCount == 0 ? 'status_inactive'.tr : 'status_active'.tr, 
                                style: TextStyle(
                                  fontSize: 18, 
                                  fontWeight: FontWeight.bold,
                                  color: scanCount == 0 ? Colors.grey : Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      // Points Badge
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.orange.shade400, Colors.deepOrange],
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ]
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.stars, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              "+$points ${'points'.tr}",
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      Text(
                        'login_to_add_points'.tr,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8)),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      
                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(ctx),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                side: BorderSide(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2)),
                              ),
                              child: Text('close'.tr, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                Navigator.pop(context); // Go back to LoginScreen
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              child: Text('login'.tr, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            );
          }
        } else {
          bool scannedBySelf = response['scannedBySelf'] == true;
          
          String errorMessage = scannedBySelf 
              ? 'scanned_by_self'.tr 
              : 'scanned_by_other'.tr;
          
          final isAdminContactNeeded = !scannedBySelf;
          
          showDialog(
            context: context,
            builder: (ctx) => Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.info_outline, color: Colors.orange, size: 48),
                    ),
                    const SizedBox(height: 20),
                    Text('attention'.tr, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
                    const SizedBox(height: 12),
                    Text(
                      errorMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodyMedium?.color),
                    ),
                    const SizedBox(height: 24),
                    if (isAdminContactNeeded)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _showComplaintDialog(qrCode);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: Text('send_complaint'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    if (isAdminContactNeeded) const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(isAdminContactNeeded ? 'cancel'.tr : 'understood'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            )
          );
        }

        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _isScanned = false;
            });
          }
        });
  }

  void _showManualEntryDialog() {
    final TextEditingController codeController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 10)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(Icons.keyboard, size: 40, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(height: 20),
              Text('manual_entry'.tr, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('enter_qr_number'.tr, style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
              const SizedBox(height: 20),
              TextField(
                controller: codeController,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: (val) {
                  Navigator.pop(ctx);
                  if (val.trim().isNotEmpty) {
                    _processQrCode(val.trim());
                  }
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                      child: Text('cancel'.tr, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        final code = codeController.text.trim();
                        if (code.isNotEmpty) _processQrCode(code);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text('confirm'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComplaintDialog(String qrCode) {
    final TextEditingController messageController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.report_problem, size: 40, color: Colors.orange),
                  ),
                  const SizedBox(height: 20),
                  Text('leave_complaint'.tr, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12)
                    ),
                    child: Text("QR Kod: $qrCode", style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: messageController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Muammoni qisqacha yozing (ixtiyoriy)",
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: isSubmitting ? null : () => Navigator.pop(ctx),
                          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                          child: Text('cancel'.tr, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isSubmitting ? null : () async {
                            setState(() => isSubmitting = true);
                            final msg = messageController.text.trim().isEmpty 
                                ? "Ushbu QR kod ishlatilgan deb xato bermoqda." 
                                : messageController.text.trim();
                                
                            final res = await _apiService.submitComplaint(qrCode, msg);
                            setState(() => isSubmitting = false);
                            
                            if (!ctx.mounted) return;
                            Navigator.pop(ctx);
                            
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(res['message'] ?? (res['success'] ? 'complaint_sent'.tr : 'error'.tr)),
                                backgroundColor: res['success'] ? Colors.green : Colors.red,
                              )
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: isSubmitting 
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : Text('submit'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
      ),
    );
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
                errorBuilder: (context, error) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.videocam_off, color: Colors.white54, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          'camera_error'.tr,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white54),
                        ),
                      ],
                    ),
                  );
                },
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
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 80.0),
                  child: ElevatedButton.icon(
                    onPressed: _showManualEntryDialog,
                    icon: const Icon(Icons.keyboard),
                    label: Text('manual_entry'.tr),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                    ),
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
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 0.5),
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
