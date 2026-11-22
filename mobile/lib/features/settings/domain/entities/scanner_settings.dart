/// Настройки сканера на этом устройстве (A6).
class ScannerSettings {
  const ScannerSettings({
    this.torchOnByDefault = false,
    this.soundOnResult = true,
    this.vibrateOnReject = true,
    this.gate = 'Gate 1',
  });

  final bool torchOnByDefault;
  final bool soundOnResult;
  final bool vibrateOnReject;

  /// Название входа — его нет в API, задаётся на устройстве и
  /// показывается в строке статуса результатов («GATE 3 · 19:43:02»).
  final String gate;

  ScannerSettings copyWith({
    bool? torchOnByDefault,
    bool? soundOnResult,
    bool? vibrateOnReject,
    String? gate,
  }) =>
      ScannerSettings(
        torchOnByDefault: torchOnByDefault ?? this.torchOnByDefault,
        soundOnResult: soundOnResult ?? this.soundOnResult,
        vibrateOnReject: vibrateOnReject ?? this.vibrateOnReject,
        gate: gate ?? this.gate,
      );
}
