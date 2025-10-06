import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      hintText = 'Clear the chat to start aR new conversation.';
    } else if (widget.numChatRequests == 0) {
      hintText = 'Ask me anything about Serverpod...';
    } else {
      hintText = 'Ask a follow-up question...';
    }

    return Container(
      padding: const EdgeInsets.only(
        left: 12.0,
        right: 8.0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: KeyboardListener(
              focusNode: widget.focusNode,
              onKeyEvent: (event) => _handleKeyboardEvents(event),
              child: Container(
                constraints: BoxConstraints(maxHeight: 400.0),
                child: TextField(
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
                  maxLines: null,
                  minLines: 1,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: TextStyle(color: theme.disabledColor),
                    border: InputBorder.none,
                  ),
                  controller: widget.textController,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
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
                    onPressed: widget.enabled ? _handleSubmit : null,
                    child: const Icon(
                      LucideIcons.rocket300,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _handleKeyboardEvents(KeyEvent event) {
    if (event is KeyDownEvent) {
      final isEnterPressed = event.logicalKey == LogicalKeyboardKey.enter;
      final isShiftPressed = HardwareKeyboard.instance.isShiftPressed;

      if (isEnterPressed && !isShiftPressed && widget.enabled) {
        _handleSubmit();
      }
    }
  }

  void _handleSubmit() {
    if (widget.textController.text.trim().isNotEmpty) {
      widget.onSend(widget.textController.text);
      widget.textController.clear();
    }
  }
}