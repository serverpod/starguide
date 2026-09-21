/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import '../answer_outcome.dart' as _ig2enm7h;

/// A chat session with the first question asked, for listing.
abstract class AdminChatSessionSummary
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AdminChatSessionSummary._({
    required this.id,
    required this.createdAt,
    this.goodAnswer,
    this.authUserId,
    required this.messageCount,
    this.answerOutcome,
    this.answerOutcomeConfidence,
    required this.firstQuestion,
  });

  factory AdminChatSessionSummary({
    required int id,
    required DateTime createdAt,
    bool? goodAnswer,
    _isc.UuidValue? authUserId,
    required int messageCount,
    _ig2enm7h.AnswerOutcome? answerOutcome,
    double? answerOutcomeConfidence,
    required String firstQuestion,
  }) = _AdminChatSessionSummaryImpl;

  factory AdminChatSessionSummary.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return AdminChatSessionSummary(
      id: jsonSerialization['id'] as int,
      createdAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      goodAnswer: jsonSerialization['goodAnswer'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(jsonSerialization['goodAnswer']),
      authUserId: jsonSerialization['authUserId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['authUserId'],
            ),
      messageCount: jsonSerialization['messageCount'] as int,
      answerOutcome: jsonSerialization['answerOutcome'] == null
          ? null
          : _ig2enm7h.AnswerOutcome.fromJson(
              (jsonSerialization['answerOutcome'] as String),
            ),
      answerOutcomeConfidence:
          (jsonSerialization['answerOutcomeConfidence'] as num?)?.toDouble(),
      firstQuestion: jsonSerialization['firstQuestion'] as String,
    );
  }

  int id;

  DateTime createdAt;

  bool? goodAnswer;

  _isc.UuidValue? authUserId;

  int messageCount;

  /// Jev's judgement of the latest answer, if it was judged.
  _ig2enm7h.AnswerOutcome? answerOutcome;

  double? answerOutcomeConfidence;

  /// The first question of the conversation, truncated.
  String firstQuestion;

  /// Returns a shallow copy of this [AdminChatSessionSummary]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AdminChatSessionSummary copyWith({
    int? id,
    DateTime? createdAt,
    bool? goodAnswer,
    _isc.UuidValue? authUserId,
    int? messageCount,
    _ig2enm7h.AnswerOutcome? answerOutcome,
    double? answerOutcomeConfidence,
    String? firstQuestion,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AdminChatSessionSummary',
      'id': id,
      'createdAt': createdAt.toJson(),
      if (goodAnswer != null) 'goodAnswer': goodAnswer,
      if (authUserId != null) 'authUserId': authUserId?.toJson(),
      'messageCount': messageCount,
      if (answerOutcome != null) 'answerOutcome': answerOutcome?.toJson(),
      if (answerOutcomeConfidence != null)
        'answerOutcomeConfidence': answerOutcomeConfidence,
      'firstQuestion': firstQuestion,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AdminChatSessionSummary',
      'id': id,
      'createdAt': createdAt.toJson(),
      if (goodAnswer != null) 'goodAnswer': goodAnswer,
      if (authUserId != null) 'authUserId': authUserId?.toJson(),
      'messageCount': messageCount,
      if (answerOutcome != null) 'answerOutcome': answerOutcome?.toJson(),
      if (answerOutcomeConfidence != null)
        'answerOutcomeConfidence': answerOutcomeConfidence,
      'firstQuestion': firstQuestion,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AdminChatSessionSummaryImpl extends AdminChatSessionSummary {
  _AdminChatSessionSummaryImpl({
    required int id,
    required DateTime createdAt,
    bool? goodAnswer,
    _isc.UuidValue? authUserId,
    required int messageCount,
    _ig2enm7h.AnswerOutcome? answerOutcome,
    double? answerOutcomeConfidence,
    required String firstQuestion,
  }) : super._(
         id: id,
         createdAt: createdAt,
         goodAnswer: goodAnswer,
         authUserId: authUserId,
         messageCount: messageCount,
         answerOutcome: answerOutcome,
         answerOutcomeConfidence: answerOutcomeConfidence,
         firstQuestion: firstQuestion,
       );

  /// Returns a shallow copy of this [AdminChatSessionSummary]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AdminChatSessionSummary copyWith({
    int? id,
    DateTime? createdAt,
    Object? goodAnswer = _Undefined,
    Object? authUserId = _Undefined,
    int? messageCount,
    Object? answerOutcome = _Undefined,
    Object? answerOutcomeConfidence = _Undefined,
    String? firstQuestion,
  }) {
    return AdminChatSessionSummary(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      goodAnswer: goodAnswer is bool? ? goodAnswer : this.goodAnswer,
      authUserId: authUserId is _isc.UuidValue? ? authUserId : this.authUserId,
      messageCount: messageCount ?? this.messageCount,
      answerOutcome: answerOutcome is _ig2enm7h.AnswerOutcome?
          ? answerOutcome
          : this.answerOutcome,
      answerOutcomeConfidence: answerOutcomeConfidence is double?
          ? answerOutcomeConfidence
          : this.answerOutcomeConfidence,
      firstQuestion: firstQuestion ?? this.firstQuestion,
    );
  }
}
