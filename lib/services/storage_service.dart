import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_score.dart';
import '../models/quiz_result.dart';

// Service pour le stockage local
class StorageService {
  static const String _userScoreKey = 'user_score';
  static const String _quizHistoryKey = 'quiz_history';

  // Sauvegarder le score utilisateur
  Future<void> saveUserScore(UserScore score) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.setString(_userScoreKey, jsonEncode(score.toJson()));
      if (!success) {
        throw Exception('Failed to save user score');
      }
    } catch (e) {
      throw Exception('Error saving user score: $e');
    }
  }

  // Récupérer le score utilisateur
  Future<UserScore?> getUserScore() async {
    final prefs = await SharedPreferences.getInstance();
    final scoreJson = prefs.getString(_userScoreKey);
    
    if (scoreJson != null) {
      return UserScore.fromJson(jsonDecode(scoreJson));
    }
    return null;
  }

  // Sauvegarder un résultat de quiz
  Future<void> saveQuizResult(QuizResult result) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_quizHistoryKey) ?? '[]';
      final history = (jsonDecode(historyJson) as List)
          .map((e) => QuizResult.fromJson(e))
          .toList();
      
      history.add(result);
      
      final success = await prefs.setString(
        _quizHistoryKey,
        jsonEncode(history.map((e) => e.toJson()).toList()),
      );
      if (!success) {
        throw Exception('Failed to save quiz result');
      }
    } catch (e) {
      throw Exception('Error saving quiz result: $e');
    }
  }

  // Récupérer l'historique des quiz
  Future<List<QuizResult>> getQuizHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_quizHistoryKey) ?? '[]';
    
    return (jsonDecode(historyJson) as List)
        .map((e) => QuizResult.fromJson(e))
        .toList();
  }

  // Réinitialiser toutes les données
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userScoreKey);
    await prefs.remove(_quizHistoryKey);
  }
}

