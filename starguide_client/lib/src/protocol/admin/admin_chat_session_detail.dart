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
import 'package:starguide_client/src/protocol/protocol.dart' as _ix1idbfg;
import '../answer_outcome.dart' as _ig2enm7h;
import '../chat_message.dart' as _izru38dm;

/// A chat session with its full conversation.
abstract class AdminChatSessionDetail
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AdminChatSessionDetail._({
    required this.id,
    required this.createdAt,
    this.goodAnswer,
    this.authUserId,
    this.answerOutcome,
    this.answerOutcomeConfidence,
    required this.messages,
  });

  factory AdminChatSessionDetail({
    required int id,
    required DateTime createdAt,
    bool? goodAnswer,
    _isc.UuidValue? authUserId,
    _ig2enm7h.AnswerOutcome? answerOutcome,
    double? answerOutcomeConfidence,
    required List<_izru38dm.ChatMessage> messages,
  }) = _AdminChatSessionDetailImpl;

  factory AdminChatSessionDetail.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return AdminChatSessionDetail(
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
      answerOutcome: jsonSerialization['answerOutcome'] == null
          ? null
          : _ig2enm7h.AnswerOutcome.fromJson(
              (jsonSerialization['answerOutcome'] as String),
            ),
      answerOutcomeConfidence:
          (jsonSerialization['answerOutcomeConfidence'] as num?)?.toDouble(),
      messages: _ix1idbfg.Protocol().deserialize<List<_izru38dm.ChatMessage>>(
        jsonSerialization['messages'],
      ),
    );
  }

  int id;

  DateTime createdAt;

  bool? goodAnswer;

  _isc.UuidValue? authUserId;

  /// Jev's judgement of the latest answer, if it was judged.
  _ig2enm7h.AnswerOutcome? answerOutcome;

  double? answerOutcomeConfidence;

  List<_izru38dm.ChatMessage> messages;

  /// Returns a shallow copy of this [AdminChatSessionDetail]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AdminChatSessionDetail copyWith({
    int? id,
    DateTime? createdAt,
    bool? goodAnswer,
    _isc.UuidValue? authUserId,
    _ig2enm7h.AnswerOutcome? answerOutcome,
    double? answerOutcomeConfidence,
    List<_izru38dm.ChatMessage>? messages,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AdminChatSessionDetail',
      'id': id,
      'createdAt': createdAt.toJson(),
      if (goodAnswer != null) 'goodAnswer': goodAnswer,
      if (authUserId != null) 'authUserId': authUserId?.toJson(),
      if (answerOutcome != null) 'answerOutcome': answerOutcome?.toJson(),
      if (answerOutcomeConfidence != null)
        'answerOutcomeConfidence': answerOutcomeConfidence,
      'messages': messages.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AdminChatSessionDetail',
      'id': id,
      'createdAt': createdAt.toJson(),
      if (goodAnswer != null) 'goodAnswer': goodAnswer,
      if (authUserId != null) 'authUserId': authUserId?.toJson(),
      if (answerOutcome != null) 'answerOutcome': answerOutcome?.toJson(),
      if (answerOutcomeConfidence != null)
        'answerOutcomeConfidence': answerOutcomeConfidence,
      'messages': messages.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AdminChatSessionDetailImpl extends AdminChatSessionDetail {
  _AdminChatSessionDetailImpl({
    required int id,
    required DateTime createdAt,
    bool? goodAnswer,
    _isc.UuidValue? authUserId,
    _ig2enm7h.AnswerOutcome? answerOutcome,
    double? answerOutcomeConfidence,
    required List<_izru38dm.ChatMessage> messages,
  }) : super._(
         id: id,
         createdAt: createdAt,
         goodAnswer: goodAnswer,
         authUserId: authUserId,
         answerOutcome: answerOutcome,
         answerOutcomeConfidence: answerOutcomeConfidence,
         messages: messages,
       );

  /// Returns a shallow copy of this [AdminChatSessionDetail]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AdminChatSessionDetail copyWith({
    int? id,
    DateTime? createdAt,
    Object? goodAnswer = _Undefined,
    Object? authUserId = _Undefined,
    Object? answerOutcome = _Undefined,
    Object? answerOutcomeConfidence = _Undefined,
    List<_izru38dm.ChatMessage>? messages,
  }) {
    return AdminChatSessionDetail(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      goodAnswer: goodAnswer is bool? ? goodAnswer : this.goodAnswer,
      authUserId: authUserId is _isc.UuidValue? ? authUserId : this.authUserId,
      answerOutcome: answerOutcome is _ig2enm7h.AnswerOutcome?
          ? answerOutcome
          : this.answerOutcome,
      answerOutcomeConfidence: answerOutcomeConfidence is double?
          ? answerOutcomeConfidence
          : this.answerOutcomeConfidence,
      messages: messages ?? this.messages.map((e0) => e0.copyWith()).toList(),
    );
  }
}
