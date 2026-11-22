/// Терпимое чтение JSON: контракт бэкенда описан не полностью, поэтому
/// модели принимают несколько вариантов имён полей и типов.
extension JsonReader on Map<String, dynamic> {
  String? str(List<String> keys) {
    for (final k in keys) {
      final v = this[k];
      if (v == null) continue;
      if (v is String) return v.isEmpty ? null : v;
      if (v is num || v is bool) return v.toString();
    }
    return null;
  }

  int? integer(List<String> keys) {
    for (final k in keys) {
      final v = this[k];
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) {
        final parsed = int.tryParse(v);
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  bool? boolean(List<String> keys) {
    for (final k in keys) {
      final v = this[k];
      if (v is bool) return v;
      if (v is String) return v.toLowerCase() == 'true';
    }
    return null;
  }

  /// [naiveIsUtc]: сервер пишет моменты (`checkedInAt`, `createdAt`) в UTC
  /// без пояса. Даты событий — местное время площадки, их не сдвигаем.
  DateTime? date(List<String> keys, {bool naiveIsUtc = false}) {
    final raw = str(keys);
    if (raw == null) return null;
    final hasZone = RegExp(r'(Z|[+-]\d{2}:?\d{2})$').hasMatch(raw);
    final parsed = DateTime.tryParse(naiveIsUtc && !hasZone ? '${raw}Z' : raw);
    return parsed?.toLocal();
  }

  Map<String, dynamic>? obj(String key) {
    final v = this[key];
    return v is Map ? v.cast<String, dynamic>() : null;
  }
}

/// Список из ответа: либо голый массив, либо обёртка `{content: [...]}` /
/// `{data: [...]}` (на случай пагинации Spring).
List<Map<String, dynamic>> jsonList(dynamic data) {
  final raw = switch (data) {
    List() => data,
    Map() => data['content'] ?? data['data'] ?? data['items'] ?? const [],
    _ => const [],
  };
  if (raw is! List) return const [];
  return raw.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList();
}
