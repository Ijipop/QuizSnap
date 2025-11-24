import 'package:flutter/material.dart';

// Widget pour afficher un timer
class TimerWidget extends StatelessWidget {
  final int secondsRemaining;
  final VoidCallback? onTimeUp;

  const TimerWidget({
    super.key,
    required this.secondsRemaining,
    this.onTimeUp,
  });

  String get formattedTime {
    final minutes = secondsRemaining ~/ 60;
    final seconds = secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: secondsRemaining < 10 ? Colors.red : Colors.blue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        formattedTime,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

