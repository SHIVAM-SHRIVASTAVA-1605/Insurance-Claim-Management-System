import 'dart:io';
import 'package:path_provider/path_provider.dart';

class StorageService {
  static Future<void> saveData(String key, String data) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$key.json');
    await file.writeAsString(data);
  }

  static Future<String?> loadData(String key) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$key.json');
      if (await file.exists()) {
        return await file.readAsString();
      }
    } catch (e) {
      print('Error loading data: $e');
    }
    return null;
  }
}
