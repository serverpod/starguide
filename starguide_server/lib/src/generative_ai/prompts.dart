import 'dart:io';

class Prompts {
  static final Prompts _instance = Prompts._();
  static Prompts get instance => _instance;

  final Map<String, String> _prompts = {};

  Prompts._() {
    final promptsFolder = Directory('prompts');
    for (var file in promptsFolder.listSync(recursive: true)) {
      if (file.path.endsWith('.txt') && file is File) {
        _prompts[file.path.split('/').last.replaceAll('.txt', '')] =
            file.readAsStringSync();
      }
    }
  }

  String? get(String key) {
    return _prompts[key];
  }
}
