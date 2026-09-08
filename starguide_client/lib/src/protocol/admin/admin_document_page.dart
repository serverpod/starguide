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
import '../admin/admin_document_summary.dart' as _iq9hsvut;

/// One page of RAG documents.
abstract class AdminDocumentPage
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AdminDocumentPage._({
    required this.documents,
    required this.totalCount,
    required this.page,
    required this.pageSize,
  });

  factory AdminDocumentPage({
    required List<_iq9hsvut.AdminDocumentSummary> documents,
    required int totalCount,
    required int page,
    required int pageSize,
  }) = _AdminDocumentPageImpl;

  factory AdminDocumentPage.fromJson(Map<String, dynamic> jsonSerialization) {
    return AdminDocumentPage(
      documents: _ix1idbfg.Protocol()
          .deserialize<List<_iq9hsvut.AdminDocumentSummary>>(
            jsonSerialization['documents'],
          ),
      totalCount: jsonSerialization['totalCount'] as int,
      page: jsonSerialization['page'] as int,
      pageSize: jsonSerialization['pageSize'] as int,
    );
  }

  List<_iq9hsvut.AdminDocumentSummary> documents;

  int totalCount;

  int page;

  int pageSize;

  /// Returns a shallow copy of this [AdminDocumentPage]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AdminDocumentPage copyWith({
    List<_iq9hsvut.AdminDocumentSummary>? documents,
    int? totalCount,
    int? page,
    int? pageSize,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AdminDocumentPage',
      'documents': documents.toJson(valueToJson: (v) => v.toJson()),
      'totalCount': totalCount,
      'page': page,
      'pageSize': pageSize,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AdminDocumentPage',
      'documents': documents.toJson(valueToJson: (v) => v.toJsonForProtocol()),
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

class _AdminDocumentPageImpl extends AdminDocumentPage {
  _AdminDocumentPageImpl({
    required List<_iq9hsvut.AdminDocumentSummary> documents,
    required int totalCount,
    required int page,
    required int pageSize,
  }) : super._(
         documents: documents,
         totalCount: totalCount,
         page: page,
         pageSize: pageSize,
       );

  /// Returns a shallow copy of this [AdminDocumentPage]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AdminDocumentPage copyWith({
    List<_iq9hsvut.AdminDocumentSummary>? documents,
    int? totalCount,
    int? page,
    int? pageSize,
  }) {
    return AdminDocumentPage(
      documents:
          documents ?? this.documents.map((e0) => e0.copyWith()).toList(),
      totalCount: totalCount ?? this.totalCount,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}
