import 'package:flutter/material.dart';

// Écran de classement
class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Classement'),
      ),
      body: const Center(
        child: Text('Classement - À implémenter'),
      ),
    );
  }
}

