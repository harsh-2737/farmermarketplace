import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  final String categoryName;
  final IconData icon;

  const CategoryCard({
    super.key,
    required this.categoryName,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 35,
          ),
          const SizedBox(height: 8),
          Text(
            categoryName,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}