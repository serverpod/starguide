// A minimal example showing how to use the generated client.
//
// Run with:
//   dart run example/basic_usage.dart

import 'dart:async';
import 'dart:io';

import 'package:starguide_client/starguide_client.dart';

Future<void> main(List<String> args) async {
  // Choose the appropriate host for your environment:
  // - Local dev: 'http://localhost:8080/' (if running the server locally)
  // - Public demo: 'https://starguide.api.serverpod.space/'
  final host = Platform.environment['STARGUIDE_HOST'] ??
      'https://starguide.api.serverpod.space/';

  final client = Client(host);

  // Example: Using the MCP endpoint to fetch resources
  try {
    final resources = await client.mcp.getAllResources();
    print('Fetched ${resources.length} resources via MCP.');
    if (resources.isNotEmpty) {
      final first = resources.first;
      print('First resource: name="${first.name}", uri=${first.uri}');
    }
  } catch (e) {
    stderr.writeln('Failed to fetch MCP resources: $e');
  }
}
