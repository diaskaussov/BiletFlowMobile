import '../entities/appearance.dart';
import '../repositories/appearance_repository.dart';

class LoadAppearance {
  const LoadAppearance(this._repo);

  final AppearanceRepository _repo;

  Future<AppearancePreferences> call() => _repo.load();
}

class SaveAppearance {
  const SaveAppearance(this._repo);

  final AppearanceRepository _repo;

  Future<void> call(AppearancePreferences p) => _repo.save(p);
}
