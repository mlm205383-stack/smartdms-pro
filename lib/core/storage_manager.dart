import 'dart:io';

class StorageManager {
  static const String basePath = '/storage/emulated/0/SmartDMS_PRO';

  static Future<void> initStorage() async {
    List<String> folders = [
      '$basePath/database',
      '$basePath/files',
      '$basePath/config',
      '$basePath/backup',
      '$basePath/2024',
    ];
    for (var path in folders) {
      await Directory(path).create(recursive: true);
    }
  }

  static String get currentStoragePath => '$basePath/2024/';
}
