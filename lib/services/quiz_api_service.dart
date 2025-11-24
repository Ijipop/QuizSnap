import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/question.dart';
import '../models/category.dart' as models;
import 'interfaces/quiz_api_interface.dart';

// Implémentation pour quiz-api.fr
class QuizApiService implements IQuizApiService {
  // URL corrigée selon la documentation
  static const String baseUrl = 'https://www.quiz-api.fr/api';
  final String apiToken;

  QuizApiService({required this.apiToken});

  @override
  Future<List<Question>> getQuestions({
    int amount = 10,
    int? category,
    String? difficulty,
    String? language,
  }) async {
    try {
      // Construire les paramètres de requête
      final queryParams = <String, String>{
        'limit': amount.toString(),
      };
      
      // Ajouter les paramètres optionnels seulement s'ils sont fournis
      if (language != null && language.isNotEmpty) {
        queryParams['language'] = language;
      }
      if (difficulty != null && difficulty.isNotEmpty) {
        queryParams['difficulty'] = difficulty;
      }
      if (category != null) {
        // Essayer différents formats pour les tags/catégories
        queryParams['tags'] = category.toString();
      }

      final uri = Uri.parse('$baseUrl/questions').replace(
        queryParameters: queryParams,
      );

      // Debug: afficher l'URL complète
      debugPrint('🔍 API Call: $uri');
      debugPrint('🔑 Token: ${apiToken.substring(0, 10)}...');

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $apiToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Timeout: L\'API n\'a pas répondu dans les 10 secondes');
        },
      );

      debugPrint('📡 Response Status: ${response.statusCode}');
      debugPrint('📄 Response Body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');

      // Gérer les différents codes de statut
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        debugPrint('✅ Data received: ${data.runtimeType}');
        
        // quiz-api.fr retourne les données dans data['data']
        List<dynamic> questionsData;
        if (data['data'] != null) {
          questionsData = data['data'] as List;
          debugPrint('📦 Found ${questionsData.length} questions in data.data');
        } else if (data is List) {
          questionsData = data;
          debugPrint('📦 Found ${questionsData.length} questions (direct list)');
        } else if (data['questions'] != null) {
          questionsData = data['questions'] as List;
          debugPrint('📦 Found ${questionsData.length} questions in data.questions');
        } else {
          debugPrint('⚠️ No questions found in response');
          throw Exception('Aucune question trouvée dans la réponse de l\'API. Format: ${data.keys}');
        }

        if (questionsData.isEmpty) {
          throw Exception('L\'API a retourné une liste vide de questions');
        }

        return questionsData.map((json) {
          // Format quiz-api.fr : { title: { fr: "..." }, answers: [...], ... }
          List<String> answers = [];
          String correctAnswer = '';
          String questionText = '';

          // Extraire le texte de la question (peut être dans title.fr ou question)
          if (json['title'] != null && json['title'] is Map) {
            questionText = json['title']['fr'] ?? 
                          json['title']['en'] ?? 
                          json['title'].values.first?.toString() ?? '';
          } else {
            questionText = json['question']?.toString() ?? 
                          json['text']?.toString() ?? '';
          }

          // Extraire les réponses
          if (json['answers'] != null) {
            final answersList = json['answers'] as List;
            for (var answer in answersList) {
              String answerText = '';
              if (answer is Map) {
                answerText = answer['text'] ?? 
                            answer['answer'] ?? 
                            answer['fr'] ?? 
                            answer.toString();
                if (answer['correct'] == true || answer['is_correct'] == true) {
                  correctAnswer = answerText;
                }
              } else {
                answerText = answer.toString();
              }
              if (answerText.isNotEmpty) {
                answers.add(answerText);
              }
            }
          } else if (json['correct_answer'] != null) {
            // Format alternatif (Open Trivia style)
            correctAnswer = json['correct_answer'].toString();
            final incorrectAnswers = (json['incorrect_answers'] as List?)
                    ?.map((a) => a.toString())
                    .toList() ??
                [];
            answers = [...incorrectAnswers, correctAnswer]..shuffle();
          }

          // Si pas de réponses trouvées, créer des réponses par défaut
          if (answers.isEmpty) {
            answers = ['Réponse A', 'Réponse B', 'Réponse C', 'Réponse D'];
            correctAnswer = answers[0];
          }

          return Question(
            id: json['id']?.toString() ?? 
                 DateTime.now().millisecondsSinceEpoch.toString(),
            question: questionText.isNotEmpty ? questionText : 'Question sans texte',
            answers: answers,
            correctAnswer: correctAnswer.isNotEmpty 
                ? correctAnswer 
                : answers[0],
            category: json['category']?.toString() ?? 
                     json['tags']?.toString() ?? 
                     json['tag']?.toString(),
            difficulty: json['difficulty']?.toString(),
          );
        }).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Erreur d\'authentification: Token invalide ou expiré. Vérifiez votre token API.');
      } else if (response.statusCode == 404) {
        throw Exception('Endpoint non trouvé: ${uri.toString()}');
      } else if (response.statusCode >= 500) {
        throw Exception('Erreur serveur (${response.statusCode}): L\'API est temporairement indisponible');
      } else {
        throw Exception('Erreur HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Error: $e');
      // Propager l'erreur au lieu de retourner des questions par défaut
      rethrow;
    }
  }

  @override
  Future<List<models.Category>> getCategories() async {
    try {
      // Essayer plusieurs endpoints possibles
      final possibleEndpoints = [
        '$baseUrl/tags',
        '$baseUrl/categories',
        'https://quiz-api.fr/api/tags',
        'https://quiz-api.fr/api/categories',
      ];

      http.Response? response;

      for (final endpoint in possibleEndpoints) {
        try {
          final uri = Uri.parse(endpoint);
          response = await http.get(
            uri,
            headers: {
              'Authorization': 'Bearer $apiToken',
              'Accept': 'application/json',
            },
          );

          if (response.statusCode == 200) {
            break; // Succès, on sort de la boucle
          }
        } catch (e) {
          // Essayer le prochain endpoint
          continue;
        }
      }

      if (response == null || response.statusCode != 200) {
        // Si aucun endpoint ne fonctionne, lancer une erreur
        throw Exception('Aucun endpoint de catégories ne fonctionne. Dernière tentative: ${possibleEndpoints.last}');
      }

      // Parser la réponse si on a réussi
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        List<dynamic> categoriesData;
        if (data is List) {
          categoriesData = data;
        } else if (data['data'] != null) {
          categoriesData = data['data'] as List;
        } else if (data['tags'] != null) {
          categoriesData = data['tags'] as List;
        } else {
          categoriesData = [];
        }

        return categoriesData.asMap().entries.map((entry) {
          final json = entry.value;
          return models.Category(
            id: json['id'] ?? entry.key,
            name: json['name'] ?? 
                  json['tag'] ?? 
                  json['title'] ?? 
                  json.toString(),
          );
        }).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Erreur d\'authentification: Token invalide pour les catégories');
      } else {
        throw Exception('Erreur HTTP ${response.statusCode} lors du chargement des catégories: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Categories Error: $e');
      rethrow;
    }
  }

}

