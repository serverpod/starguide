import 'package:flutter/material.dart';

class StarguideDisconnected extends StatelessWidget {
  const StarguideDisconnected({
    super.key,
    required this.onReconnect,
  });

  final VoidCallback onReconnect;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 256,
              height: 256,
              child: Image.asset('assets/disconnected.webp'),
            ),
            const SizedBox(height: 16),
            Text('Oops. Something went wrong.'),
            const SizedBox(height: 32),
            OutlinedButton(
              onPressed: onReconnect,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text('Try Again'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
