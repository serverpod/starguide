import 'package:starguide_server/src/business/data_fetcher.dart';
import 'package:starguide_server/src/business/data_sources/github_docs.dart';

DataFetcher setupDataFetcher() {
  return DataFetcher(dataSources: [
    GithubDocsDataSource(
      owner: 'serverpod',
      repo: 'serverpod_docs',
      basePath: 'docs',
      referenceUrl: Uri.parse('https://docs.serverpod.dev'),
      branch: 'main',
    ),
  ]);
}

// TODO: Github Discussions
// await fetchGithubDocs(
//   owner: 'serverpod',
//   repo: 'serverpod_docs',
//   basePath: 'docs',
//   referenceUrl: Uri.parse('https://docs.serverpod.dev'),
//   branch: 'main',
// );

// final categoryId = await fetchGithubDiscussionCategoryId(
//   owner: 'serverpod',
//   repo: 'serverpod',
//   name: 'Q&A',
// );
// print('Q&A category id: $categoryId');

// await fetchAnsweredGithubDiscussions(
//   owner: 'serverpod',
//   repo: 'serverpod',
//   categoryId: categoryId!,
// );
