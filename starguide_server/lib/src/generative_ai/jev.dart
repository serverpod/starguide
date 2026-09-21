import 'package:jev_dart/jev_dart.dart' as jev;
import 'package:serverpod/serverpod.dart';
import 'package:starguide_server/src/business/document_index.dart';
import 'package:starguide_server/src/generated/protocol.dart';

/// A page picked from the [DocumentIndex], with the score it was ranked by.
class PickedDocument {
  const PickedDocument({
    required this.documentId,
    required this.label,
    required this.score,
  });

  final int documentId;
  final String label;

  /// The probability that the page answers the question, as the product of
  /// the probability of its domain and its probability within its group.
  final double score;
}

/// Jev's judgement of an answer.
typedef AnswerJudgement = ({AnswerOutcome outcome, double confidence});

/// Asks Jev, TypeSafe's System One model, the typed questions Starguide
/// needs answered while answering a question: which pages to read, whether
/// they contain the answer, and whether the generated answer resolved the
/// question.
///
/// Jev only answers typed questions, with a probability for every option, so
/// the pages of the [DocumentIndex] are offered as options of choice
/// questions, one request per group, and ranked by their probabilities.
class Jev {
  /// The name of the password holding the TypeSafe API key.
  static const passwordKey = 'typesafeAPIKey';

  /// How many pages [pickDocuments] returns by default.
  static const pickCount = 5;

  /// The probability from [canAnswer] at or above which the picked pages are
  /// trusted to contain the answer, so no further search is needed.
  static const answerGateThreshold = 0.7;

  /// The most characters of a page's content sent to [canAnswer], so that a
  /// few long pages cannot blow up the request.
  static const maxPageCharacters = 12000;

  static Jev? _instance;

  /// The shared instance, or null if the [passwordKey] password is not set.
  static Jev? get instance {
    if (_instance != null) return _instance;
    final apiKey = Serverpod.instance.getPassword(passwordKey);
    if (apiKey == null) return null;
    return _instance = Jev(
      jev.TypeSafeClient(apiKey: apiKey, logLevel: jev.LogLevel.warn),
    );
  }

  /// Replaces the shared instance, for tests. Set to null to restore it.
  static set instance(Jev? value) => _instance = value;

  Jev(this._client);

  final jev.TypeSafeClient _client;

  /// Picks the [count] pages of [index] most likely to answer [question],
  /// best first. Pages that Jev gives no probability are left out, so fewer
  /// pages may be returned.
  ///
  /// One request is sent per group of the index, plus one asking which
  /// domain the question is about, all at once. A page's score is the
  /// probability of its domain times its probability within its group. A
  /// failed request is logged and its group skipped. Throws a
  /// [GenerativeAiException] if every request fails.
  Future<List<PickedDocument>> pickDocuments(
    Session session,
    DocumentIndex index,
    List<ChatMessage> conversation,
    String question, {
    int count = pickCount,
  }) async {
    if (index.groups.isEmpty) return const [];

    final stopwatch = Stopwatch()..start();
    final state = _state(conversation, question);

    final results = await Future.wait([
      _tryAsk(session, 'domain', state, {
        'domain': jev.choice(_domainInstructions, index.domainCriteria),
      }),
      for (final group in index.groups)
        _tryAsk(session, group.name, state, {
          'page': jev.choice(_pageInstructions, group.criteria),
        }),
    ]);
    final domainResult = results.first;
    final groupResults = results.skip(1).toList();

    if (groupResults.every((result) => result == null)) {
      throw GenerativeAiException(
        message: 'Every request to Jev for picking pages failed.',
      );
    }

    // Without the domain answer, every domain is weighted the same.
    final domainAnswer = domainResult?.choice('domain');
    final domainProbabilities = domainAnswer?.probabilities ?? const {};

    final picks = <PickedDocument>[];
    for (var i = 0; i < index.groups.length; i++) {
      final group = index.groups[i];
      final result = groupResults[i];
      if (result == null) continue;

      final domainProbability = domainProbabilities[group.domain] ?? 1.0;
      for (final option in result.choice('page').probabilities.entries) {
        final entry = index.entryFor(group, option.key);
        if (entry == null) continue;
        picks.add(
          PickedDocument(
            documentId: entry.documentId,
            label: '${group.name}/${entry.label}',
            score: domainProbability * option.value,
          ),
        );
      }
    }
    picks.sort((a, b) => b.score.compareTo(a.score));
    final picked = picks.take(count).toList();

    session.log(
      'Jev picked pages in ${stopwatch.elapsedMilliseconds}ms, '
      'domain: ${domainAnswer?.choice ?? 'unknown'} '
      '(${_percent(domainAnswer?.confidence)} confidence), '
      'tokens: ${_usage(results)}, '
      'pages: ${picked.map((p) => '${p.label} ${_percent(p.score)}').join(', ')}',
      level: LogLevel.debug,
    );
    return picked;
  }

