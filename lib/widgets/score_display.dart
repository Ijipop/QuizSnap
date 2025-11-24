import 'package:flutter/material.dart';

// Widget pour afficher le score
class ScoreDisplay extends StatelessWidget {
  final int score;
  final int totalQuestions;

  const ScoreDisplay({
    super.key,
    required this.score,
    required this.totalQuestions,
  });

  double get percentage => (score / totalQuestions) * 100;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Score',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '$score / $totalQuestions',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

