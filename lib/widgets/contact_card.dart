/* 
 * MSSV: 102230299
 * Họ và tên: Nguyễn Chánh Khiêm
 * Lớp: 23T_DT3
 */

import 'package:flutter/material.dart';
import '../models/contact.dart';

class ContactCard extends StatelessWidget {
  final Contact contact;
  final VoidCallback onTap;
  final VoidCallback onCall;
  final VoidCallback onMessage;
  final VoidCallback onToggleFavorite;
  final Future<bool?> Function() onConfirmDismiss;
  final VoidCallback onDismissed;

  const ContactCard({
    super.key,
    required this.contact,
    required this.onTap,
    required this.onCall,
    required this.onMessage,
    required this.onToggleFavorite,
    required this.onConfirmDismiss,
    required this.onDismissed,
  });

  Color _getCategoryColor(String category, bool isDark) {
    switch (category) {
      case 'Gia đình':
        return Colors.purple;
      case 'Bạn bè':
        return Colors.green;
      case 'Công việc':
        return Colors.indigo;
      case 'VIP':
        return Colors.amber.shade800;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final categoryColor = _getCategoryColor(contact.category, isDark);

    return Dismissible(
      key: Key(contact.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) => onConfirmDismiss(),
      onDismissed: (direction) => onDismissed(),
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red.shade600,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: const [
            Text(
              'Xóa liên hệ',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.delete_forever, color: Colors.white, size: 28),
          ],
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  // Avatar với chữ cái đầu và Badge Yêu thích (Custom Layout)
                  Stack(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              contact.avatarColor.withValues(alpha: 0.85),
                              contact.avatarColor,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: contact.avatarColor.withValues(alpha: 0.35),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          contact.initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      if (contact.isFavorite)
                        Positioned(
                          right: -1,
                          bottom: -1,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E293B) : Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.star_rounded,
                              size: 16,
                              color: Color(0xFFFFB300),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),

                  // Thông tin Tên, Số điện thoại và Nhóm
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contact.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.titleMedium?.color,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(
                              Icons.phone_outlined,
                              size: 13,
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              contact.phone,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: categoryColor.withValues(alpha: isDark ? 0.25 : 0.12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: categoryColor.withValues(alpha: 0.3),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            contact.category,
                            style: TextStyle(
                              fontSize: 11,
                              color: categoryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Nút thao tác nhanh: Gọi, Nhắn tin, Yêu thích
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Nút sao yêu thích nhanh
                      IconButton(
                        tooltip: contact.isFavorite ? 'Bỏ yêu thích' : 'Thêm vào yêu thích',
                        icon: Icon(
                          contact.isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                          color: contact.isFavorite
                              ? const Color(0xFFFFB300)
                              : (isDark ? Colors.grey.shade500 : Colors.grey.shade400),
                          size: 24,
                        ),
                        onPressed: onToggleFavorite,
                      ),

                      // Nút gọi nhanh
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: isDark ? 0.25 : 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          tooltip: 'Gọi điện',
                          icon: const Icon(Icons.call, color: Colors.green, size: 19),
                          onPressed: onCall,
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Nút nhắn tin nhanh
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: isDark ? 0.25 : 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          tooltip: 'Nhắn tin',
                          icon: const Icon(Icons.sms, color: Colors.blue, size: 18),
                          onPressed: onMessage,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
