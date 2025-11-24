// Modèle pour le résultat d'un quiz
class QuizResult {
  final int totalQuestions;
  final int correctAnswers;
  final int score;
  final String category;
  final DateTime completedAt;

  QuizResult({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.score,
    required this.category,
    required this.completedAt,
  });

  double get percentage => (correctAnswers / totalQuestions) * 100;

  Map<String, dynamic> toJson() {
    return {
      'total_questions': totalQuestions,
      'correct_answers': correctAnswers,
      'score': score,
      'category': category,
      'completed_at': completedAt.toIso8601String(),
    };
  }

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      totalQuestions: json['total_questions'] ?? 0,
      correctAnswers: json['correct_answers'] ?? 0,
      score: json['score'] ?? 0,
      category: json['category'] ?? '',
      completedAt: DateTime.parse(json['completed_at']),
    );
  }
}

