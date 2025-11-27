import 'package:starguide_server/src/business/data_fetcher.dart';
import 'package:starguide_server/src/business/data_sources/github_discussions.dart';
import 'package:starguide_server/src/business/data_sources/github_docs.dart';

late final String latestServerpodVersion;

Future<void> configureDataFetcher() async {
  final serverpodDocs = await GithubDocsDataSource.versioned(
    owner: 'serverpod',
    repo: 'serverpod_docs',
    basePath: '/',
    referenceUrl: Uri.parse('https://docs.serverpod.dev'),
    branch: 'main',
    domain: 'Serverpod framework',
  );
  latestServerpodVersion = serverpodDocs.latestVersion!;

  final serverpodDiscussions = GithubDiscussionsDataSource(
    owner: 'serverpod',
    repo: 'serverpod',
    categoryName: 'Q&A',
    domain: 'Serverpod',
  );

  final relicDocs = GithubDocsDataSource(
    owner: 'serverpod',
    repo: 'relic',
    basePath: 'doc/site/docs',
    referenceUrl: Uri.parse('https://docs.dartrelic.dev'),
    branch: 'main',
    domain: 'Relic',
  );

  final dataSources = [
    serverpodDocs,
    serverpodDiscussions,
    relicDocs,
  ];

  DataFetcher.configure(dataSources);
}
