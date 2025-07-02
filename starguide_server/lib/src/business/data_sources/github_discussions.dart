import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:serverpod/serverpod.dart';
import 'package:starguide_server/src/business/data_fetcher.dart';
import 'package:starguide_server/src/business/data_source.dart';

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
  Stream<RawRAGDocuement> fetch(
    Session session,
    DataFetcher fetcher, {
    String? path,
    Uri? referenceUrl,
  }) async* {
    final githubToken = Serverpod.instance.getPassword('githubToken')!;

    final categoryId = await _fetchGithubDiscussionCategoryId(
      owner: owner,
      repo: repo,
      name: categoryName,
    );

    if (categoryId == null) {
      print('Category "$categoryName" not found for repository $owner/$repo');
      return;
    }

    String? cursor;
    bool hasNextPage = true;
    int totalFetched = 0;

    while (hasNextPage) {
      final query = '''
      query(\$cursor: String) {
        repository(owner: "$owner", name: "$repo") {
          discussions(first: 100, categoryId: "$categoryId", after: \$cursor) {
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
        print('GitHub API error: ${response.statusCode} - ${response.body}');
        break;
      }

      final data = jsonDecode(response.body);

      if (data['errors'] != null) {
        print('GraphQL errors: ${data['errors']}');
        break;
      }

      final discussionsData = data['data']['repository']['discussions'];
      final discussions = discussionsData['nodes'];
      final pageInfo = discussionsData['pageInfo'];

      hasNextPage = pageInfo['hasNextPage'] ?? false;
      cursor = pageInfo['endCursor'];

      totalFetched += discussions.length as int;
      print('Fetched ${discussions.length} discussions (total: $totalFetched)');

      for (var discussion in discussions) {
        if (discussion['answerChosenAt'] != null) {
          print('${discussion['title']}: ${discussion['url']}');
        }
      }

      // Add a small delay to avoid rate limiting
      if (hasNextPage) {
        await Future.delayed(Duration(seconds: 1));
      }
    }

    print('Finished fetching discussions. Total fetched: $totalFetched');
  }

  Future<String?> _fetchGithubDiscussionCategoryId({
    required String owner,
    required String repo,
    required String name,
  }) async {
    final githubToken = Serverpod.instance.getPassword('githubToken')!;

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

    final data = jsonDecode(response.body);
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
