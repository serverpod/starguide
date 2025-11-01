import 'dart:io';

import 'package:serverpod/serverpod.dart';

final buster = CacheBustingConfig(
  mountPrefix: '/',
  fileSystemRoot: Directory(
    'web/static',
  ),
);
