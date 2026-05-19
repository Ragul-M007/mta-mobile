import 'dart:io';

/// Drop-in replacement for the abandoned `external_path` package.
class ExternalPath {
  static const String DIRECTORY_DOWNLOADS = 'Download';
  static const String DIRECTORY_MUSIC = 'Music';
  static const String DIRECTORY_DCIM = 'DCIM';
  static const String DIRECTORY_DOCUMENTS = 'Documents';
  static const String DIRECTORY_PICTURES = 'Pictures';
  static const String DIRECTORY_MOVIES = 'Movies';

  static Future<String> getExternalStoragePublicDirectory(String type) async {
    if (Platform.isAndroid) {
      return '/storage/emulated/0/$type';
    }
    return '';
  }
}
