import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../utils/constants.dart';
import 'quiz_screen.dart';
import '../widgets/category_card.dart';

// Écran de sélection de catégorie
class CategorySelectionScreen extends StatefulWidget {
  const CategorySelectionScreen({super.key});

  @override
  State<CategorySelectionScreen> createState() => _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  String? _selectedDifficulty;

  @override
  void initState() {
    super.initState();
    // Charger les catégories au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuizProvider>().loadCategories();
    });
  }

  void _startQuiz(int categoryId, String categoryName) {
    if (_selectedDifficulty == null) {
      // Afficher un message si aucune difficulté n'est sélectionnée
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Veuillez sélectionner une difficulté'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    // Charger les questions et naviguer vers le quiz
    final quizProvider = context.read<QuizProvider>();
    
    // Afficher un loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Chargement des questions...'),
              ],
            ),
          ),
        ),
      ),
    );

    quizProvider.loadQuestions(
      amount: AppConstants.defaultQuestionCount,
      category: categoryId,
      difficulty: _selectedDifficulty,
      language: 'fr', // Français
    ).then((_) {
      // Fermer le loader
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Vérifier si les questions ont été chargées avec succès
      if (quizProvider.error == null && quizProvider.questions.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizScreen(categoryName: categoryName),
          ),
        );
      } else {
        // Afficher une erreur
        final errorMessage = quizProvider.error ?? 'Aucune question disponible';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $errorMessage'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Réessayer',
              onPressed: () {
                _startQuiz(categoryId, categoryName);
              },
            ),
          ),
        );
      }
    }).catchError((error) {
      // Fermer le loader en cas d'erreur
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${error.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 4),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choisir une catégorie'),
      ),
      body: Consumer<QuizProvider>(
        builder: (context, quizProvider, child) {
          // Afficher un loader pendant le chargement
          if (quizProvider.isLoadingCategories) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Afficher une erreur si problème
          if (quizProvider.error != null && quizProvider.categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur de chargement',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      quizProvider.error ?? 'Erreur inconnue',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      quizProvider.loadCategories();
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          // Afficher les catégories
          return Column(
            children: [
              // Sélection de la difficulté
              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DIFFICULTÉ',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          children: AppConstants.difficulties.map((difficulty) {
                            final isSelected = _selectedDifficulty == difficulty;
                            return ChoiceChip(
                              label: Text(
                                AppConstants.getDifficultyLabel(difficulty),
                                style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedDifficulty =
                                      selected ? difficulty : null;
                                });
                              },
                              selectedColor:
                                  Theme.of(context).colorScheme.primary,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? Theme.of(context)
                                        .colorScheme
                                        .onPrimary
                                    : Theme.of(context).colorScheme.primary,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Liste des catégories
              Expanded(
                child: quizProvider.categories.isEmpty
                    ? Center(
                        child: Text(
                          'Aucune catégorie disponible',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: quizProvider.categories.length,
                        itemBuilder: (context, index) {
                          final category = quizProvider.categories[index];
                          return CategoryCard(
                            categoryName: category.name,
                            onTap: () => _startQuiz(category.id, category.name),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
