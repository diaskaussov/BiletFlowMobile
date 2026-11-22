import 'dart:typed_data';

import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Действия с файлами и ссылками: отправить PDF или .ics, распечатать,
/// открыть календарь. Обёртка, чтобы экраны не знали про плагины.
class DocumentActions {
  const DocumentActions();

  Future<void> share(Uint8List bytes, {required String name, required String mimeType, String? text}) async {
    await SharePlus.instance.share(ShareParams(
      files: [XFile.fromData(bytes, name: name, mimeType: mimeType)],
      fileNameOverrides: [name],
      text: text,
    ));
  }

  Future<void> shareText(String text, {String? subject}) async {
    await SharePlus.instance.share(ShareParams(text: text, subject: subject));
  }

  /// Системный диалог печати (W7 «PRINT»).
  Future<void> printPdf(Uint8List bytes, {required String name}) async {
    await Printing.layoutPdf(onLayout: (_) async => bytes, name: name);
  }

  Future<bool> openUrl(Uri url) => launchUrl(url, mode: LaunchMode.externalApplication);
}
