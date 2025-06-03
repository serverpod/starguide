import 'package:flutter/material.dart';

class StarguideChatInput extends StatefulWidget {
  const StarguideChatInput({
    super.key,
    required this.onSend,
  });

  final Function(String) onSend;

  @override
  State<StarguideChatInput> createState() => _StarguideChatInputState();
}

class _StarguideChatInputState extends State<StarguideChatInput> {
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.dividerColor,
        ),
        borderRadius: BorderRadius.circular(8),
        color: theme.scaffoldBackgroundColor,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration.collapsed(
                    hintText: 'Ask me anything about Serverpod...',
                    hintStyle: TextStyle(color: theme.disabledColor),
                  ),
                  controller: _textController,
                  onSubmitted: (value) {
                    widget.onSend(_textController.text);
                    _textController.clear();
                  },
                ),
              ),
              IconButton(
                onPressed: () {
                  widget.onSend(_textController.text);
                  _textController.clear();
                },
                icon: const Icon(Icons.send),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
