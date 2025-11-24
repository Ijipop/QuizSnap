import 'package:flutter/foundation.dart';
import '../models/question.dart';
import '../models/quiz_result.dart';
import '../models/category.dart' as models;
import '../services/api_service.dart';
import '../services/quiz_service.dart';

// Provider pour gérer l'état du quiz
class QuizProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final QuizService _quizService = QuizService();

  List<Question> _questions = [];
  List<models.Category> _categories = [];
  Map<int, String> _userAnswers = {};
  int _currentQuestionIndex = 0;
  bool _isLoading = false;
  bool _isLoadingCategories = false;
  String? _error;
  QuizResult? _result;

  // Getters
  List<Question> get questions => _questions;
  List<models.Category> get categories => _categories;
  Map<int, String> get userAnswers => _userAnswers;
  int get currentQuestionIndex => _currentQuestionIndex;
  bool get isLoading => _isLoading;
  bool get isLoadingCategories => _isLoadingCategories;
  String? get error => _error;
  QuizResult? get result => _result;
  Question? get currentQuestion =>
      _currentQuestionIndex < _questions.length
          ? _questions[_currentQuestionIndex]
          : null;
  bool get isQuizComplete => _currentQuestionIndex >= _questions.length;

  // Charger les questions
  Future<void> loadQuestions({
    int amount = 10,
    int? category,
    String? difficulty,
    String? language,
  }) async {
    // Toujours utiliser le français par défaut
    language = language ?? 'fr';
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _questions = await _apiService.getQuestions(
        amount: amount,
        category: category,
        difficulty: difficulty,
        language: language,
      );
      _currentQuestionIndex = 0;
      _userAnswers = {};
      _result = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Répondre à une question
  void answerQuestion(String answer) {
    _userAnswers[_currentQuestionIndex] = answer;
    notifyListeners();
  }

  // Passer à la question suivante
  void nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex++;
      notifyListeners();
    }
  }

  // Question précédente
  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      notifyListeners();
    }
  }

  // Terminer le quiz et calculer le résultat
  void finishQuiz(String category) {
    _result = _quizService.createResult(
      questions: _questions,
      userAnswers: _userAnswers,
      category: category,
    );
    notifyListeners();
  }

  // Charger les catégories depuis l'API
  Future<void> loadCategories() async {
    _isLoadingCategories = true;
    _error = null;
    notifyListeners();

    try {
      _categories = await _apiService.getCategories();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingCategories = false;
      notifyListeners();
    }
  }

  // Réinitialiser le quiz
  void resetQuiz() {
    _questions = [];
    _userAnswers = {};
    _currentQuestionIndex = 0;
    _result = null;
    _error = null;
    notifyListeners();
  }
}

