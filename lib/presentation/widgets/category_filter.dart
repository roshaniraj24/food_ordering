import 'package:flutter/material.dart';

class CategoryFilter extends StatelessWidget {
  final String? selectedCategory;
  final double? selectedMinRating;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<double?> onRatingChanged;

  const CategoryFilter({
    super.key,
    required this.selectedCategory,
    required this.selectedMinRating,
    required this.onCategoryChanged,
    required this.onRatingChanged,
  });

  static const List<String> categories = [
    'Italian',
    'American',
    'Japanese',
    'Mexican',
    'Chinese',
    'Indian',
  ];

  static const List<double> ratings = [4.0, 4.5];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Category filter
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // All categories chip
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _buildNeonChip(
                      'All',
                      selectedCategory == null,
                      () => onCategoryChanged(null),
                    ),
                  ),
                  
                  // Category chips
                  ...categories.map((category) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: _buildNeonChip(
                        category,
                        selectedCategory == category,
                        () => onCategoryChanged(selectedCategory == category ? null : category),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Neon rating filter dropdown
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selectedMinRating != null
                    ? const Color(0xFFE84393).withOpacity(0.6)
                    : const Color(0xFF74B9FF).withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: selectedMinRating != null
                  ? [
                      BoxShadow(
                        color: const Color(0xFFE84393).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: PopupMenuButton<double?>(
              icon: ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: selectedMinRating != null
                      ? [const Color(0xFFE84393), const Color(0xFF6C5CE7)]
                      : [const Color(0xFF74B9FF).withOpacity(0.6), const Color(0xFF00CEC9).withOpacity(0.4)],
                ).createShader(bounds),
                child: const Icon(
                  Icons.star,
                  color: Colors.white,
                ),
              ),
              tooltip: 'Filter by rating',
              onSelected: onRatingChanged,
              color: const Color(0xFF21262D),
              itemBuilder: (context) => [
                PopupMenuItem<double?>(
                  value: null,
                  child: Row(
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFF74B9FF), Color(0xFFE84393)],
                        ).createShader(bounds),
                        child: const Icon(Icons.clear, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      const Text('All ratings', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                ...ratings.map((rating) {
                  return PopupMenuItem<double?>(
                    value: rating,
                    child: Row(
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFFFDCB6E), Color(0xFFE84393)],
                          ).createShader(bounds),
                          child: const Icon(
                            Icons.star,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text('${rating.toString()}+', style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNeonChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF6C5CE7), Color(0xFFE84393)],
                )
              : null,
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : const Color(0xFF74B9FF).withOpacity(0.5),
            width: 1.5,
          ),
          color: isSelected ? null : const Color(0xFF161B22).withOpacity(0.6),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFE84393).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: const Color(0xFF6C5CE7).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: const Color(0xFF74B9FF).withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFFB8C5D1),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}