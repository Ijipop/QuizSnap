import '../models/question.dart';
import '../models/quiz_result.dart';

// Service pour la logique métier du quiz
class QuizService {
  int calculateScore({
    required List<Question> questions,
    required Map<int, String> userAnswers,
  }) {
    int score = 0;
    
    for (int i = 0; i < questions.length; i++) {
      final question = questions[i];
      final userAnswer = userAnswers[i];
      
      if (userAnswer == question.correctAnswer) {
        score++;
      }
    }
    
    return score;
  }

  QuizResult createResult({
    required List<Question> questions,
    required Map<int, String> userAnswers,
    required String category,
  }) {
    final correctAnswers = calculateScore(
      questions: questions,
      userAnswers: userAnswers,
    );

    return QuizResult(
      totalQuestions: questions.length,
      correctAnswers: correctAnswers,
      score: correctAnswers,
      category: category,
      completedAt: DateTime.now(),
    );
  }

  bool isAnswerCorrect(Question question, String userAnswer) {
    return question.correctAnswer == userAnswer;
  }
}

