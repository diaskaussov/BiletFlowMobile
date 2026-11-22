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

  DateTime? date(List<String> keys) {
    final raw = str(keys);
    return raw == null ? null : DateTime.tryParse(raw)?.toLocal();
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
