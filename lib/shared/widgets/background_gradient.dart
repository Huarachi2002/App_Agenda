import 'package:flutter/material.dart';

/// Widget que dibuja un gradiente de fondo (opcional)
class BackgroundGradient extends StatelessWidget {
  const BackgroundGradient();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xff4c669f),
            Color(0xff3b5998),
            Color(0xff192f6a),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }
}