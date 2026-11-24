import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart' show openAppSettings;
import 'package:provider/provider.dart';

import '../../../../app/main_tab_bar.dart';
import '../../../../app/routes.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/presentation/failure_text.dart';
import '../../../../core/presentation/l10n.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/widgets/commerce_widgets.dart';
import '../../../../core/widgets/data_blocks.dart';
import '../../../../core/widgets/floating_nav_bar.dart';
import '../../../../core/widgets/labeled_text_field.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../connection/presentation/connection_controller.dart';
import '../../../settings/presentation/settings_controller.dart';
import '../../domain/entities/scan_result.dart';
import '../view_models/scanner_view_model.dart';

/// A3 · Сканер. Один скан за раз: результат открывается на весь экран,
/// камера на паузе, пока контролёр не нажмёт «Следующий».
class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> with WidgetsBindingObserver {
  late final MobileScannerController _camera;
  bool _permissionDenied = false;
  bool _showingResult = false;

  /// После возврата с результата тот же код в кадре не перечитываем сразу —
  /// иначе экран отказа зациклится.
  String? _cooldownCode;
  DateTime _cooldownUntil = DateTime(0);
  static const _cooldown = Duration(milliseconds: 1500);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final torch = context.read<SettingsController>().settings.torchOnByDefault;
    _camera = MobileScannerController(formats: const [BarcodeFormat.qrCode], torchEnabled: torch, autoTorch: !torch);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _camera.dispose();
    super.dispose();
  }

  /// Вернулись из системных настроек — пробуем камеру снова.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _permissionDenied) {
      setState(() => _permissionDenied = false);
      _camera.start();
    }
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_showingResult || _permissionDenied) return;
    final raw = capture.barcodes.map((b) => b.rawValue).whereType<String>().firstOrNull;
    if (raw == null) return;
    if (raw == _cooldownCode && DateTime.now().isBefore(_cooldownUntil)) return;
    await _check(raw);
  }

  Future<void> _check(String raw) async {
    final vm = context.read<ScannerViewModel>();
    final result = await vm.handle(raw);
    if (result == null || !mounted) return;
    switch (result) {
      case Ok<ScanResult>(:final value):
        _showingResult = true;
        await _camera.pause();
        if (!mounted) return;
        await context.push(Routes.result, extra: value);
        await _resume(raw);
      case Err<ScanResult>(failure: NetworkFailure()):
        _showingResult = true;
        await _camera.pause();
        if (!mounted) return;
        await context.push(Routes.offline);
        await _resume(raw);
      case Err<ScanResult>(:final failure):
        _cooldownCode = raw;
        _cooldownUntil = DateTime.now().add(_cooldown);
        showMessage(context, failure.text(context));
    }
  }

  Future<void> _resume(String lastCode) async {
    _cooldownCode = lastCode;
    _cooldownUntil = DateTime.now().add(_cooldown);
    _showingResult = false;
    if (mounted && !_permissionDenied) await _camera.start();
  }

  Future<void> _enterCode() async {
    final code = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _ManualCodeSheet(),
    );
    if (code != null && code.trim().isNotEmpty && mounted) await _check(code.trim());
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final vm = context.watch<ScannerViewModel>();
    final online = context.watch<ConnectionController>().isOnline;
    final event = vm.event;
    final stats = vm.stats;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            if (!online)
              Material(
                color: c.danger,
                child: InkWell(
                  onTap: () => context.push(Routes.offline),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.side, vertical: 12),
                    child: Row(children: [
                      const Icon(LucideIcons.wifiOff, size: 20, color: Colors.white),
                      const SizedBox(width: 10),
                      Expanded(child: Text(l.scanPaused, style: AppText.bodyStrong.copyWith(color: Colors.white))),
                    ]),
                  ),
                ),
              ),
            LargeHeader(
              title: l.navScanner,
              context_: event?.title ?? l.chooseEvent,
              onContextTap: () => context.go(Routes.events),
              action: CircleIconButton(
                icon: LucideIcons.settings,
                tooltip: l.settings,
                onPressed: () => context.push(Routes.settings),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.side, 4, AppSpacing.side, 16),
                child: Column(
                  children: [
                    AppCard(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          EventImage(label: event?.title, height: 48, width: 48, radius: 12),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  [if (event?.startsAt != null) Fmt.dateTime(event!.startsAt!), ?event?.venueName].join(' · '),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppText.caption.copyWith(color: c.textMuted),
                                ),
                                const SizedBox(height: 3),
                                Row(children: [
                                  Expanded(
                                    child: Text(
                                      stats == null ? '—' : l.enteredOf(stats.checkedIn, stats.registered),
                                      style: AppText.cardTitle.copyWith(color: c.text),
                                    ),
                                  ),
                                  if (stats != null)
                                    Text(Fmt.percent(stats.checkedIn, stats.registered),
                                        style: AppText.bodyStrong.copyWith(color: c.primary, fontWeight: FontWeight.w700)),
                                ]),
                                const SizedBox(height: 6),
                                ProgressStrip(value: stats?.ratio ?? 0),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(child: _permissionDenied ? _PermissionDenied(onFind: () => context.go(Routes.search)) : _cameraCard(context, vm)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const ScannerTabBar(current: ScannerTab.scanner),
    );
  }

  Widget _cameraCard(BuildContext context, ScannerViewModel vm) {
    final l = context.l10n;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.panel),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: AppPalette.camera),
          MobileScanner(
            controller: _camera,
            onDetect: _onDetect,
            placeholderBuilder: (_) => const ColoredBox(color: AppPalette.camera),
            errorBuilder: (context, error) {
              if (error.errorCode == MobileScannerErrorCode.permissionDenied && !_permissionDenied) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) setState(() => _permissionDenied = true);
                });
              }
              return Center(
                child: Text(l.cameraUnavailable, style: AppText.bodySecondary.copyWith(color: Colors.white70)),
              );
            },
          ),
          // Затемнение по краям — подсказки читаются на любом фоне.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(radius: 0.9, colors: [Color(0x0014141F), Color(0xB314141F)]),
            ),
          ),
          ValueListenableBuilder<MobileScannerState>(
            valueListenable: _camera,
            builder: (context, camera, _) {
              final torchOn = camera.torchState == TorchState.on;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  SizedBox.square(
                    dimension: 220,
                    child: CustomPaint(painter: _FramePainter(scanLine: context.colors.primary)),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    vm.isChecking ? l.checking : (torchOn ? l.lowLightTorchOn : l.pointAtQr),
                    textAlign: TextAlign.center,
                    style: AppText.body.copyWith(color: const Color(0xFFF4F4F8), fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (camera.torchState != TorchState.unavailable) ...[
                        _GlassButton(
                          icon: LucideIcons.flashlight,
                          label: l.torch,
                          active: torchOn,
                          onTap: _camera.toggleTorch,
                        ),
                        const SizedBox(width: 12),
                      ],
                      _GlassButton(icon: LucideIcons.keyboard, label: l.enterCode, onTap: _enterCode),
                    ],
                  ),
                  const Spacer(),
                  if (vm.isChecking) const LinearProgressIndicator(minHeight: 3),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Полупрозрачная кнопка поверх камеры («Фонарик», «Ввести код»).
class _GlassButton extends StatelessWidget {
  const _GlassButton({required this.icon, required this.label, required this.onTap, this.active = false});

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final fg = active ? const Color(0xFF14141F) : Colors.white;
    return Semantics(
      button: true,
      toggled: active,
      child: Material(
        color: active ? Colors.white : Colors.white.withValues(alpha: 0.15),
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: fg),
                const SizedBox(width: 8),
                Text(label, style: AppText.buttonSmall.copyWith(color: fg)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Рамка-прицел: белые скруглённые уголки и светящаяся линия.
class _FramePainter extends CustomPainter {
  const _FramePainter({required this.scanLine});

  final Color scanLine;

  @override
  void paint(Canvas canvas, Size size) {
    const arm = 40.0, w = 5.0;
    final p = Paint()
      ..color = Colors.white
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final s = size.width, h = size.height, o = w / 2;
    for (final (dx, dy) in [(1.0, 1.0), (-1.0, 1.0), (1.0, -1.0), (-1.0, -1.0)]) {
      final x = dx > 0 ? o : s - o, y = dy > 0 ? o : h - o;
      canvas.drawPath(
        Path()
          ..moveTo(x, y + dy * arm)
          ..lineTo(x, y + dy * 10)
          ..arcToPoint(Offset(x + dx * 10, y), radius: const Radius.circular(10), clockwise: dx * dy > 0)
          ..lineTo(x + dx * arm, y),
        p,
      );
    }
    final line = Rect.fromCenter(center: Offset(s / 2, h / 2), width: math.min(180, s - 40), height: 3);
    canvas.drawRRect(
      RRect.fromRectAndRadius(line, const Radius.circular(2)),
      Paint()
        ..color = scanLine
        ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 6),
    );
  }

  @override
  bool shouldRepaint(_FramePainter old) => old.scanLine != scanLine;
}

class _PermissionDenied extends StatelessWidget {
  const _PermissionDenied({required this.onFind});

  final VoidCallback onFind;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AppCard(
      radius: AppRadius.panel,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MessageView(icon: LucideIcons.cameraOff, tone: Tone.warning, title: l.cameraOffTitle, message: l.cameraOffBody),
          const SizedBox(height: 20),
          PrimaryButton(label: l.openSettings, onPressed: openAppSettings),
          const SizedBox(height: 10),
          SecondaryButton(label: l.findGuestInstead, icon: LucideIcons.userSearch, onPressed: onFind),
        ],
      ),
    );
  }
}

/// «Ввести код» — проверка по коду из письма или под QR.
class _ManualCodeSheet extends StatefulWidget {
  const _ManualCodeSheet();

  @override
  State<_ManualCodeSheet> createState() => _ManualCodeSheetState();
}

class _ManualCodeSheetState extends State<_ManualCodeSheet> {
  final _code = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.side, 0, AppSpacing.side, 16 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.enterCodeTitle, style: AppText.headerTitle.copyWith(color: c.text)),
          const SizedBox(height: 4),
          Text(l.enterCodeHint, style: AppText.bodySecondary.copyWith(color: c.textMuted)),
          const SizedBox(height: 16),
          LabeledTextField(
            controller: _code,
            autofocus: true,
            leadingIcon: LucideIcons.ticket,
            hintText: 'c67b8e0d-…',
            textInputAction: TextInputAction.done,
            onSubmitted: (v) => Navigator.of(context).pop(v),
          ),
          const SizedBox(height: 16),
          PrimaryButton(label: l.checkCode, onPressed: () => Navigator.of(context).pop(_code.text)),
        ],
      ),
    );
  }
}
