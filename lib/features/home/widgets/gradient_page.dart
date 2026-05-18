import 'package:flutter/material.dart';

class GradientPage extends StatelessWidget {
  const GradientPage({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFF8EE), Color(0xFFF6EFE4), Color(0xFFF8F7F4)],
        ),
      ),
      child: SafeArea(child: child),
    );
  }
}
