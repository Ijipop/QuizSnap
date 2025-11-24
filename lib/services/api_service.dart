import '../models/question.dart';
import '../models/category.dart' as models;
import 'interfaces/quiz_api_interface.dart';
import 'open_trivia_service.dart';
// import 'quiz_api_service.dart'; // Décommentez si vous voulez revenir à quiz-api.fr

// Service principal qui utilise l'interface
// Pour changer d'API, il suffit de changer l'implémentation ici !
class ApiService {
  // ✅ POINT DE CHANGEMENT : Changez juste cette ligne pour utiliser une autre API
  late final IQuizApiService _apiService;

  ApiService() {
    // Utilisez Open Trivia DB (gratuit, fiable, pas de token requis)
    _apiService = OpenTriviaService();

    // Pour utiliser quiz-api.fr à la place, décommentez :
    // _apiService = QuizApiService(
    //   apiToken: '26|absxF6YP4xzcBQFwoDELifdxP1io8ldkLg5hB9R7c47a7b22',
    // );

    // Pour utiliser une autre API, créez une nouvelle implémentation
    // de IQuizApiService et assignez-la ici !
  }

  // Délègue les appels à l'implémentation choisie
  Future<List<Question>> getQuestions({
    int amount = 10,
    int? category,
    String? difficulty,
    String? language,
  }) {
    // Toujours utiliser le français par défaut si non spécifié
    return _apiService.getQuestions(
      amount: amount,
      category: category,
      difficulty: difficulty,
      language: language ?? 'fr', // Français par défaut
    );
  }

  Future<List<models.Category>> getCategories() {
    return _apiService.getCategories();
  }
}
