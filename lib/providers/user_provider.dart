import 'package:flutter/foundation.dart';
import '../models/user_score.dart';
import '../models/quiz_result.dart';
import '../services/storage_service.dart';

// Provider pour gérer l'état utilisateur et les statistiques
class UserProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();

  UserScore? _userScore;
  List<QuizResult> _quizHistory = [];
  bool _isLoading = false;
  bool _isInitialized = false;

  // Constructeur qui charge automatiquement les données au démarrage
  UserProvider() {
    _initialize();
  }

  // Initialiser et charger les données
  Future<void> _initialize() async {
    if (!_isInitialized) {
      await loadUserData();
      _isInitialized = true;
    }
  }

  // Getters
  UserScore? get userScore => _userScore;
  List<QuizResult> get quizHistory => _quizHistory;
  bool get isLoading => _isLoading;

  // Charger les données utilisateur
  Future<void> loadUserData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _userScore = await _storageService.getUserScore();
      _quizHistory = await _storageService.getQuizHistory();
    } catch (e) {
      debugPrint('Error loading user data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mettre à jour le score après un quiz
  Future<void> updateScore(QuizResult result) async {
    try {
      // Sauvegarder le résultat immédiatement
      await _storageService.saveQuizResult(result);

      // Mettre à jour le score total
      final currentTotalQuizzes = _userScore?.totalQuizzes ?? 0;
      final currentTotalCorrect = _userScore?.totalCorrectAnswers ?? 0;
      final currentTotalQuestions = _userScore?.totalQuestions ?? 0;

      _userScore = UserScore(
        totalQuizzes: currentTotalQuizzes + 1,
        totalCorrectAnswers: currentTotalCorrect + result.correctAnswers,
        totalQuestions: currentTotalQuestions + result.totalQuestions,
        categoryScores: {
          ..._userScore?.categoryScores ?? {},
          result.category: (_userScore?.categoryScores[result.category] ?? 0) +
              result.correctAnswers,
        },
      );

      // Sauvegarder le score mis à jour immédiatement
      await _storageService.saveUserScore(_userScore!);
      
      // Recharger pour avoir l'historique à jour
      await loadUserData();
    } catch (e) {
      debugPrint('Error updating score: $e');
      // En cas d'erreur, recharger quand même les données
      await loadUserData();
    }
  }

  // Réinitialiser toutes les données
  Future<void> resetAllData() async {
    await _storageService.clearAllData();
    _userScore = null;
    _quizHistory = [];
    notifyListeners();
  }
}

