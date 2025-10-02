import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingSkeleton extends StatelessWidget {
  const LoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5,  // Fake items
      itemBuilder: (_, __) => const Padding(
        padding: EdgeInsets.all(8.0),
        child: Shimmer(  // Add shimmer package if needed, or custom
          gradient: LinearGradient(
            colors: [
              Colors.grey,
              Colors.white,
              Colors.grey,
            ],
          ),
          child: Card(child: SizedBox(height: 100)),
        ),
      ),
    );
  }
}