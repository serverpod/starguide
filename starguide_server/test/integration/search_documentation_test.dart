import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:jev_dart/jev_dart.dart';
import 'package:serverpod/serverpod.dart';
import 'package:starguide_server/src/business/document_index.dart';
import 'package:starguide_server/src/business/search.dart';
import 'package:starguide_server/src/generated/protocol.dart';
import 'package:starguide_server/src/generative_ai/jev.dart' as starguide;
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

RAGDocument _document(String url, {String domain = 'Serverpod framework'}) {
  return RAGDocument(
    embedding: Vector(List<double>.filled(768, 0)),
    fetchTime: DateTime.now(),
    sourceUrl: Uri.parse(url),
    content: 'Content of $url',
    title: url.split('/').last,
    embeddingSummary: 'Summary',
    shortDescription: 'Description',
    type: RAGDocumentType.documentation,
    domain: domain,
  );
}

/// A choice answer where [choice] gets [probability] and the rest is spread
/// over the other options.
Map<String, Object?> _choiceAnswer(
  List<String> options,
  String choice,
  double probability,
) {
  final rest = options.length == 1
      ? 0.0
      : (1 - probability) / (options.length - 1);
  return {
    'type': 'choice',
    'choice': choice,
    'confidence': probability,
    'probabilities': {
      for (final option in options)
        option: option == choice ? probability : rest,
    },
  };
}

http.Response _jsonResponse(Map<String, Object?> answers) {
  return http.Response(
    jsonEncode({
      'model': 'jev-test',
      'answers': answers,
      'usage': {'input_tokens': 10, 'output_tokens': 1},
    }),
    200,
    headers: {'content-type': 'application/json'},
  );
}

void main() {
  withServerpod('Given documents in the index', (sessionBuilder, endpoints) {
    late Session session;
    late List<http.Request> requests;
    late Map<String, String> chosenPerGroup;
    late Set<String> failingGroups;

    setUp(() async {
      session = sessionBuilder.build();
      await DocumentIndexCache.invalidate(session);
      requests = [];
      chosenPerGroup = {};
      failingGroups = {};

      await RAGDocument.db.insert(session, [
        _document('https://docs.serverpod.dev/concepts/models'),
        _document('https://docs.serverpod.dev/concepts/database'),
        _document(
          'https://docs.serverpod.dev/cloud/deploy',
          domain: 'Serverpod Cloud',
        ),
        _document(
          'https://docs.serverpod.dev/cloud/secrets',
          domain: 'Serverpod Cloud',
        ),
      ]);

      // Answers each request from the chosen option of its question. A
      // group is keyed by its first option: 'database' for the framework
      // docs and 'deploy' for the cloud docs.
      final client = MockClient((request) async {
        requests.add(request);
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        final questions = body['questions'] as Map<String, dynamic>;
        final name = questions.keys.single;
        final criteria = (questions[name]['criteria'] as Map).keys
            .cast<String>()
            .toList();
        final groupKey = name == 'domain'
            ? 'domain'
            : criteria.first.split('/').first;
        if (failingGroups.contains(groupKey)) {
          return http.Response('{"error":"boom"}', 500);
        }
        final chosen = chosenPerGroup[groupKey] ?? 'none';
        return _jsonResponse({name: _choiceAnswer(criteria, chosen, 0.8)});
      });
      starguide.Jev.instance = starguide.Jev(
        TypeSafeClient(apiKey: 'test', httpClient: client),
      );
    });

    tearDown(() {
      starguide.Jev.instance = null;
    });

    test(
      'when picking pages then one request per group is sent at once',
      () async {
        chosenPerGroup['domain'] = 'Serverpod Cloud';
        chosenPerGroup['deploy'] = 'secrets';

        final documents = await searchDocumentation(
          session,
          [],
          'How do I set a secret?',
        );

        expect(requests, hasLength(3));
        expect(requests.map((r) => r.url.path).toSet(), {'/v1/systemone'});
        for (final request in requests) {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['state'], {
            'conversation': [],
            'question': 'How do I set a secret?',
          });
        }

        // The chosen page of the chosen domain first, then the rest of that
        // domain, then the other domain's pages, which score the same.
        final paths = documents.map((d) => d.sourceUrl.path).toList();
        expect(paths.take(2), ['/cloud/secrets', '/cloud/deploy']);
        expect(paths.skip(2).toSet(), {
          '/concepts/database',
          '/concepts/models',
        });
      },
    );

    test('when a group request fails then its pages are skipped', () async {
      chosenPerGroup['domain'] = 'Serverpod framework';
      chosenPerGroup['database'] = 'models';
      failingGroups.add('deploy');

      final documents = await searchDocumentation(session, [], 'Models?');

      expect(documents.map((d) => d.sourceUrl.path), [
        '/concepts/models',
        '/concepts/database',
      ]);
    });

    test(
      'when every group request fails then an exception is thrown',
      () async {
        failingGroups.addAll(['deploy', 'database']);

        await expectLater(
          searchDocumentation(session, [], 'Anything?'),
          throwsA(isA<GenerativeAiException>()),
        );
      },
    );

    test('when judging the picked pages then the content is sent', () async {
      final documents = await RAGDocument.db.find(session, limit: 2);
      final jev = starguide.Jev.instance!;
      requests.clear();

      // Answer the noul question regardless of its content.
      final client = MockClient((request) async {
        requests.add(request);
        return _jsonResponse({
          'answerable': {'type': 'noul', 'noul': 0.9},
        });
      });
      starguide.Jev.instance = starguide.Jev(
        TypeSafeClient(apiKey: 'test', httpClient: client),
      );

      final probability = await starguide.Jev.instance!.canAnswer(
        session,
        [],
        'Question?',
        documents,
      );
      expect(probability, 0.9);
      final body = jsonDecode(requests.single.body) as Map<String, dynamic>;
      final pages = body['state']['pages'] as List;
      expect(pages, hasLength(2));
      expect(pages.first['content'], documents.first.content);
      expect(jev, isNotNull);
    });

    test('when judging an answer then the outcome is returned', () async {
      final client = MockClient((request) async {
        return _jsonResponse({
          'outcome': _choiceAnswer(
            ['answered', 'notAnswered', 'unsure'],
            'notAnswered',
            0.7,
          ),
        });
      });
      starguide.Jev.instance = starguide.Jev(
        TypeSafeClient(apiKey: 'test', httpClient: client),
      );

      final judgement = await starguide.Jev.instance!.judgeAnswer(
        session,
        [],
        'Question?',
        'I do not know.',
      );
      expect(judgement.outcome, AnswerOutcome.notAnswered);
      expect(judgement.confidence, 0.7);
    });
  });
}
