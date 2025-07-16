import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:serverpod/serverpod.dart';
import 'package:starguide_server/src/business/data_fetcher.dart';
import 'package:starguide_server/src/business/data_source.dart';
import 'package:starguide_server/src/business/data_source_exception.dart';
import 'package:starguide_server/src/generated/protocol.dart';

class GithubDiscussionsDataSource implements DataSource {
  final String owner;
  final String repo;
  final String categoryName;

  GithubDiscussionsDataSource({
    required this.owner,
    required this.repo,
    required this.categoryName,
  });

  @override
  String get name => 'GithubDiscussions';

  @override
  Stream<RawRAGDocument> fetch(
    Session session,
    DataFetcher fetcher, {
    String? path,
    Uri? referenceUrl,
  }) async* {
    final githubToken = Serverpod.instance.getPassword('githubToken');
    if (githubToken == null) {
      throw DataSourceException(
        'GitHub token not configured',
      );
    }

    // Check GitHub API quota
    final quotaResponse = await http.post(
      Uri.parse('https://api.github.com/graphql'),
      headers: {
        'Authorization': 'Bearer $githubToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'query': '''
          query {
            rateLimit {
              limit
              remaining
              resetAt
            }
          }
        ''',
      }),
    );

    if (quotaResponse.statusCode != 200) {
      throw DataSourceException(
        'Failed to check GitHub API quota',
        statusCode: quotaResponse.statusCode,
      );
    }

    final quotaData = jsonDecode(quotaResponse.body);

    if (quotaData['errors'] != null) {
      throw DataSourceException(
        'Failed to check GitHub API quota: ${quotaData['errors']}',
      );
    }

    final remaining = quotaData['data']['rateLimit']['remaining'];
    final limit = quotaData['data']['rateLimit']['limit'];
    final resetAt = quotaData['data']['rateLimit']['resetAt'];

    session.log(
      'GitHub API quota - Remaining: $remaining/$limit, Resets at: $resetAt',
    );

    final categoryId = await _fetchGithubDiscussionCategoryId(
      owner: owner,
      repo: repo,
      name: categoryName,
    );

    if (categoryId == null) {
      throw DataSourceException(
        'Discussion category "$categoryName" not found for repository $owner/$repo',
      );
    }

    String? cursor;
    bool hasNextPage = true;
    int totalFetched = 0;

    while (hasNextPage) {
      final query = '''
      query(\$cursor: String) {
        repository(owner: "$owner", name: "$repo") {
          discussions(first: 50, categoryId: "$categoryId", after: \$cursor) {
            pageInfo {
              hasNextPage
              endCursor
            }
            nodes {
              title
              url
              answerChosenAt
              body
              answer {
                body
                createdAt
              }
            }
          }
        }
      }
    ''';

      final variables = cursor != null ? {'cursor': cursor} : {};

      final response = await http.post(
        Uri.parse('https://api.github.com/graphql'),
        headers: {
          'Authorization': 'Bearer $githubToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'query': query,
          'variables': variables,
        }),
      );

      if (response.statusCode != 200) {
        throw DataSourceException(
          'GitHub API request failed: ${response.body}',
          statusCode: response.statusCode,
        );
      }

      final data = jsonDecode(response.body);

      if (data['errors'] != null) {
        throw DataSourceException(
          'GraphQL query failed: ${data['errors']}',
        );
      }

      final discussionsData = data['data']['repository']['discussions'];
      final discussions = discussionsData['nodes'];
      final pageInfo = discussionsData['pageInfo'];

      hasNextPage = pageInfo['hasNextPage'] ?? false;
      cursor = pageInfo['endCursor'];

      totalFetched += discussions.length as int;
      session.log(
        'Fetched ${discussions.length} discussions (total: $totalFetched)',
      );

      for (var discussion in discussions) {
        if (discussion['answerChosenAt'] != null) {
          final title = discussion['title'] ?? 'GitHub Discussion';
          final url = Uri.parse(discussion['url']!);
          final question = discussion['body'] ?? 'No question content';
          final answer = discussion['answer']?['body'] ?? 'No answer content';

          if (await fetcher.shouldFetchUrl(session, url)) {
            yield RawRAGDocument(
              sourceUrl: url,
              document:
                  'TITLE: $title\n\nQUESTION:\n$question\n\nANSWER:\n$answer',
              dataSourceType: DataSourceType.markdown,
              documentType: RAGDocumentType.discussion,
              title: title,
            );
          }
        }
      }

      // Add a small delay to avoid rate limiting
      if (hasNextPage) {
        await Future.delayed(Duration(seconds: 1));
      }
    }

    session.log('Finished fetching discussions. Total fetched: $totalFetched');
  }

  Future<String?> _fetchGithubDiscussionCategoryId({
    required String owner,
    required String repo,
    required String name,
  }) async {
    final githubToken = Serverpod.instance.getPassword('githubToken');
    if (githubToken == null) {
      throw DataSourceException(
        'GitHub token not configured',
      );
    }

    final query = '''
    query {
      repository(owner: "$owner", name: "$repo") {
        discussionCategories(first: 50) {
          nodes {
            id
            name
          }
        }
      }
    }
  ''';

    final response = await http.post(
      Uri.parse('https://api.github.com/graphql'),
      headers: {
        'Authorization': 'Bearer $githubToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'query': query}),
    );

    if (response.statusCode != 200) {
      throw DataSourceException(
        'Failed to fetch discussion categories: ${response.body}',
        statusCode: response.statusCode,
      );
    }

    final data = jsonDecode(response.body);

    if (data['errors'] != null) {
      throw DataSourceException(
        'Failed to fetch discussion categories: ${data['errors']}',
      );
    }

    final categories =
        data['data']['repository']['discussionCategories']['nodes'];

    for (var category in categories) {
      if (category['name'] == name) {
        return category['id'];
      }
    }
    return null;
  }
}
