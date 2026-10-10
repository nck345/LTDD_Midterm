/* 
 * MSSV: 102230299
 * Họ và tên: Nguyễn Chánh Khiêm
 * Lớp: 23T_DT3
 */

import 'package:flutter/material.dart';
import '../services/contact_service.dart';

// Custom layout
class CategoryFilterChips extends StatelessWidget {
  final ContactService service;

  const CategoryFilterChips({
    super.key,
    required this.service,
  });

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Tất cả':
        return Icons.people_alt_outlined;
      case '⭐ Yêu thích':
        return Icons.star_rounded;
      case 'Gia đình':
        return Icons.family_restroom_rounded;
      case 'Bạn bè':
        return Icons.emoji_emotions_outlined;
      case 'Công việc':
        return Icons.work_outline_rounded;
      case 'VIP':
        return Icons.workspace_premium_rounded;
      default:
        return Icons.label_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = [
      'Tất cả',
      '⭐ Yêu thích',
      'Gia đình',
      'Bạn bè',
      'Công việc',
      'VIP',
      'Khác',
    ];

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = service.selectedCategory == cat;
          final count = service.countByCategory(cat);

          final chipColor = isSelected
              ? (isDark ? const Color(0xFF2563EB) : theme.colorScheme.primary)
              : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0));

          final textColor = isSelected
              ? Colors.white
              : (isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155));

          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => service.setCategory(cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: chipColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getCategoryIcon(cat),
                      size: 16,
                      color: textColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      cat,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.25)
                            : (isDark ? Colors.black26 : Colors.white),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
