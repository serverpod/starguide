import 'dart:io';

import 'package:serverpod/serverpod.dart';
import 'package:starguide_server/src/business/search.dart';
import 'package:starguide_server/src/generated/protocol.dart';
import 'package:starguide_server/src/generative_ai/generative_ai.dart';
import 'package:starguide_server/src/generative_ai/prompts.dart';

/// Default instruction string returned to Model Context Protocol (MCP)
/// clients during capability discovery. It describes available tools and how
/// to use them to obtain Serverpod guides and documentation answers.
const _mcpInstructions =
    'Provides code samples, guides, and full documentation about Serverpod, a '
    'backend framework written in Dart. To list available coding guides, use '
    'the "list-guides" tool. Then, retrieve relevant guides to the problem you '
    'are working on using the "get-guide" tool. If the answer is not found in '
    'the guides, use the "ask-docs" tool to search the full Serverpod '
    'documentation and get answers from GitHub discussions.';

/// Endpoint for handling Model Context Protocol (MCP) related operations.
///
/// Exposes utilities used by MCP-compatible clients to:
/// - Retrieve markdown resources describing the Serverpod framework.
/// - Ask questions answered via RAG (Retrieval-Augmented Generation) over
///   Serverpod documentation and GitHub discussions.
/// - Load and parse markdown resources with metadata extraction.
///
/// {@category Endpoint}
class McpEndpoint extends Endpoint {
  /// Returns the MCP instruction string presented to MCP clients.
  ///
  /// The returned text outlines the available tools (e.g., list-guides,
  /// get-guide, ask-docs) and how to interact with this server.
  Future<String> mcpInstructions(Session session) async {
    return _mcpInstructions;
  }

  /// Retrieves all markdown resources.
  ///
  /// Returns a list of [MarkdownResourceInfo] objects containing:
  /// - Resource name (extracted from first heading).
  /// - URI (serverpod:// prefixed path).
  /// - Description (first paragraph after title).
  /// - Full text content.
  ///
  /// The resources are discovered by scanning the `assets/resources` directory
  /// for files ending in `.md`. Each file is parsed and converted to a
  /// [MarkdownResourceInfo].
  ///
  /// Throws [FileSystemException] if the resources cannot be accessed.
  Future<List<MarkdownResourceInfo>> getAllResources(
    Session session,
  ) async {
    final resourceDir = Directory('assets/resources');
    final resourceInfos = <MarkdownResourceInfo>[];
    for (final file in resourceDir.listSync()) {
      if (file.path.endsWith('.md')) {
        final resourceInfo = await _loadMarkdownResource(file.path);
        resourceInfos.add(resourceInfo);
      }
    }
    return resourceInfos;
  }

  /// Processes a question using RAG (Retrieval-Augmented Generation).
  ///
  /// Searches both documentation and discussions to find relevant context,
  /// then generates an answer using the generative AI system.
  ///
  /// [session] - The server session for database access.
  /// [question] - The user's question to be answered.
  /// [geminiAPIKey] - API key for the Gemini generative AI service.
  ///
  /// Returns a [String] containing the generated answer based on the retrieved
  /// context and the user's question.
  ///
  /// This method returns a fully assembled answer (non-streaming). For a
  /// streaming, conversational experience see the `starguide.ask` endpoint.
  ///
  /// May throw if the generative AI provider rejects the request or if the
  /// provided [geminiAPIKey] is invalid.
  Future<String> ask(
    Session session,
    String question,
    String geminiAPIKey,
  ) async {
    final genAi = GenerativeAi.withAPIKey(geminiAPIKey);

    // Search RAG documents in parallel, using different methods.
    final results = await Future.wait([
      searchDocumentation(session, [], question),
      searchDiscussions(session, [], question),
    ]);
    var documents = results.expand((list) => list).toList();

    // Generate the answer.
    final answerStream = genAi.generateConversationalAnswer(
      systemPrompt: Prompts.instance.get('final_answer')!,
      question: question,
      documents: documents,
      conversation: [],
    );

    // Return the answer in as a single string.
    var answer = '';
    await for (var chunk in answerStream) {
      answer += chunk;
    }
    return answer;
  }

  /// Loads and parses a markdown resource file, extracting metadata and content.
  ///
  /// [relativePath] - The relative path to the markdown file to load.
  ///
  /// Returns a [MarkdownResourceInfo] object containing the parsed metadata
  /// and content with a serverpod:// prefixed URI.
  ///
  /// Throws [FileSystemException] if the file cannot be read.
  Future<MarkdownResourceInfo> _loadMarkdownResource(
      String relativePath) async {
    final uri = 'serverpod://$relativePath';

    final file = File(relativePath);
    final rawContents = await file.readAsString();

    final lines = rawContents.split('\n');

    // Get title from first line (# Title)
    final title = lines.first.substring(1).trim();

    // Find first paragraph after title
    var descriptionStart = 1;
    while (descriptionStart < lines.length &&
        lines[descriptionStart].trim().isEmpty) {
      descriptionStart++;
    }

    var descriptionEnd = descriptionStart;
    while (descriptionEnd < lines.length &&
        lines[descriptionEnd].trim().isNotEmpty) {
      descriptionEnd++;
    }

    final description =
        lines.sublist(descriptionStart, descriptionEnd).join('\n');

    // Rest of document is the body
    final text = lines.sublist(descriptionEnd).join('\n').trim();

    return MarkdownResourceInfo(
      name: title,
      uri: uri,
      description: description,
      text: text,
    );
  }
}
