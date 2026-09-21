import 'package:serverpod/serverpod.dart';
import 'dart:convert';

import 'package:starguide_server/src/business/admin_stats.dart';
import 'package:starguide_server/src/business/document_index.dart';
import 'package:starguide_server/src/generated/protocol.dart';

/// Endpoint backing the admin interface. Only users with the admin scope,
/// which is granted to serverpod.dev accounts, can call it.
class AdminEndpoint extends Endpoint {
  static const _maxPageSize = 100;

  /// Longest first question included in a chat session summary.
  static const _maxFirstQuestionLength = 200;

  @override
  bool get requireLogin => true;

  @override
  Set<Scope> get requiredScopes => {Scope.admin};

  /// Returns the statistics shown on the overview.
  Future<AdminOverview> getOverview(Session session) {
    return AdminStats.overview(session);
  }

  /// Lists the RAG documents used to answer questions, most recently fetched
  /// first. The optional filters narrow the list by document type, domain,
  /// and a case-insensitive search of the title.
  Future<AdminDocumentPage> listDocuments(
    Session session, {
    required int page,
    required int pageSize,
    RAGDocumentType? type,
    String? domain,
    String? search,
  }) async {
    final limit = pageSize.clamp(1, _maxPageSize);
    final offset = page.clamp(0, 1 << 30) * limit;

    Expression where(RAGDocumentTable t) {
      Expression expression = Constant.bool(true);
      if (type != null) expression = expression & t.type.equals(type);
      if (domain != null) expression = expression & t.domain.equals(domain);
      if (search != null && search.trim().isNotEmpty) {
        expression = expression & t.title.ilike('%${search.trim()}%');
      }
      return expression;
    }

    final totalCount = await RAGDocument.db.count(session, where: where);
    final documents = await RAGDocument.db.find(
      session,
      where: where,
      orderBy: (t) => t.fetchTime.desc(),
      limit: limit,
      offset: offset,
    );

    return AdminDocumentPage(
      documents: [
        for (final document in documents)
          AdminDocumentSummary(
            id: document.id!,
            title: document.title,
            sourceUrl: document.sourceUrl,
            type: document.type,
            domain: document.domain,
            fetchTime: document.fetchTime,
            shortDescription: document.shortDescription,
            contentLength: document.content.length,
          ),
      ],
      totalCount: totalCount,
      page: page,
      pageSize: limit,
    );
  }

  /// Lists the distinct domains of the stored documents, for filtering.
  Future<List<String>> listDocumentDomains(Session session) async {
    final rows = await session.db.unsafeQuery(
      'SELECT DISTINCT domain FROM rag_document ORDER BY domain',
    );
    return [for (final row in rows) row[0] as String];
  }

  /// Returns a document with its content. Throws if it does not exist.
  Future<AdminDocumentDetail> getDocument(Session session, int id) async {
    final document = await RAGDocument.db.findById(session, id);
    if (document == null) {
      throw Exception('Document $id not found.');
    }
    return AdminDocumentDetail(
      id: document.id!,
      title: document.title,
      sourceUrl: document.sourceUrl,
      type: document.type,
      domain: document.domain,
      fetchTime: document.fetchTime,
      shortDescription: document.shortDescription,
      embeddingSummary: document.embeddingSummary,
      content: document.content,
    );
  }

  /// Returns the document index as it is cached for Jev, with the payloads
  /// of its questions. Builds it if it is not cached.
  Future<AdminDocumentIndex> getDocumentIndex(Session session) async {
    return _describeIndex(await DocumentIndexCache.get(session));
  }

  /// Rebuilds the document index from the database and returns it.
  Future<AdminDocumentIndex> rebuildDocumentIndex(Session session) async {
    await DocumentIndexCache.invalidate(session);
    return _describeIndex(await DocumentIndexCache.get(session));
  }

