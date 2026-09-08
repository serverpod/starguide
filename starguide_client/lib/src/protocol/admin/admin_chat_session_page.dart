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
import '../admin/admin_chat_session_summary.dart' as _ix5rx7p3;

/// One page of chat sessions.
abstract class AdminChatSessionPage
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AdminChatSessionPage._({
    required this.sessions,
    required this.totalCount,
    required this.page,
    required this.pageSize,
  });

  factory AdminChatSessionPage({
    required List<_ix5rx7p3.AdminChatSessionSummary> sessions,
    required int totalCount,
    required int page,
    required int pageSize,
  }) = _AdminChatSessionPageImpl;

  factory AdminChatSessionPage.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return AdminChatSessionPage(
      sessions: _ix1idbfg.Protocol()
          .deserialize<List<_ix5rx7p3.AdminChatSessionSummary>>(
            jsonSerialization['sessions'],
          ),
      totalCount: jsonSerialization['totalCount'] as int,
      page: jsonSerialization['page'] as int,
      pageSize: jsonSerialization['pageSize'] as int,
    );
  }

  List<_ix5rx7p3.AdminChatSessionSummary> sessions;

  int totalCount;

  int page;

  int pageSize;

  /// Returns a shallow copy of this [AdminChatSessionPage]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AdminChatSessionPage copyWith({
    List<_ix5rx7p3.AdminChatSessionSummary>? sessions,
    int? totalCount,
    int? page,
    int? pageSize,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AdminChatSessionPage',
      'sessions': sessions.toJson(valueToJson: (v) => v.toJson()),
      'totalCount': totalCount,
      'page': page,
      'pageSize': pageSize,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AdminChatSessionPage',
      'sessions': sessions.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'totalCount': totalCount,
      'page': page,
      'pageSize': pageSize,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _AdminChatSessionPageImpl extends AdminChatSessionPage {
  _AdminChatSessionPageImpl({
    required List<_ix5rx7p3.AdminChatSessionSummary> sessions,
    required int totalCount,
    required int page,
    required int pageSize,
  }) : super._(
         sessions: sessions,
         totalCount: totalCount,
         page: page,
         pageSize: pageSize,
       );

  /// Returns a shallow copy of this [AdminChatSessionPage]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AdminChatSessionPage copyWith({
    List<_ix5rx7p3.AdminChatSessionSummary>? sessions,
    int? totalCount,
    int? page,
    int? pageSize,
  }) {
    return AdminChatSessionPage(
      sessions: sessions ?? this.sessions.map((e0) => e0.copyWith()).toList(),
      totalCount: totalCount ?? this.totalCount,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}
