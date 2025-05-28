import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:serverpod/serverpod.dart';
import 'package:starguide_server/src/business/data_fetcher.dart';
import 'package:starguide_server/src/business/data_source.dart';

class GithubDocsDataSource implements DataSource {
  final String owner;
  final String repo;
  final String branch;
  final String basePath;
  final Uri referenceUrl;
  late final String githubToken;

  GithubDocsDataSource({
    required this.owner,
    required this.repo,
    required this.branch,
    required this.basePath,
    required this.referenceUrl,
  }) {
    githubToken = Serverpod.instance.getPassword('githubToken')!;
  }

  @override
  Stream<RawRAGDocuement> fetch(
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

    final response = await http.get(
      apiUrl,
      headers: {
        'Authorization': 'Bearer $githubToken',
        'Accept': 'application/vnd.github.v3+json',
      },
    );

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
          final fileResponse = await http.get(fileUrl);
          if (fileResponse.statusCode == 200) {
            yield RawRAGDocuement(
              sourceUrl: url,
              document: fileResponse.body,
              type: DataSourceType.markdown,
            );
          }
        }
      }
    }
  }
}

// Future<void> fetchGithubDocs({
//   required String owner,
//   required String repo,
//   required String basePath,
//   required Uri referenceUrl,
//   required String branch,
// }) async {
//   final apiUrl = Uri.parse(
//     'https://api.github.com/repos/$owner/$repo/contents/$basePath?ref=$branch',
//   );

//   final response = await http.get(
//     apiUrl,
//     headers: {
//       'Authorization': 'Bearer $githubToken',
//       'Accept': 'application/vnd.github.v3+json',
//     },
//   );

//   if (response.statusCode != 200) {
//     throw Exception(
//       'Failed to list contents. ${response.statusCode}\n${response.body}',
//     );
//   }

//   final List files = json.decode(response.body);

//   for (var file in files) {
//     final fileName = file['name'];
//     final cleanedFileName = _cleanFileName(fileName);
//     final url = referenceUrl.replace(
//       pathSegments: [
//         ...referenceUrl.pathSegments,
//         cleanedFileName,
//       ],
//     );

//     if (file['type'] == 'dir') {
//       fetchGithubDocs(
//         owner: owner,
//         repo: repo,
//         basePath: '$basePath/$fileName',
//         referenceUrl: url,
//         branch: branch,
//       );
//     } else if (file['type'] == 'file' &&
//         (fileName.endsWith('.md') || fileName.endsWith('.mdx'))) {
//       // final fileUrl = Uri.parse(file['download_url']);
//       print('DOWNLOADING: $cleanedFileName $url');
//       // final fileResponse = await http.get(fileUrl);
//       // if (fileResponse.statusCode == 200) {
//       //   print('FILE:\n${fileResponse.body}');
//       // }
//     }
//   }
// }

String _cleanFileName(String fileName) {
  final prefixRegex = RegExp(r'^\d+-');
  final suffixRegex = RegExp(r'\.(md|mdx)$');
  final cleanedName =
      fileName.replaceFirst(prefixRegex, '').replaceFirst(suffixRegex, '');

  if (cleanedName == 'index') return '';
  return cleanedName;
}
