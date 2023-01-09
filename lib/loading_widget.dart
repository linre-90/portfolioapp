import 'package:flutter/material.dart';

/// Spinner that can be shown when loading some data from backend.
class Spinner extends StatelessWidget {
  const Spinner({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: (CircularProgressIndicator()));
  }
}
