// Web implementation
import 'dart:html' as html;

class WebHelper {
  static void downloadFile(String content, String filename) {
    final bytes = content.codeUnits;
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}
