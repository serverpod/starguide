// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:starguide_server/src/business/data_sources/github_docs.dart';

// Future<void> fetchAnsweredGithubDiscussions({
//   required String owner,
//   required String repo,
//   required String categoryId,
// }) async {
//   final query = '''
//     query {
//       repository(owner: "$owner", name: "$repo") {
//         discussions(first: 50, categoryId: "$categoryId") {
//           nodes {
//             title
//             url
//             answerChosenAt
//             body
//             answer {
//               body
//               createdAt
//             }
//           }
//         }
//       }
//     }
//   ''';

//   final response = await http.post(
//     Uri.parse('https://api.github.com/graphql'),
//     headers: {
//       'Authorization': 'Bearer $githubToken',
//       'Content-Type': 'application/json',
//     },
//     body: jsonEncode({'query': query}),
//   );

//   final data = jsonDecode(response.body);
//   final discussions = data['data']['repository']['discussions']['nodes'];

//   for (var discussion in discussions) {
//     if (discussion['answerChosenAt'] != null) {
//       print('${discussion['title']}: ${discussion['url']}');
//       print(discussion['body']);
//     }
//   }
// }

// Future<String?> fetchGithubDiscussionCategoryId({
//   required String owner,
//   required String repo,
//   required String name,
// }) async {
//   final query = '''
//     query {
//       repository(owner: "$owner", name: "$repo") {
//         discussionCategories(first: 50) {
//           nodes {
//             id
//             name
//           }
//         }
//       }
//     }
//   ''';

//   final response = await http.post(
//     Uri.parse('https://api.github.com/graphql'),
//     headers: {
//       'Authorization': 'Bearer $githubToken',
//       'Content-Type': 'application/json',
//     },
//     body: jsonEncode({'query': query}),
//   );

//   final data = jsonDecode(response.body);
//   final categories =
//       data['data']['repository']['discussionCategories']['nodes'];

//   for (var category in categories) {
//     if (category['name'] == name) {
//       return category['id'];
//     }
//   }
//   return null;
// }
