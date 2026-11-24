import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart' show openAppSettings;
import 'package:provider/provider.dart';

import '../../../../app/routes.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/widgets/field_painters.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../connection/presentation/connection_controller.dart';
import '../../../settings/presentation/settings_controller.dart';
import '../view_models/scanner_view_model.dart';
import '../../../../core/presentation/failure_text.dart';

/// B1 · Scanner idle / B2 · Low light, torch on / B3 · Camera permission denied
class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> with WidgetsBindingObserver {
  late final MobileScannerController _camera;
  bool _permissionDenied = false;
  bool _showingResult = false;

  /// После возврата с экрана результата тот же код, оставшийся в кадре,
  /// не перечитываем сразу — иначе экран отказа зациклится.
  String? _cooldownCode;
  DateTime _cooldownUntil = DateTime(0);
  static const _cooldown = Duration(milliseconds: 1500);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final torch = context.read<SettingsController>().settings.torchOnByDefault;
    _camera = MobileScannerController(
      formats: const [BarcodeFormat.qrCode],
      torchEnabled: torch,
      autoTorch: !torch,
    );
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

    final vm = context.read<ScannerViewModel>();
    final result = await vm.handle(raw);
    if (result == null || !mounted) return;

    switch (result) {
      case Ok(:final value):
        _showingResult = true;
        await _camera.pause();
        if (!mounted) return;
        await context.push(Routes.result, extra: value);
        await _resume(raw);
      case Err(failure: NetworkFailure()):
        _showingResult = true;
        await _camera.pause();
        if (!mounted) return;
        await context.push(Routes.offline);
        await _resume(raw);
      case Err(:final failure):
        _cooldownCode = raw;
        _cooldownUntil = DateTime.now().add(_cooldown);
        showMessage(context, failure.text(context));
    }
  }

  Future<void> _resume(String lastCode) async {
    _cooldownCode = lastCode;
    _cooldownUntil = DateTime.now().add(_cooldown);
    _showingResult = false;
    if (mounted) await _camera.start();
  }

  void _findByName() => context.push(Routes.search);

  @override
  Widget build(BuildContext context) {
    if (_permissionDenied) return _PermissionDenied(onFindByName: _findByName);

    final vm = context.watch<ScannerViewModel>();
    final online = context.watch<ConnectionController>().isOnline;
    final gate = context.watch<SettingsController>().settings.gate;
    final stats = vm.stats;
    final event = vm.event;

    return Scaffold(
      backgroundColor: AppPalette.camera,
      body: Stack(
        fit: StackFit.expand,
        children: [
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
              return _CameraError(message: error.errorDetails?.message ?? 'Camera is unavailable.');
            },
          ),
          // затемнение вокруг рамки, чтобы подсказки читались на любом фоне
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xCC15181A), Color(0x0015181A), Color(0x0015181A), Color(0xE615181A)],
                stops: [0, 0.22, 0.6, 0.85],
              ),
            ),
          ),
          SafeArea(
            child: ValueListenableBuilder<MobileScannerState>(
              valueListenable: _camera,
              builder: (context, camera, _) {
                final torchOn = camera.torchState == TorchState.on;
                return Column(
                  children: [
                    _TopBar(
                      title: event?.title ?? 'Scanner',
                      subtitle: stats == null
                          ? gate
                          : '$gate · ${Fmt.count(stats.checkedIn)} / ${Fmt.count(stats.registered)} in',
                      torch: camera.torchState,
                      onTorch: _camera.toggleTorch,
                      onBack: () => context.pop(),
                    ),
                    if (!online)
                      _Banner(
                        text: 'NO CONNECTION — SCANNING PAUSED',
                        onTap: () => context.push(Routes.offline),
                      )
                    else if (torchOn)
                      const _Banner(text: 'LOW LIGHT — TORCH ON'),
                    const Spacer(),
                    const _Reticle(),
                    const SizedBox(height: 28),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sideDark),
                      child: Column(
                        children: [
                          Text(
                            vm.isChecking
                                ? 'Checking ticket…'
                                : (torchOn ? 'Reading code…' : 'Hold the ticket QR in the frame'),
                            textAlign: TextAlign.center,
                            style: AppText.headerTitle.copyWith(color: AppPalette.onStrong),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            torchOn
                                ? 'Move a little closer if it does not catch.'
                                : 'Paper or phone screen. Works in grayscale.',
                            textAlign: TextAlign.center,
                            style: AppText.meta.copyWith(color: AppPalette.onStrong.withValues(alpha: 0.6)),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.sideDark, 0, AppSpacing.sideDark, AppSpacing.bottomClearance,
                      ),
                      child: torchOn
                          ? SecondaryButton(label: 'Find by name instead', onDark: true, onPressed: _findByName)
                          : Row(
                              children: [
                                Expanded(
                                  child: SecondaryButton(
                                    label: 'Find by name',
                                    icon: Icons.search,
                                    onDark: true,
                                    onPressed: _findByName,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.actionGap),
                                Expanded(
                                  child: SecondaryButton(
                                    label: 'Summary',
                                    onDark: true,
                                    onPressed: event == null
                                        ? null
                                        : () => context.push(Routes.eventSummary(event.id)),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
          if (vm.isChecking)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: LinearProgressIndicator(minHeight: 3, color: context.colors.primarySoft),
            ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.title,
    required this.subtitle,
    required this.torch,
    required this.onTorch,
    required this.onBack,
  });

  final String title;
  final String subtitle;
  final TorchState torch;
  final VoidCallback onTorch;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final on = torch == TorchState.on;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.sideDark - 7, 8, AppSpacing.sideDark, 10),
      child: Row(
        children: [
          BackBox(onPressed: onBack, onDark: true),
          const SizedBox(width: 5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.headerTitle.copyWith(color: AppPalette.onStrong),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle.toUpperCase(),
                  style: AppText.fieldLabel.copyWith(color: AppPalette.onStrong.withValues(alpha: 0.6)),
                ),
              ],
            ),
          ),
          if (torch != TorchState.unavailable)
            Semantics(
              button: true,
              toggled: on,
              label: 'Torch',
              child: GestureDetector(
                onTap: onTorch,
                child: Container(
                  width: AppSizes.minTap,
                  height: AppSizes.minTap,
                  decoration: BoxDecoration(
                    color: on ? AppPalette.onStrong : null,
                    border: on ? null : Border.all(color: AppPalette.onStrong.withValues(alpha: 0.35)),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        on ? Icons.flashlight_on_outlined : Icons.flashlight_off_outlined,
                        size: 22,
                        color: on ? context.colors.text : AppPalette.onStrong,
                      ),
                      if (torch == TorchState.auto)
                        Positioned(
                          bottom: 2,
                          child: Text(
                            'AUTO',
                            style: AppText.fieldLabel.copyWith(fontSize: 7, color: AppPalette.onStrong),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.text, this.onTap});

  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sideDark),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        color: AppPalette.onStrong,
        child: Text(text, style: AppText.statusStrip.copyWith(color: context.colors.text)),
      ),
    );
  }
}

class _Reticle extends StatelessWidget {
  const _Reticle();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = (constraints.maxWidth - 2 * 40).clamp(160.0, 300.0);
        return SizedBox.square(
          dimension: side,
          child: CustomPaint(
            painter: ReticlePainter(cornerColor: AppPalette.onStrong, lineColor: context.colors.primarySoft),
          ),
        );
      },
    );
  }
}

class _CameraError extends StatelessWidget {
  const _CameraError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppPalette.camera,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: AppText.bodySecondary.copyWith(color: AppPalette.onStrong.withValues(alpha: 0.6)),
          ),
        ),
      ),
    );
  }
}

