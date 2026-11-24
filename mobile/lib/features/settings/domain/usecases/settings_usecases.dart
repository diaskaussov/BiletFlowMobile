import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../entities/scanner_settings.dart';
import '../repositories/settings_repository.dart';

class LoadSettings {
  const LoadSettings(this._repo);

  final SettingsRepository _repo;

  Future<ScannerSettings> call() => _repo.load();
}

class SaveSettings {
  const SaveSettings(this._repo);

  final SettingsRepository _repo;

  static const maxGateLength = 24;

  Future<Result<ScannerSettings>> call(ScannerSettings settings) async {
    final gate = settings.gate.trim();
    if (gate.isEmpty) return const Err(ValidationFailure('Gate name cannot be empty.', code: 'gateEmpty'));
    if (gate.length > maxGateLength) {
      return const Err(ValidationFailure('Gate name is too long.', code: 'gateLong'));
    }
    final normalized = settings.copyWith(gate: gate);
    await _repo.save(normalized);
    return Ok(normalized);
  }
}
