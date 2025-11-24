// Modèle pour une question de quiz
class Question {
  final String id;
  final String question;
  final List<String> answers;
  final String correctAnswer;
  final String? category;
  final String? difficulty;

  Question({
    required this.id,
    required this.question,
    required this.answers,
    required this.correctAnswer,
    this.category,
    this.difficulty,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] ?? '',
      question: json['question'] ?? '',
      answers: List<String>.from(json['answers'] ?? []),
      correctAnswer: json['correct_answer'] ?? '',
      category: json['category'],
      difficulty: json['difficulty'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answers': answers,
      'correct_answer': correctAnswer,
      'category': category,
      'difficulty': difficulty,
    };
  }
}

