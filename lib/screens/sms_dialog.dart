/* 
 * MSSV: 102230299
 * Họ và tên: Nguyễn Chánh Khiêm
 * Lớp: 23T_DT3
 */

import 'package:flutter/material.dart';
import '../models/contact.dart';

class SmsDialog extends StatefulWidget {
  final Contact contact;

  const SmsDialog({super.key, required this.contact});

  static Future<void> show(BuildContext context, Contact contact) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SmsDialog(contact: contact),
    );
  }

  @override
  State<SmsDialog> createState() => _SmsDialogState();
}

class _SmsDialogState extends State<SmsDialog> {
  final TextEditingController _msgController = TextEditingController();

  final List<String> _quickTemplates = [
    'Tôi đang bận, sẽ gọi lại cho bạn sau nhé!',
    'Xin chào! Bạn có khỏe không?',
    'Hãy gọi lại cho tôi ngay khi rảnh nhé.',
    'Cảm ơn bạn rất nhiều!',
  ];

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  void _sendSms() {
    final text = _msgController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập nội dung tin nhắn!')),
      );
      return;
    }

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.blue.shade700,
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Đã gửi tin nhắn đến ${widget.contact.name} (${widget.contact.phone})!'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: bottomInset + 20,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: widget.contact.avatarColor,
                child: Text(
                  widget.contact.initials,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gửi tin nhắn đến ${widget.contact.name}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      widget.contact.phone,
                      style: TextStyle(color: isDark ? Colors.white60 : Colors.black54, fontSize: 13),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Mẫu tin nhắn nhanh
          const Text(
            'Tin nhắn mẫu nhanh:',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _quickTemplates.map((template) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    label: Text(
                      template,
                      style: const TextStyle(fontSize: 12),
                    ),
                    onPressed: () {
                      _msgController.text = template;
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Ô soạn tin
          TextField(
            controller: _msgController,
            maxLines: 3,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Nhập nội dung tin nhắn...',
            ),
          ),
          const SizedBox(height: 16),

          // Nút gửi
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _sendSms,
              icon: const Icon(Icons.send),
              label: const Text(
                'GỬI TIN NHẮN (SMS)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
