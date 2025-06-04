import 'package:flutter/material.dart';

class StarguideEmptyChat extends StatelessWidget {
  const StarguideEmptyChat({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 256,
        height: 256,
        child: Image.asset('assets/logo.webp'),
      ),
    );
  }
}
