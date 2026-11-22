/// Что лежит в прочитанном QR — решается до запроса к серверу.
sealed class QrPayload {
  const QrPayload();
}

/// Похоже на код билета — проверяет сервер.
final class TicketPayload extends QrPayload {
  const TicketPayload(this.code);

  final String code;
}

/// Campaign QR (§4.14): HTTPS-ссылка на событие с промо-токеном.
/// Никогда не даёт право входа, на сервер как билет не отправляется.
final class CampaignPayload extends QrPayload {
  const CampaignPayload({required this.link, this.promoCode});

  final String link;
  final String? promoCode;
}

/// Чужой QR: ссылка другого сервиса, текст, пусто (B8).
final class ForeignPayload extends QrPayload {
  const ForeignPayload(this.raw);

  final String raw;
}

abstract final class QrClassifier {
  static const _promoKeys = [
    'promo', 'promoCode', 'promo_code', 'code', 'campaign', 'campaignId',
    'c', 'ref', 'utm_campaign',
  ];

  /// Самый длинный код билета, который мы ещё отправляем на сервер.
  static const _maxTicketLength = 128;

  static QrPayload classify(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return ForeignPayload(raw);

    final uri = Uri.tryParse(text);
    final scheme = uri?.scheme.toLowerCase() ?? '';
    if (uri != null && (scheme == 'http' || scheme == 'https' || scheme == 'biletflow')) {
      final ours = scheme == 'biletflow' || uri.host.toLowerCase().contains('biletflow');
      final promo = _promoFrom(uri);
      final campaignPath = RegExp(r'/(promo|campaign|c)(/|$)').hasMatch(uri.path.toLowerCase());
      if (ours || promo != null || campaignPath) {
        return CampaignPayload(link: text, promoCode: promo ?? _lastSegment(uri, campaignPath));
      }
      return ForeignPayload(text);
    }

    if (text.length > _maxTicketLength || text.contains(RegExp(r'\s'))) {
      return ForeignPayload(text);
    }
    return TicketPayload(text);
  }

  static String? _promoFrom(Uri uri) {
    for (final key in _promoKeys) {
      final v = uri.queryParameters[key];
      if (v != null && v.isNotEmpty) return v;
    }
    return null;
  }

  static String? _lastSegment(Uri uri, bool campaignPath) {
    if (!campaignPath) return null;
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (segments.length < 2) return null;
    return segments.last;
  }
}
