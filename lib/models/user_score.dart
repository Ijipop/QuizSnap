// Modèle pour les statistiques utilisateur
class UserScore {
  final int totalQuizzes;
  final int totalCorrectAnswers;
  final int totalQuestions;
  final Map<String, int> categoryScores;

  UserScore({
    required this.totalQuizzes,
    required this.totalCorrectAnswers,
    required this.totalQuestions,
    required this.categoryScores,
  });

  double get overallAccuracy {
    if (totalQuestions == 0) return 0.0;
    return (totalCorrectAnswers / totalQuestions) * 100;
  }

  Map<String, dynamic> toJson() {
    return {
      'total_quizzes': totalQuizzes,
      'total_correct_answers': totalCorrectAnswers,
      'total_questions': totalQuestions,
      'category_scores': categoryScores,
    };
  }

  factory UserScore.fromJson(Map<String, dynamic> json) {
    return UserScore(
      totalQuizzes: json['total_quizzes'] ?? 0,
      totalCorrectAnswers: json['total_correct_answers'] ?? 0,
      totalQuestions: json['total_questions'] ?? 0,
      categoryScores: Map<String, int>.from(json['category_scores'] ?? {}),
    );
  }
}

