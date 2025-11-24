import 'package:flutter/material.dart';

// Widget pour afficher une carte de catégorie
class CategoryCard extends StatelessWidget {
  final String categoryName;
  final VoidCallback onTap;
  final String? icon;

  const CategoryCard({
    super.key,
    required this.categoryName,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (icon != null)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Icon(
                    Icons.quiz,
                    size: 32,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              Expanded(
                child: Text(
                  categoryName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

