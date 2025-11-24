import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/question.dart';
import '../models/category.dart' as models;
import 'interfaces/quiz_api_interface.dart';
import 'translation_service.dart';

// Implémentation pour Open Trivia DB (exemple d'alternative)
// Vous pouvez facilement ajouter d'autres implémentations
class OpenTriviaService implements IQuizApiService {
  static const String baseUrl = 'https://opentdb.com/api.php';
  final TranslationService _translationService = TranslationService();
  
  // Rate limiting : Open Trivia DB limite à 1 requête par seconde
  DateTime? _lastRequestTime;
  static const Duration _minRequestInterval = Duration(seconds: 1);

  @override
  Future<List<Question>> getQuestions({
    int amount = 10,
    int? category,
    String? difficulty,
    String? language,
  }) async {
    try {
      // Construire l'URL selon le format Open Trivia DB
      // https://opentdb.com/api.php?amount=10&difficulty=medium&type=multiple
      final queryParams = <String, String>{
        'amount': amount.toString(),
        'type': 'multiple', // Toujours multiple choice
        if (category != null) 'category': category.toString(),
        if (difficulty != null) 'difficulty': difficulty,
      };

      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);

      debugPrint('🔍 Open Trivia DB Call: $uri');

      // Rate limiting : attendre si nécessaire
      await _waitForRateLimit();

      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Timeout: L\'API n\'a pas répondu dans les 10 secondes');
        },
      );

      debugPrint('📡 Response Status: ${response.statusCode}');

      // Gérer le rate limiting (429)
      if (response.statusCode == 429) {
        debugPrint('⚠️ Rate limit atteint, attente de 3 secondes...');
        await Future.delayed(const Duration(seconds: 3));
        // Retry avec un délai supplémentaire
        await _waitForRateLimit();
        await Future.delayed(const Duration(seconds: 1)); // Délai supplémentaire
        final retryResponse = await http.get(uri).timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            throw Exception('Timeout: L\'API n\'a pas répondu dans les 15 secondes');
          },
        );
        if (retryResponse.statusCode == 200) {
          return _processQuestionsResponse(retryResponse, language);
        } else if (retryResponse.statusCode == 429) {
          // Si encore 429, attendre plus longtemps
          debugPrint('⚠️ Rate limit encore atteint, attente de 5 secondes...');
          await Future.delayed(const Duration(seconds: 5));
          await _waitForRateLimit();
          final secondRetryResponse = await http.get(uri).timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw Exception('Timeout: L\'API n\'a pas répondu dans les 15 secondes');
            },
          );
          if (secondRetryResponse.statusCode == 200) {
            return _processQuestionsResponse(secondRetryResponse, language);
          } else {
            throw Exception('Failed to load questions: HTTP ${secondRetryResponse.statusCode} (après 2 retries). Veuillez patienter quelques instants avant de réessayer.');
          }
        } else {
          throw Exception('Failed to load questions: HTTP ${retryResponse.statusCode} (après retry)');
        }
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Vérifier le response_code (0 = success)
        if (data['response_code'] != 0) {
          throw Exception('API Error: response_code ${data['response_code']}');
        }

        return _processQuestionsResponse(response, language);
      } else {
        throw Exception('Failed to load questions: HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Open Trivia DB Error: $e');
      rethrow;
    }
  }

  @override
  Future<List<models.Category>> getCategories() async {
    try {
      final uri = Uri.parse('https://opentdb.com/api_category.php');
      
      debugPrint('🔍 Fetching categories from: $uri');

      // Rate limiting : attendre si nécessaire
      await _waitForRateLimit();

      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Timeout: L\'API n\'a pas répondu dans les 10 secondes');
        },
      );

      debugPrint('📡 Categories Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final categories = data['trivia_categories'] as List;
        
        debugPrint('✅ Received ${categories.length} categories from Open Trivia DB');
        
        // Traduire les catégories en français
        final translatedCategories = <models.Category>[];
        for (final json in categories) {
          final originalName = json['name'] as String;
          // Utiliser le service de traduction (qui utilise le mapping en priorité)
          final translatedName = await _translationService
              .translateToFrench(originalName)
              .timeout(const Duration(seconds: 2), onTimeout: () => originalName);
          
          translatedCategories.add(models.Category(
            id: json['id'] as int,
            name: translatedName,
          ));
        }
        
        return translatedCategories;
      } else {
        throw Exception('Failed to load categories: HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Categories Error: $e');
      rethrow;
    }
  }

  /// Attendre si nécessaire pour respecter le rate limit
  Future<void> _waitForRateLimit() async {
    if (_lastRequestTime != null) {
      final timeSinceLastRequest = DateTime.now().difference(_lastRequestTime!);
      if (timeSinceLastRequest < _minRequestInterval) {
        final waitTime = _minRequestInterval - timeSinceLastRequest;
        debugPrint('⏳ Rate limiting: attente de ${waitTime.inMilliseconds}ms');
        await Future.delayed(waitTime);
      }
    }
    _lastRequestTime = DateTime.now();
  }

  /// Traiter la réponse de l'API pour extraire les questions
  Future<List<Question>> _processQuestionsResponse(
    http.Response response,
    String? language,
  ) async {
    final data = json.decode(response.body);
    
    // Vérifier le response_code (0 = success)
    if (data['response_code'] != 0) {
      throw Exception('API Error: response_code ${data['response_code']}');
    }

    final results = data['results'] as List;
    debugPrint('✅ Received ${results.length} questions from Open Trivia DB');

    if (results.isEmpty) {
      throw Exception('Aucune question retournée par l\'API');
    }
    
    // Générer des IDs uniques pour chaque question
    final questions = <Question>[];
    
    for (final entry in results.asMap().entries) {
      final index = entry.key;
      final json = entry.value;
      
      // Décoder le HTML d'abord
      final questionText = _decodeHtml(json['question']);
      final incorrectAnswers = (json['incorrect_answers'] as List)
          .map((a) => _decodeHtml(a.toString()))
          .toList();
      final correctAnswer = _decodeHtml(json['correct_answer']);
      
          // Traduire uniquement la question si la langue demandée est le français
          // Les réponses restent en anglais pour accélérer le chargement
          String translatedQuestion = questionText;
          String translatedCorrectAnswer = correctAnswer;
          List<String> translatedIncorrectAnswers = incorrectAnswers;
          
          if (language == 'fr') {
            try {
              // Traduire uniquement la question (avec timeout pour éviter les blocages)
              translatedQuestion = await _translationService
                  .translateToFrench(questionText)
                  .timeout(const Duration(seconds: 5), onTimeout: () {
                debugPrint('⚠️ Question translation timeout');
                return questionText;
              });
              
              // Les réponses restent en anglais (pas de traduction)
              // Cela réduit le nombre d'appels API et accélère le chargement
            } catch (e) {
              debugPrint('⚠️ Translation error: $e - Using original text');
              // En cas d'erreur, utiliser le texte original
              translatedQuestion = questionText;
            }
          }
      
      final allAnswers = [...translatedIncorrectAnswers, translatedCorrectAnswer]..shuffle();
      
      questions.add(Question(
        id: '${DateTime.now().millisecondsSinceEpoch}_$index',
        question: translatedQuestion,
        answers: allAnswers,
        correctAnswer: translatedCorrectAnswer,
        category: json['category'],
        difficulty: json['difficulty'],
      ));
    }
    
    return questions;
  }

  String _decodeHtml(String html) {
    return html
        .replaceAll('&quot;', '"')
        .replaceAll('&#039;', "'")
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>');
  }
}