  static AdminDocumentIndex _describeIndex(DocumentIndex index) {
    final domainPayload = jsonEncode(index.domainCriteria);
    final groupPayloads = [
      for (final group in index.groups) jsonEncode(group.criteria),
    ];
    final totalSizeInBytes =
        index.sizeInBytes + utf8.encode(domainPayload).length;
    return AdminDocumentIndex(
      index: index,
      expiresAt: index.generatedAt.add(DocumentIndexCache.lifetime),
      entryCount: index.entryCount,
      totalSizeInBytes: totalSizeInBytes,
      estimatedTokens: (totalSizeInBytes / 4).round(),
      domainPayload: domainPayload,
      groupPayloads: groupPayloads,
    );
  }

  /// Lists chat sessions, newest first. With [goodAnswer] set, only sessions
  /// with that vote are listed. With [votedOnly], unvoted sessions are
  /// skipped. With [outcomes], only sessions whose latest answer Jev judged
  /// with one of those outcomes are listed. The default lists sessions where
  /// the answer was voted poor.
  Future<AdminChatSessionPage> listChatSessions(
    Session session, {
    required int page,
    required int pageSize,
    bool? goodAnswer = false,
    bool votedOnly = false,
    List<AnswerOutcome>? outcomes,
  }) async {
    final limit = pageSize.clamp(1, _maxPageSize);
    final offset = page.clamp(0, 1 << 30) * limit;

    Expression where(ChatSessionTable t) {
      Expression expression = Constant.bool(true);
      if (goodAnswer != null) {
        expression = expression & t.goodAnswer.equals(goodAnswer);
      } else if (votedOnly) {
        expression = expression & t.goodAnswer.notEquals(null);
      }
      if (outcomes != null) {
        expression = expression & t.answerOutcome.inSet(outcomes.toSet());
      }
      return expression;
    }

    final totalCount = await ChatSession.db.count(session, where: where);
    final sessions = await ChatSession.db.find(
      session,
      where: where,
      orderBy: (t) => t.createdAt.desc(),
      limit: limit,
      offset: offset,
    );

    // Load the conversations of the listed sessions in one query.
    final sessionIds = {for (final s in sessions) s.id!};
    final messages = sessionIds.isEmpty
        ? const <ChatMessage>[]
        : await ChatMessage.db.find(
            session,
            where: (t) => t.chatSessionId.inSet(sessionIds),
            orderBy: (t) => t.id,
          );
    final messageCounts = <int, int>{};
    final firstQuestions = <int, String>{};
    for (final message in messages) {
      messageCounts.update(
        message.chatSessionId,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
      if (message.type == ChatMessageType.user) {
        firstQuestions.putIfAbsent(message.chatSessionId, () {
          final question = message.message.trim();
          return question.length <= _maxFirstQuestionLength
              ? question
              : '${question.substring(0, _maxFirstQuestionLength)}…';
        });
      }
    }

    return AdminChatSessionPage(
      sessions: [
        for (final s in sessions)
          AdminChatSessionSummary(
            id: s.id!,
            createdAt: s.createdAt,
            goodAnswer: s.goodAnswer,
            authUserId: s.authUserId,
            messageCount: messageCounts[s.id!] ?? 0,
            answerOutcome: s.answerOutcome,
            answerOutcomeConfidence: s.answerOutcomeConfidence,
            firstQuestion: firstQuestions[s.id!] ?? '',
          ),
      ],
      totalCount: totalCount,
      page: page,
      pageSize: limit,
    );
  }

  /// Returns a chat session with its full conversation. Throws if it does
  /// not exist.
  Future<AdminChatSessionDetail> getChatSession(Session session, int id) async {
    final chatSession = await ChatSession.db.findById(session, id);
    if (chatSession == null) {
      throw Exception('Chat session $id not found.');
    }
    final messages = await ChatMessage.db.find(
      session,
      where: (t) => t.chatSessionId.equals(id),
      orderBy: (t) => t.id,
    );
    return AdminChatSessionDetail(
      id: chatSession.id!,
      createdAt: chatSession.createdAt,
      goodAnswer: chatSession.goodAnswer,
      authUserId: chatSession.authUserId,
      answerOutcome: chatSession.answerOutcome,
      answerOutcomeConfidence: chatSession.answerOutcomeConfidence,
      messages: messages,
    );
  }
}
