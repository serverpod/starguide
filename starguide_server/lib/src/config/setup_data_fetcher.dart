import 'package:starguide_server/src/business/data_fetcher.dart';
import 'package:starguide_server/src/business/data_sources/github_discussions.dart';
import 'package:starguide_server/src/business/data_sources/github_docs.dart';
import 'package:starguide_server/src/business/data_sources/website.dart';
import 'package:starguide_server/src/generated/protocol.dart';

late final String latestServerpodVersion;

Future<void> configureDataFetcher() async {
  final serverpodDocs = await GithubDocsDataSource.versioned(
    owner: 'serverpod',
    repo: 'serverpod_docs',
    basePath: '/',
    referenceUrl: Uri.parse('https://docs.serverpod.dev'),
    branch: 'main',
    domain: 'Serverpod framework',
    description:
        'The open source backend framework for Flutter, written in Dart, '
        'with its server, ORM, migrations, authentication, and client '
        'code generation.',
  );
  latestServerpodVersion = serverpodDocs.latestVersion!;

  final serverpodDiscussions = GithubDiscussionsDataSource(
    owner: 'serverpod',
    repo: 'serverpod',
    categoryName: 'Q&A',
    domain: 'Serverpod',
    description: 'Questions and answers about Serverpod on GitHub.',
  );

  final serverpodCloudDocs = GithubDocsDataSource(
    owner: 'serverpod',
    repo: 'serverpod_docs',
    basePath: 'cloud_docs',
    referenceUrl: Uri.parse('https://docs.serverpod.dev/cloud'),
    branch: 'main',
    domain: 'Serverpod Cloud',
    description:
        'The hosting service for Serverpod servers, with its scloud command '
        'line tool, deployments, databases, secrets, custom domains, and '
        'billing.',
  );

  final relicDocs = GithubDocsDataSource(
    owner: 'serverpod',
    repo: 'relic',
    basePath: 'doc/site/docs',
    referenceUrl: Uri.parse('https://docs.dartrelic.dev'),
    branch: 'main',
    domain: 'Relic',
    description:
        'The low-level web server for Dart that Serverpod is built on, with '
        'routing, middleware, requests, responses, and static files.',
  );

  // Pages on serverpod.dev are listed in the table of contents together with
  // the documentation, while blog posts are found by embedding search like
  // the discussions.
  final serverpodSite = WebsiteDataSource(
    indexUrls: [
      Uri.parse('https://serverpod.dev/markdown/feature'),
      Uri.parse('https://serverpod.dev/markdown/for'),
      Uri.parse('https://serverpod.dev/markdown/compare'),
    ],
    domain: 'Serverpod',
    documentType: RAGDocumentType.site,
    description:
        'The Serverpod website, which presents the features and compares '
        'Serverpod with other frameworks and services.',
  );

  final serverpodBlog = WebsiteDataSource(
    indexUrls: [Uri.parse('https://serverpod.dev/markdown/blog')],
    domain: 'Serverpod',
    documentType: RAGDocumentType.blog,
    description: 'Blog posts on the Serverpod website.',
  );

  final dataSources = [
    serverpodDocs,
    serverpodCloudDocs,
    serverpodDiscussions,
    relicDocs,
    serverpodSite,
    serverpodBlog,
  ];

  DataFetcher.configure(dataSources);
}
