import 'dart:io';

import 'package:serverpod/serverpod.dart';

final busterStatic = CacheBustingConfig(
  mountPrefix: '/',
  fileSystemRoot: Directory(
    'web/static',
  ),
);

final busterApp = CacheBustingConfig(
  mountPrefix: '/',
  fileSystemRoot: Directory(
    'web/app',
  ),
);
