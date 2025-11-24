import 'package:flutter/material.dart';

// Écran de profil / Statistiques
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: const Center(
        child: Text('Profile Screen - À implémenter'),
      ),
    );
  }
}

