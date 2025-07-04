import 'dart:io';

import 'package:starguide_server/src/web/widgets/default_page_widget.dart';
import 'package:serverpod/serverpod.dart';

class RouteRoot extends WidgetRoute {
  @override
  Future<Widget> build(Session session, HttpRequest request) async {
    // Disable cache.
    request.response.headers.set(
      'Cache-Control',
      'no-store, no-cache, must-revalidate',
    );
    request.response.headers.set(
      'Pragma',
      'no-cache',
    );
    request.response.headers.set(
      'Expires',
      '0',
    );

    return DefaultPageWidget();
  }
}
