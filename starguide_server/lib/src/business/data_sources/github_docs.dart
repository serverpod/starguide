import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pub_semver/pub_semver.dart';
import 'package:serverpod/serverpod.dart';
import 'package:starguide_server/src/business/data_fetcher.dart';
import 'package:starguide_server/src/business/data_source.dart';
import 'package:starguide_server/src/generated/protocol.dart';

class GithubDocsDataSource implements DataSource {
  final String owner;
  final String repo;
  final String branch;
  final String basePath;
  final Uri referenceUrl;

  /// Latest version, if known.
  final String? latestVersion;

  GithubDocsDataSource({
    required this.owner,
    required this.repo,
    required this.branch,
    required this.basePath,
    required this.referenceUrl,
    this.latestVersion,
  });

  static Future<http.Response> _githubApiGet(Uri url) async {
    final githubToken = Serverpod.instance.getPassword('githubToken');
    if (githubToken == null) {
      throw Exception('GitHub token not configured');
    }

    return await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $githubToken',
        'Accept': 'application/vnd.github.v3+json',
      },
    );
  }

  static Future<GithubDocsDataSource> versioned({
    required final String owner,
    required final String repo,
    required final String branch,
    required final String basePath,
    required final Uri referenceUrl,
  }) async {
    // Normalize basePath: remove leading slash, ensure trailing slash (or empty)
    var normalizedPath = basePath;
    if (normalizedPath.startsWith('/')) {
      normalizedPath = normalizedPath.substring(1);
    }
    if (normalizedPath.isNotEmpty && !normalizedPath.endsWith('/')) {
      normalizedPath = '$normalizedPath/';
    }

    // Fetch versions.json from the normalized path (or root if empty)
    final versionsPath = '${normalizedPath}versions.json';
    final versionsUrl = Uri.parse(
      'https://api.github.com/repos/$owner/$repo/contents/$versionsPath?ref=$branch',
    );

    final versionsResponse = await _githubApiGet(versionsUrl);

    if (versionsResponse.statusCode != 200) {
      throw Exception(
        'Failed to fetch versions.json. ${versionsResponse.statusCode}\n${versionsResponse.body}',
      );
    }

    final versionsData = json.decode(versionsResponse.body);
    final downloadUrl = Uri.parse(versionsData['download_url']);

    final fileResponse = await _githubApiGet(downloadUrl);

    if (fileResponse.statusCode != 200) {
      throw Exception(
        'Failed to download versions.json. ${fileResponse.statusCode}\n${fileResponse.body}',
      );
    }

    final List<dynamic> versions = json.decode(fileResponse.body);
    if (versions.isEmpty) {
      throw Exception('versions.json is empty');
    }

    // Find latest version by comparing semantic versions using pub_semver
    final latestVersion = _findLatestVersion(versions.cast<String>());

    // Append versioned_docs/version-<version> to the normalized path
    final finalBasePath =
        '${normalizedPath}versioned_docs/version-$latestVersion';

    // Verify the path exists before returning
    final verifyUrl = Uri.parse(
      'https://api.github.com/repos/$owner/$repo/contents/$finalBasePath?ref=$branch',
    );
    final verifyResponse = await _githubApiGet(verifyUrl);

    if (verifyResponse.statusCode != 200) {
      throw Exception(
        'Versioned docs path does not exist: $finalBasePath\n'
        'Status: ${verifyResponse.statusCode}\n'
        'Response: ${verifyResponse.body}',
      );
    }

    return GithubDocsDataSource(
      owner: owner,
      repo: repo,
      branch: branch,
      basePath: finalBasePath,
      referenceUrl: referenceUrl,
      latestVersion: latestVersion,
    );
  }

  @override
  String get name => 'GithubDocs';

  @override
  Stream<RawRAGDocument> fetch(
    Session session,
    DataFetcher fetcher, {
    String? path,
    Uri? referenceUrl,
  }) async* {
    path ??= basePath;
    referenceUrl ??= this.referenceUrl;

    final apiUrl = Uri.parse(
      'https://api.github.com/repos/$owner/$repo/contents/$path?ref=$branch',
    );

    final response = await _githubApiGet(apiUrl);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to list contents. ${response.statusCode}\n${response.body}',
      );
    }

    final List files = json.decode(response.body);

    for (var file in files) {
      final fileName = file['name'];
      final cleanedFileName = _cleanFileName(fileName);
      final url = referenceUrl.replace(
        pathSegments: [
          ...referenceUrl.pathSegments,
          cleanedFileName,
        ],
      );

      if (file['type'] == 'dir') {
        final listing = fetch(
          session,
          fetcher,
          path: '$path/$fileName',
          referenceUrl: url,
        );

        await for (var doc in listing) {
          yield doc;
        }
      } else if (file['type'] == 'file' &&
          (fileName.endsWith('.md') || fileName.endsWith('.mdx'))) {
        if (await fetcher.shouldFetchUrl(session, url)) {
          final fileUrl = Uri.parse(file['download_url']);
          final fileResponse = await _githubApiGet(fileUrl);
          if (fileResponse.statusCode == 200) {
            yield RawRAGDocument(
              sourceUrl: url,
              document: fileResponse.body,
              dataSourceType: DataSourceType.markdown,
              documentType: RAGDocumentType.documentation,
              title: _getTitle(fileResponse.body),
            );
          }
        }
      }
    }
  }
}

String _cleanFileName(String fileName) {
  final prefixRegex = RegExp(r'^\d+-');
  final suffixRegex = RegExp(r'\.(md|mdx)$');
  final cleanedName =
      fileName.replaceFirst(prefixRegex, '').replaceFirst(suffixRegex, '');

  if (cleanedName == 'index') return '';
  return cleanedName;
}

String _getTitle(String markdown) {
  final titleRegex = RegExp(r'^\s*# (.+)$', multiLine: true);
  final match = titleRegex.firstMatch(markdown);
  return match?.group(1)?.trim() ?? 'Documentation';
}

String _findLatestVersion(List<String> versions) {
  if (versions.isEmpty) {
    throw ArgumentError('Versions list cannot be empty');
  }

  // Parse versions, filter out invalid ones, and sort to find latest
  final parsedVersions = <(String versionString, Version version)>[];
  for (final versionString in versions) {
    try {
      final version = Version.parse(versionString);
      parsedVersions.add((versionString, version));
    } catch (e) {
      // Skip invalid version strings
      continue;
    }
  }

  if (parsedVersions.isEmpty) {
    throw ArgumentError('No valid versions found in list');
  }

  // Sort by version (ascending) and return the last one (latest)
  parsedVersions.sort((a, b) => a.$2.compareTo(b.$2));
  return parsedVersions.last.$1;
}
