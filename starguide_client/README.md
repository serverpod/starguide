# Starguide Client

The client library for connecting to Serverpod's Starguide server. Starguide is an AI-powered assistant that provides code samples, guides, and full documentation about the Serverpod framework.

## Features

- **Model Context Protocol (MCP) Support**: Access Serverpod documentation and guides through MCP endpoints
- **RAG-Powered Q&A**: Ask questions and get answers using Retrieval-Augmented Generation
- **Chat Interface**: Interactive chat sessions with the Starguide AI assistant
- **Documentation Access**: Retrieve markdown resources and documentation
- **Streaming Responses**: Real-time streaming of AI responses

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  starguide_client: ^0.1.0
```

Then run:

```bash
dart pub get
```

## Usage

### Basic Setup

```dart
import 'package:starguide_client/starguide_client.dart';

// Create a client instance
final client = Client('https://your-starguide-server.com');
```

### MCP Endpoints

The MCP (Model Context Protocol) endpoints provide access to Serverpod documentation and guides:

```dart
// Get MCP instructions
final instructions = await client.mcp.mcpInstructions();

// Retrieve all available markdown resources
final resources = await client.mcp.getAllResources();

// Ask a question using RAG
final answer = await client.mcp.ask(
  'How do I create a new endpoint in Serverpod?',
  'your-gemini-api-key',
);
```

### Chat Interface

For interactive conversations with the Starguide AI:

```dart
// Create a new chat session
final chatSession = await client.starguide.createChatSession('recaptcha-token');

// Ask a question and get streaming response
final responseStream = client.starguide.ask(chatSession, 'How do I set up authentication?');

await for (final chunk in responseStream) {
  print(chunk); // Print each chunk as it arrives
}

// Vote on the quality of the answer
await client.starguide.vote(chatSession, true); // true for good answer
```

## API Reference

### MCP Endpoint

Provides access to Serverpod documentation and guides:

- `mcpInstructions()` - Returns MCP instructions
- `getAllResources()` - Retrieves all markdown resources
- `ask(question, geminiAPIKey)` - Processes questions using RAG

### Starguide Endpoint

Provides interactive chat functionality:

- `createChatSession(reCaptchaToken)` - Creates a new chat session
- `ask(chatSession, question)` - Sends a question and returns streaming response
- `vote(chatSession, goodAnswer)` - Votes on answer quality

