import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

// Service de traduction gratuit
class TranslationService {
  // Cache pour éviter de retraduire les mêmes textes
  final Map<String, String> _translationCache = {};

  // Mapping de traduction pour les catégories communes (plus rapide)
  static const Map<String, String> _categoryTranslations = {
    'General Knowledge': 'Culture générale',
    'Entertainment: Books': 'Divertissement : Livres',
    'Entertainment: Film': 'Divertissement : Cinéma',
    'Entertainment: Music': 'Divertissement : Musique',
    'Entertainment: Musicals & Theatres': 'Divertissement : Comédies musicales et théâtres',
    'Entertainment: Television': 'Divertissement : Télévision',
    'Entertainment: Video Games': 'Divertissement : Jeux vidéo',
    'Entertainment: Board Games': 'Divertissement : Jeux de société',
    'Science & Nature': 'Sciences et nature',
    'Science: Computers': 'Sciences : Informatique',
    'Science: Mathematics': 'Sciences : Mathématiques',
    'Mythology': 'Mythologie',
    'Sports': 'Sports',
    'Geography': 'Géographie',
    'History': 'Histoire',
    'Politics': 'Politique',
    'Art': 'Art',
    'Celebrities': 'Célébrités',
    'Animals': 'Animaux',
    'Vehicles': 'Véhicules',
    'Entertainment: Comics': 'Divertissement : Bandes dessinées',
    'Science: Gadgets': 'Sciences : Gadgets',
    'Entertainment: Japanese Anime & Manga': 'Divertissement : Anime et Manga japonais',
    'Entertainment: Cartoon & Animations': 'Divertissement : Dessins animés',
  };

  // Mapping de traduction pour les réponses courantes
  static const Map<String, String> _commonTranslations = {
    'Spanish': 'Espagnol',
    'French': 'Français',
    'English': 'Anglais',
    'German': 'Allemand',
    'Italian': 'Italien',
    'Portuguese': 'Portugais',
    'Clubs': 'Trèfles',
    'Panther': 'Panthère',
    'Puma': 'Puma',
    'Weave': 'Tisser',
  };

  /// Vérifier si un texte doit être traduit
  bool _shouldTranslate(String text) {
    // Ne pas traduire les nombres purs (années, etc.)
    if (RegExp(r'^\d+$').hasMatch(text.trim())) {
      return false;
    }
    
    // Ne pas traduire les noms de langues courants
    final languageNames = ['spanish', 'french', 'english', 'german', 'italian', 'portuguese'];
    if (languageNames.contains(text.trim().toLowerCase())) {
      return false;
    }
    
    // Ne pas traduire les mots très courts (probablement des noms propres)
    if (text.trim().length <= 2) {
      return false;
    }
    
    // Ne pas traduire si le texte contient principalement des caractères non-latins
    // (déjà dans une autre langue comme le japonais)
    final nonLatinChars = RegExp(r'[^\x00-\x7F]').allMatches(text).length;
    if (nonLatinChars > text.length * 0.3) {
      return false;
    }
    
    return true;
  }

  /// Traduire un texte de l'anglais vers le français
  Future<String> translateToFrench(String text) async {
    // Si vide, retourner tel quel
    if (text.isEmpty) return text;

    // Vérifier le cache
    if (_translationCache.containsKey(text)) {
      return _translationCache[text]!;
    }

    // Vérifier si le texte doit être traduit
    if (!_shouldTranslate(text)) {
      _translationCache[text] = text;
      return text;
    }

    // Vérifier le mapping de catégories d'abord (instantané)
    if (_categoryTranslations.containsKey(text)) {
      final translated = _categoryTranslations[text]!;
      _translationCache[text] = translated;
      return translated;
    }

    // Vérifier le mapping de traductions courantes
    if (_commonTranslations.containsKey(text)) {
      final translated = _commonTranslations[text]!;
      _translationCache[text] = translated;
      return translated;
    }

    // Essayer MyMemory API (plus fiable que LibreTranslate)
    try {
      final translated = await _translateWithMyMemory(text);
      if (translated != null && 
          translated.isNotEmpty && 
          translated != text &&
          translated.toLowerCase() != text.toLowerCase()) {
        _translationCache[text] = translated;
        return translated;
      }
    } catch (e) {
      // Ne pas logger les erreurs pour les textes qui ne doivent pas être traduits
      if (_shouldTranslate(text)) {
        debugPrint('MyMemory error: $e');
      }
    }

    // Si toutes les APIs échouent, retourner le texte original
    // (Ne pas logger pour éviter le spam dans les logs)
    _translationCache[text] = text;
    return text;
  }

  /// Traduire avec MyMemory API (gratuit, pas de clé requise)
  Future<String?> _translateWithMyMemory(String text) async {
    try {
      // Limiter la longueur du texte (MyMemory a une limite)
      final textToTranslate = text.length > 500 ? text.substring(0, 500) : text;
      
      final uri = Uri.parse('https://api.mymemory.translated.net/get').replace(
        queryParameters: {
          'q': textToTranslate,
          'langpair': 'en|fr',
        },
      );

      final response = await http.get(uri).timeout(
        const Duration(seconds: 8),
        onTimeout: () {
          throw Exception('MyMemory timeout');
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['responseStatus'] == 200) {
          final translated = data['responseData']?['translatedText'] as String?;
          if (translated != null && translated.isNotEmpty) {
            return translated;
          }
        }
      }
    } catch (e) {
      debugPrint('MyMemory translation error: $e');
    }
    return null;
  }

  /// Traduire une liste de textes en parallèle
  Future<List<String>> translateList(List<String> texts) async {
    final futures = texts.map((text) => translateToFrench(text));
    return await Future.wait(futures);
  }

  /// Vider le cache
  void clearCache() {
    _translationCache.clear();
  }
}

