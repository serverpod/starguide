import 'dart:convert';

import 'package:flutter/services.dart';

/// App configuration loaded from the `assets/config.json` asset.
///
/// When the app is served by the Serverpod web server, the server replaces
/// the bundled file with one pointing at its own API server, so the app
/// always connects to the right environment.
class AppConfig {
  final String? apiUrl;

  AppConfig({required this.apiUrl});

  static Future<AppConfig> loadConfig() async {
    final config = await _loadJsonConfig();
    final String? apiUrl = config['apiUrl'];

    return AppConfig(apiUrl: apiUrl);
  }

  static Future<Map<String, dynamic>> _loadJsonConfig() async {
    final data = await rootBundle.loadString('assets/config.json');
    return jsonDecode(data);
  }
}
