import 'package:flutter/material.dart';
import '../utils/theme.dart';

// Widget pour un bouton de réponse
class AnswerButton extends StatelessWidget {
  final String answer;
  final VoidCallback onTap;
  final bool isSelected;
  final bool? isCorrect;
  final bool showResult;

  const AnswerButton({
    super.key,
    required this.answer,
    required this.onTap,
    this.isSelected = false,
    this.isCorrect,
    this.showResult = false,
  });

  @override
  Widget build(BuildContext context) {
    Color? backgroundColor;
    Color? textColor;

    if (showResult && isCorrect != null) {
      if (isCorrect == true) {
        // Cyan néon pour bonne réponse
        backgroundColor = AppColors.success;
        textColor = Theme.of(context).scaffoldBackgroundColor;
      } else if (isSelected && isCorrect == false) {
        // Rouge néon doux pour mauvaise réponse
        backgroundColor = AppColors.error;
        textColor = Colors.white;
      }
    } else if (isSelected) {
      // Violet néon pour sélection
      backgroundColor = AppColors.accent;
      textColor = Colors.white;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ElevatedButton(
        onPressed: showResult ? null : onTap, // Désactiver si résultat affiché
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          minimumSize: const Size(double.infinity, 50),
          padding: const EdgeInsets.all(16),
          disabledBackgroundColor: backgroundColor,
          disabledForegroundColor: textColor,
        ),
        child: Text(
          answer,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

