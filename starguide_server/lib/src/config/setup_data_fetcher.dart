import 'package:starguide_server/src/business/data_fetcher.dart';
import 'package:starguide_server/src/business/data_sources/github_discussions.dart';
import 'package:starguide_server/src/business/data_sources/github_docs.dart';

void configureDataFetcher() {
  DataFetcher.configure(
    [
      GithubDocsDataSource(
        owner: 'serverpod',
        repo: 'serverpod_docs',
        basePath: 'docs',
        referenceUrl: Uri.parse('https://docs.serverpod.dev'),
        branch: 'main',
      ),
      GithubDiscussionsDataSource(
        owner: 'serverpod',
        repo: 'serverpod',
        categoryName: 'Q&A',
      ),
    ],
  );
}
