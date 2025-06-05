import 'package:flutter/material.dart';
import 'package:starguide_flutter/config/constants.dart';

class StarguideChatInput extends StatefulWidget {
  const StarguideChatInput({
    super.key,
    required this.onSend,
    required this.textController,
    required this.enabled,
    required this.isGeneratingResponse,
    required this.numChatRequests,
    required this.focusNode,
  });

  final void Function(String message) onSend;
  final TextEditingController textController;
  final bool enabled;
  final bool isGeneratingResponse;
  final int numChatRequests;
  final FocusNode focusNode;

  @override
  State<StarguideChatInput> createState() => _StarguideChatInputState();
}

class _StarguideChatInputState extends State<StarguideChatInput> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final String hintText;

    if (widget.numChatRequests >= kMaxChatRequests) {
      hintText = 'Clear the chat to start a new conversation.';
    } else if (widget.numChatRequests == 0) {
      hintText = 'Ask me anything about Serverpod...';
    } else {
      hintText = 'Ask a follow-up question...';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  focusNode: widget.focusNode,
                  autofocus: true,
                  enabled: widget.numChatRequests < kMaxChatRequests,
                  buildCounter: (
                    context, {
                    required currentLength,
                    required isFocused,
                    required maxLength,
                  }) {
                    return const SizedBox();
                  },
                  maxLength: kMaxChatRequestLength,
                  maxLines: 1,
                  decoration: InputDecoration.collapsed(
                    hintText: hintText,
                    hintStyle: TextStyle(color: theme.disabledColor),
                  ),
                  controller: widget.textController,
                  onSubmitted: (value) {
                    widget.onSend(widget.textController.text);
                    widget.textController.clear();
                    widget.focusNode.requestFocus();
                  },
                ),
              ),
              if (widget.isGeneratingResponse)
                Container(
                  padding: const EdgeInsets.all(10),
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    color: theme.disabledColor,
                  ),
                )
              else
                IconButton(
                  padding: const EdgeInsets.all(4),
                  onPressed: widget.enabled
                      ? () {
                          widget.onSend(widget.textController.text);
                          widget.textController.clear();
                        }
                      : null,
                  icon: const Icon(Icons.send, size: 24),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