/// B3 — доступ к камере выключен; путь обратно и запасной вариант.
class _PermissionDenied extends StatelessWidget {
  const _PermissionDenied({required this.onFindByName});

  final VoidCallback onFindByName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScreenHeader(title: 'Scanner', onBack: () => context.pop()),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.sideLight, 56, AppSpacing.sideLight, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.no_photography_outlined, size: 40, color: context.colors.textMuted),
                    const SizedBox(height: 18),
                    Text('Camera access is off', style: AppText.screenTitle.copyWith(color: context.colors.text)),
                    const SizedBox(height: 8),
                    Text(
                      'BiletFlow needs the camera to read ticket QR codes. Turn it on in '
                      'Settings → BiletFlow → Camera, then come back to this screen.',
                      style: AppText.body.copyWith(color: context.colors.textMuted),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.sideLight, 0, AppSpacing.sideLight, AppSpacing.bottomClearance),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PrimaryButton(label: 'Open settings', onPressed: openAppSettings),
                  const SizedBox(height: AppSpacing.actionGap),
                  SecondaryButton(label: 'Check in by name instead', onPressed: onFindByName),
                  const SizedBox(height: 14),
                  Text(
                    'Manual search still records a real check-in against the same ticket, '
                    'so an attendee is never admitted twice.',
                    style: AppText.finePrint.copyWith(color: context.colors.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
