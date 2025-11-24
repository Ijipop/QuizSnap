import '../../models/question.dart';
import '../../models/category.dart' as models;

// Interface abstraite pour les services API de quiz
// Cela permet de changer d'API facilement en implémentant cette interface
abstract class IQuizApiService {
  /// Récupère une liste de questions
  /// 
  /// [amount] : Nombre de questions à récupérer
  /// [category] : ID de la catégorie (optionnel)
  /// [difficulty] : Niveau de difficulté (optionnel)
  /// [language] : Langue des questions (optionnel, ex: 'fr', 'en')
  Future<List<Question>> getQuestions({
    int amount = 10,
    int? category,
    String? difficulty,
    String? language,
  });

  /// Récupère la liste des catégories disponibles
  Future<List<models.Category>> getCategories();
}

