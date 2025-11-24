import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

// Écran de paramètres
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Réinitialiser les statistiques'),
        content: const Text(
          'Êtes-vous sûr de vouloir réinitialiser toutes vos statistiques ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final userProvider = context.read<UserProvider>();
              await userProvider.resetAllData();
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Statistiques réinitialisées avec succès'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Réinitialiser'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section Statistiques
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'STATISTIQUES',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.refresh),
                  title: const Text('Réinitialiser les statistiques'),
                  subtitle: const Text(
                    'Supprimer toutes vos statistiques et votre historique',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showResetConfirmation(context),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Section Informations
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'INFORMATIONS',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Version'),
                  subtitle: const Text('1.0.0'),
                ),
                ListTile(
                  leading: const Icon(Icons.quiz),
                  title: const Text('Source des questions'),
                  subtitle: const Text('Open Trivia DB'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

