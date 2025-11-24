# Services API - Documentation

## Architecture modulaire

L'architecture est conçue pour faciliter le changement d'API. Tous les services API implémentent l'interface `IQuizApiService`.

## Structure

```
services/
├── interfaces/
│   └── quiz_api_interface.dart    # Interface abstraite
├── api_service.dart                # Service principal (point de changement)
├── quiz_api_service.dart          # Implémentation quiz-api.fr
└── open_trivia_service.dart       # Implémentation Open Trivia DB (exemple)
```

## Comment changer d'API ?

### Option 1 : Changer dans `api_service.dart`

Ouvrez `lib/services/api_service.dart` et modifiez le constructeur :

```dart
ApiService() {
  // ✅ ACTUELLEMENT : quiz-api.fr
  _apiService = QuizApiService(
    apiToken: 'VOTRE_TOKEN',
  );

  // Pour utiliser Open Trivia DB :
  // _apiService = OpenTriviaService();

  // Pour une nouvelle API, créez une implémentation de IQuizApiService
  // _apiService = MaNouvelleApiService();
}
```

### Option 2 : Créer une nouvelle implémentation

1. Créez un nouveau fichier (ex: `ma_nouvelle_api_service.dart`)
2. Implémentez `IQuizApiService` :

```dart
import 'interfaces/quiz_api_interface.dart';
import '../models/question.dart';
import '../models/category.dart';

class MaNouvelleApiService implements IQuizApiService {
  @override
  Future<List<Question>> getQuestions({...}) async {
    // Votre implémentation
  }

  @override
  Future<List<Category>> getCategories() async {
    // Votre implémentation
  }
}
```

3. Utilisez-la dans `api_service.dart`

## APIs disponibles

### ✅ Quiz API (quiz-api.fr) - ACTUELLEMENT UTILISÉ
- **Avantages** : Multilingue (français), gratuit
- **Token requis** : Oui
- **Fichier** : `quiz_api_service.dart`

### Open Trivia DB
- **Avantages** : Gratuit, pas de token, grande base
- **Inconvénients** : Principalement anglais
- **Fichier** : `open_trivia_service.dart`

## Notes importantes

- Tous les services retournent les mêmes modèles (`Question`, `Category`)
- Le reste de l'application (providers, screens) n'a pas besoin de changer
- Seul `api_service.dart` doit être modifié pour changer d'API

