import 'package:starguide_server/src/business/data_sources/github_discussions.dart';
import 'package:starguide_server/src/business/data_sources/github_docs.dart';
import 'package:starguide_server/src/business/generative_ai.dart';

class DataRetriever {
  Future<void> retrieve() async {
    print('FETCH DATA');

    final githubDocs = GithubDocsDataSource(
      owner: 'serverpod',
      repo: 'serverpod_docs',
      basePath: 'docs',
      referenceUrl: Uri.parse('https://docs.serverpod.dev'),
      branch: 'main',
    );

    // await for (var doc in githubDocs.fetch()) {
    //   print('DOC: ${doc.sourceUrl}');
    // }

    final genAi = GenerativeAi();

    print('FETCH DONE');

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
  }
}
