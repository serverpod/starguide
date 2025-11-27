import 'package:starguide_server/src/business/data_fetcher.dart';
import 'package:starguide_server/src/business/data_sources/github_discussions.dart';
import 'package:starguide_server/src/business/data_sources/github_docs.dart';

Future<void> configureDataFetcher() async {
  final dataSources = [
    await GithubDocsDataSource.versioned(
      owner: 'serverpod',
      repo: 'serverpod_docs',
      basePath: '/',
      referenceUrl: Uri.parse('https://docs.serverpod.dev'),
      branch: 'main',
    ),
    GithubDiscussionsDataSource(
      owner: 'serverpod',
      repo: 'serverpod',
      categoryName: 'Q&A',
    ),
  ];

  DataFetcher.configure(dataSources);
}
