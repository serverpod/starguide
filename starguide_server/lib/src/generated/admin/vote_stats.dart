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
import 'package:serverpod/serverpod.dart' as _is;

/// Chat session and vote counts over a period of time.
abstract class VoteStats
    implements _is.SerializableModel, _is.ProtocolSerialization {
  VoteStats._({
    required this.sessionCount,
    required this.goodAnswerCount,
    required this.poorAnswerCount,
  });

  factory VoteStats({
    required int sessionCount,
    required int goodAnswerCount,
    required int poorAnswerCount,
  }) = _VoteStatsImpl;

  factory VoteStats.fromJson(Map<String, dynamic> jsonSerialization) {
    return VoteStats(
      sessionCount: jsonSerialization['sessionCount'] as int,
      goodAnswerCount: jsonSerialization['goodAnswerCount'] as int,
      poorAnswerCount: jsonSerialization['poorAnswerCount'] as int,
    );
  }

  int sessionCount;

  int goodAnswerCount;

  int poorAnswerCount;

  /// Returns a shallow copy of this [VoteStats]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  VoteStats copyWith({
    int? sessionCount,
    int? goodAnswerCount,
    int? poorAnswerCount,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'VoteStats',
      'sessionCount': sessionCount,
      'goodAnswerCount': goodAnswerCount,
      'poorAnswerCount': poorAnswerCount,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'VoteStats',
      'sessionCount': sessionCount,
      'goodAnswerCount': goodAnswerCount,
      'poorAnswerCount': poorAnswerCount,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _VoteStatsImpl extends VoteStats {
  _VoteStatsImpl({
    required int sessionCount,
    required int goodAnswerCount,
    required int poorAnswerCount,
  }) : super._(
         sessionCount: sessionCount,
         goodAnswerCount: goodAnswerCount,
         poorAnswerCount: poorAnswerCount,
       );

  /// Returns a shallow copy of this [VoteStats]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  VoteStats copyWith({
    int? sessionCount,
    int? goodAnswerCount,
    int? poorAnswerCount,
  }) {
    return VoteStats(
      sessionCount: sessionCount ?? this.sessionCount,
      goodAnswerCount: goodAnswerCount ?? this.goodAnswerCount,
      poorAnswerCount: poorAnswerCount ?? this.poorAnswerCount,
    );
  }
}
