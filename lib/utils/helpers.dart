// Fonctions helper utilitaires
class Helpers {
  // Mélanger une liste
  static List<T> shuffleList<T>(List<T> list) {
    final shuffled = List<T>.from(list);
    shuffled.shuffle();
    return shuffled;
  }

  // Formater un pourcentage
  static String formatPercentage(double value) {
    return '${value.toStringAsFixed(1)}%';
  }

  // Formater un temps en secondes
  static String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  // Obtenir un message de félicitation basé sur le score
  static String getScoreMessage(double percentage) {
    if (percentage >= 90) return 'Excellent ! 🎉';
    if (percentage >= 70) return 'Très bien ! 👍';
    if (percentage >= 50) return 'Pas mal ! 😊';
    return 'Continuez vos efforts ! 💪';
  }
}

