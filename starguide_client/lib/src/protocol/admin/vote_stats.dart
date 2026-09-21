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

/// Chat session and vote counts over a period of time.
abstract class VoteStats
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  VoteStats._({
    required this.sessionCount,
    required this.goodAnswerCount,
    required this.poorAnswerCount,
    required this.answeredCount,
    required this.notAnsweredCount,
    required this.unsureCount,
  });

  factory VoteStats({
    required int sessionCount,
    required int goodAnswerCount,
    required int poorAnswerCount,
    required int answeredCount,
    required int notAnsweredCount,
    required int unsureCount,
  }) = _VoteStatsImpl;

  factory VoteStats.fromJson(Map<String, dynamic> jsonSerialization) {
    return VoteStats(
      sessionCount: jsonSerialization['sessionCount'] as int,
      goodAnswerCount: jsonSerialization['goodAnswerCount'] as int,
      poorAnswerCount: jsonSerialization['poorAnswerCount'] as int,
      answeredCount: jsonSerialization['answeredCount'] as int,
      notAnsweredCount: jsonSerialization['notAnsweredCount'] as int,
      unsureCount: jsonSerialization['unsureCount'] as int,
    );
  }

  int sessionCount;

  int goodAnswerCount;

  int poorAnswerCount;

  /// Sessions whose latest answer Jev judged to have answered the question.
  int answeredCount;

  int notAnsweredCount;

  int unsureCount;

  /// Returns a shallow copy of this [VoteStats]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  VoteStats copyWith({
    int? sessionCount,
    int? goodAnswerCount,
    int? poorAnswerCount,
    int? answeredCount,
    int? notAnsweredCount,
    int? unsureCount,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'VoteStats',
      'sessionCount': sessionCount,
      'goodAnswerCount': goodAnswerCount,
      'poorAnswerCount': poorAnswerCount,
      'answeredCount': answeredCount,
      'notAnsweredCount': notAnsweredCount,
      'unsureCount': unsureCount,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'VoteStats',
      'sessionCount': sessionCount,
      'goodAnswerCount': goodAnswerCount,
      'poorAnswerCount': poorAnswerCount,
      'answeredCount': answeredCount,
      'notAnsweredCount': notAnsweredCount,
      'unsureCount': unsureCount,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _VoteStatsImpl extends VoteStats {
  _VoteStatsImpl({
    required int sessionCount,
    required int goodAnswerCount,
    required int poorAnswerCount,
    required int answeredCount,
    required int notAnsweredCount,
    required int unsureCount,
  }) : super._(
         sessionCount: sessionCount,
         goodAnswerCount: goodAnswerCount,
         poorAnswerCount: poorAnswerCount,
         answeredCount: answeredCount,
         notAnsweredCount: notAnsweredCount,
         unsureCount: unsureCount,
       );

  /// Returns a shallow copy of this [VoteStats]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  VoteStats copyWith({
    int? sessionCount,
    int? goodAnswerCount,
    int? poorAnswerCount,
    int? answeredCount,
    int? notAnsweredCount,
    int? unsureCount,
  }) {
    return VoteStats(
      sessionCount: sessionCount ?? this.sessionCount,
      goodAnswerCount: goodAnswerCount ?? this.goodAnswerCount,
      poorAnswerCount: poorAnswerCount ?? this.poorAnswerCount,
      answeredCount: answeredCount ?? this.answeredCount,
      notAnsweredCount: notAnsweredCount ?? this.notAnsweredCount,
      unsureCount: unsureCount ?? this.unsureCount,
    );
  }
}
