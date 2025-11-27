import 'dart:async';

import 'package:serverpod/serverpod.dart';

abstract class CacheBustedRoute extends Route {
  final CacheBustingConfig cacheBustingConfig;

  CacheBustedRoute({required this.cacheBustingConfig});

  /// Override this method to build your web widget from the current [session]
  /// and [request].
  Future<WebWidget> build(Session session, Request request);

  @override
  Future<Response> handleCall(
    Session session,
    Request request,
  ) async {
    var widget = await build(session, request);

    if (widget is RedirectWidget) {
      var uri = Uri.parse(widget.url);
      return Response.seeOther(uri);
    }

    final mimeType = widget is JsonWidget ? MimeType.json : MimeType.html;

    final headers = Headers.build(
      (mh) => mh.cacheControl = CacheControlHeader(
        noCache: true,
        privateCache: true,
      ),
    );

    return Response.ok(
      body: Body.fromString(
        await _bustPaths(widget.toString()),
        mimeType: mimeType,
      ),
      headers: headers,
    );
  }

  /// Replace all !{/path} patterns in the rendered HTML with cache-busted paths
  Future<String> _bustPaths(String renderedHtml) async {
    // Match !{/path/to/asset} pattern
    final regex = RegExp(r'!\{(/[^}]+)\}');
    final matches = regex.allMatches(renderedHtml).toList();

    if (matches.isEmpty) {
      return renderedHtml;
    }

    // Collect all unique paths that need busting
    final pathsToProcess = <String>{};
    for (final match in matches) {
      pathsToProcess.add(match.group(1)!);
    }

    // Process all paths in parallel (CacheBustingConfig has its own caching)
    final pathMap = <String, String>{};
    await Future.wait(
      pathsToProcess.map((path) async {
        pathMap[path] = await cacheBustingConfig.tryAssetPath(path);
      }),
    );

    // Replace all occurrences with busted paths
    return renderedHtml.replaceAllMapped(regex, (match) {
      final originalPath = match.group(1)!;
      return pathMap[originalPath] ?? originalPath;
    });
  }
}
