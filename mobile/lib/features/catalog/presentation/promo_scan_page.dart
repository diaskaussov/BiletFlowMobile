import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../app/routes.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/field_painters.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/state_views.dart';
import '../domain/catalog_domain.dart';

/// UC10 для участника: Campaign QR открывает событие с промокодом (W3).
/// Это не входной билет — здесь он только подставляет скидку.
class PromoScanPage extends StatefulWidget {
  const PromoScanPage({super.key});

  @override
  State<PromoScanPage> createState() => _PromoScanPageState();
}

class _PromoScanPageState extends State<PromoScanPage> {
  final _camera = MobileScannerController(formats: const [BarcodeFormat.qrCode]);
  bool _handled = false;

  @override
  void dispose() {
    _camera.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    final raw = capture.barcodes.map((b) => b.rawValue).whereType<String>().firstOrNull;
    if (raw == null) return;
    final link = parseCampaignLink(raw);
    if (link.eventId == null) {
      showMessage(context, 'This QR is not a BiletFlow campaign link.');
      return;
    }
    _handled = true;
    context.pushReplacement(Routes.publicEvent(link.eventId!, promo: link.code));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.camera,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _camera,
            onDetect: _onDetect,
            errorBuilder: (_, error) => Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Text(
                  error.errorCode == MobileScannerErrorCode.permissionDenied
                      ? 'Camera access is off. Turn it on in Settings to scan campaign codes.'
                      : 'Camera is unavailable.',
                  textAlign: TextAlign.center,
                  style: AppText.bodySecondary.copyWith(color: AppPalette.onStrong),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.sideDark - 7, 8, AppSpacing.sideDark, 0),
                  child: Row(
                    children: [
                      BackBox(onPressed: () => context.pop(), onDark: true),
                      const SizedBox(width: 5),
                      Text('Scan a campaign QR', style: AppText.headerTitle.copyWith(color: AppPalette.onStrong)),
                    ],
                  ),
                ),
                const Spacer(),
                SizedBox.square(
                  dimension: 260,
                  child: CustomPaint(
                    painter: ReticlePainter(cornerColor: AppPalette.onStrong, lineColor: context.colors.primarySoft),
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sideDark),
                  child: Text(
                    'Point at a poster or flyer QR. The event opens with its discount applied after '
                    'the server checks the code.',
                    textAlign: TextAlign.center,
                    style: AppText.meta.copyWith(color: AppPalette.onStrong.withValues(alpha: 0.7)),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
