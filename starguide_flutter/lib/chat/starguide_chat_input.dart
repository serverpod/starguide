import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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
      padding:
          const EdgeInsets.only(left: 12.0, right: 8.0, top: 8.0, bottom: 8.0),
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
                    if (widget.textController.text.isEmpty) {
                      return;
                    }
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
                    color: theme.colorScheme.primary,
                  ),
                )
              else
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: widget.focusNode.hasFocus
                        ? theme.colorScheme.primary
                        : theme.dividerColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.all(4),
                    minimumSize: const Size(48, 48),
                  ),
                  onPressed: widget.enabled
                      ? () {
                          if (widget.textController.text.isEmpty) {
                            return;
                          }
                          widget.onSend(widget.textController.text);
                          widget.textController.clear();
                        }
                      : null,
                  child: const Icon(
                    LucideIcons.rocket300,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
