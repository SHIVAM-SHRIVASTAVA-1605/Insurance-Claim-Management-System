import 'dart:html' as html;

class StorageService {
  static Future<void> saveData(String key, String data) async {
    html.window.localStorage[key] = data;
  }

  static Future<String?> loadData(String key) async {
    return html.window.localStorage[key];
  }
}