  /// The probability that [documents] contain what is needed to answer
  /// [question]. Throws a [GenerativeAiException] if the request fails.
  Future<double> canAnswer(
    Session session,
    List<ChatMessage> conversation,
    String question,
    List<RAGDocument> documents,
  ) async {
    final stopwatch = Stopwatch()..start();
    final state = {
      ..._state(conversation, question),
      'pages': [
        for (final document in documents)
          {
            'title': document.title,
            'url': document.sourceUrl.toString(),
            'content': _truncate(document.content),
          },
      ],
    };

    final result = await _ask(state, {
      'answerable': jev.noul(_answerableInstructions, {
        'true': 'A page states the answer or the steps to take',
        'false':
            'The pages are only on a related topic, or the question is '
            'about a bug, an error message, or a case the pages do not '
            'cover',
      }),
    });
    final probability = result.noul('answerable').noul;

    session.log(
      'Jev judged that the ${documents.length} picked pages answer the '
      'question with ${_percent(probability)} probability in '
      '${stopwatch.elapsedMilliseconds}ms, tokens: ${_usage([result])}',
      level: LogLevel.debug,
    );
    return probability;
  }

  /// Whether [answer] resolved [question]. Throws a [GenerativeAiException]
  /// if the request fails.
  Future<AnswerJudgement> judgeAnswer(
    Session session,
    List<ChatMessage> conversation,
    String question,
    String answer,
  ) async {
    final stopwatch = Stopwatch()..start();
    final state = {..._state(conversation, question), 'answer': answer};

    final result = await _ask(state, {
      'outcome': jev.choice(_outcomeInstructions, {
        AnswerOutcome.answered.name:
            'The answer directly addresses the question with concrete '
            'information',
        AnswerOutcome.notAnswered.name:
            'The answer says the information is not available, asks the '
            'user to look elsewhere, or does not address what was asked',
        AnswerOutcome.unsure.name:
            'The answer is partial, hedged, or may be wrong',
      }),
    });
    final choice = result.choice('outcome');
    final judgement = (
      outcome: AnswerOutcome.values.byName(choice.choice),
      confidence: choice.confidence,
    );

    session.log(
      'Jev judged the answer ${judgement.outcome.name} with '
      '${_percent(judgement.confidence)} confidence in '
      '${stopwatch.elapsedMilliseconds}ms, tokens: ${_usage([result])}',
      level: LogLevel.debug,
    );
    return judgement;
  }

  static const _domainInstructions = 'Which product is the question about?';

  static const _pageInstructions =
      'Which page most likely contains the answer to the question?';

  static const _answerableInstructions =
      'The pages contain the information needed to answer the question';

  static const _outcomeInstructions = 'Did the answer resolve the question?';

  /// The conversation so far and the new question, as the state every
  /// request is about.
  static Map<String, Object?> _state(
    List<ChatMessage> conversation,
    String question,
  ) {
    return {
      'conversation': [
        for (final message in conversation)
          {
            'role': message.type == ChatMessageType.user ? 'user' : 'assistant',
            'message': message.message,
          },
      ],
      'question': question,
    };
  }

  /// Sends one request, wrapping failures in a [GenerativeAiException].
  Future<jev.SystemOneResult> _ask(
    Map<String, Object?> state,
    Map<String, jev.Question> questions,
  ) async {
    try {
      return await _client.systemOne(state: state, questions: questions);
    } on Exception catch (e) {
      throw GenerativeAiException(message: 'Jev request failed: $e');
    }
  }

  /// Sends one request, logging a failure and returning null instead of
  /// throwing.
  Future<jev.SystemOneResult?> _tryAsk(
    Session session,
    String name,
    Map<String, Object?> state,
    Map<String, jev.Question> questions,
  ) async {
    try {
      return await _client.systemOne(state: state, questions: questions);
    } on Exception catch (e) {
      session.log('Jev request "$name" failed: $e', level: LogLevel.warning);
      return null;
    }
  }

  static String _truncate(String content) => content.length <= maxPageCharacters
      ? content
      : content.substring(0, maxPageCharacters);

  static String _percent(double? value) =>
      value == null ? '?' : '${(value * 100).round()}%';

  /// The tokens used by [results], as `in/out`.
  static String _usage(List<jev.SystemOneResult?> results) {
    var input = 0;
    var output = 0;
    for (final result in results.nonNulls) {
      input += result.usage.inputTokens;
      output += result.usage.outputTokens;
    }
    return '$input/$output';
  }
}
