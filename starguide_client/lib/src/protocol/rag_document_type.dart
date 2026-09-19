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

/// The kind of source a document was fetched from.
enum RAGDocumentType implements _isc.SerializableModel {
  /// A page of the documentation. Listed in the table of contents.
  documentation,

  /// A page of the product website. Listed in the table of contents.
  site,

  /// A GitHub discussion with an accepted answer. Found by embedding search.
  discussion,

  /// A blog post. Found by embedding search.
  blog,
  issue;

  static RAGDocumentType fromJson(String name) {
    switch (name) {
      case 'documentation':
        return RAGDocumentType.documentation;
      case 'site':
        return RAGDocumentType.site;
      case 'discussion':
        return RAGDocumentType.discussion;
      case 'blog':
        return RAGDocumentType.blog;
      case 'issue':
        return RAGDocumentType.issue;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "RAGDocumentType"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
