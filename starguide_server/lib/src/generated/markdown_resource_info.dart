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
import 'package:serverpod/serverpod.dart' as _i1;

abstract class MarkdownResourceInfo
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  MarkdownResourceInfo._({
    required this.name,
    required this.uri,
    required this.description,
    required this.text,
  });

  factory MarkdownResourceInfo({
    required String name,
    required String uri,
    required String description,
    required String text,
  }) = _MarkdownResourceInfoImpl;

  factory MarkdownResourceInfo.fromJson(
      Map<String, dynamic> jsonSerialization) {
    return MarkdownResourceInfo(
      name: jsonSerialization['name'] as String,
      uri: jsonSerialization['uri'] as String,
      description: jsonSerialization['description'] as String,
      text: jsonSerialization['text'] as String,
    );
  }

  String name;

  String uri;

  String description;

  String text;

  /// Returns a shallow copy of this [MarkdownResourceInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MarkdownResourceInfo copyWith({
    String? name,
    String? uri,
    String? description,
    String? text,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'uri': uri,
      'description': description,
      'text': text,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      'name': name,
      'uri': uri,
      'description': description,
      'text': text,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _MarkdownResourceInfoImpl extends MarkdownResourceInfo {
  _MarkdownResourceInfoImpl({
    required String name,
    required String uri,
    required String description,
    required String text,
  }) : super._(
          name: name,
          uri: uri,
          description: description,
          text: text,
        );

  /// Returns a shallow copy of this [MarkdownResourceInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MarkdownResourceInfo copyWith({
    String? name,
    String? uri,
    String? description,
    String? text,
  }) {
    return MarkdownResourceInfo(
      name: name ?? this.name,
      uri: uri ?? this.uri,
      description: description ?? this.description,
      text: text ?? this.text,
    );
  }
}
