/* 
 * MSSV: 102230299
 * Họ và tên: Nguyễn Chánh Khiêm
 * Lớp: 23T_DT3
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/contact.dart';
import '../services/contact_service.dart';
import 'add_edit_contact_screen.dart';
import 'call_simulation_screen.dart';
import 'sms_dialog.dart';

class ContactDetailScreen extends StatefulWidget {
  final Contact contact;
  final ContactService service;

  const ContactDetailScreen({
    super.key,
    required this.contact,
    required this.service,
  });

  @override
  State<ContactDetailScreen> createState() => _ContactDetailScreenState();
}

class _ContactDetailScreenState extends State<ContactDetailScreen> {
  late Contact _currentContact;

  @override
  void initState() {
    super.initState();
    _currentContact = widget.contact;
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã sao chép $label vào bộ nhớ tạm!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa liên hệ'),
        content: Text('Bạn có chắc chắn muốn xóa "${_currentContact.name}" khỏi danh bạ không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('HỦY BỎ'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('XÓA'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final removedData = await widget.service.deleteContact(_currentContact.id);
      if (mounted) {
        Navigator.of(context).pop(); // Quay về màn hình chính
        if (removedData != null) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã xóa "${removedData.contact.name}"'),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
              showCloseIcon: true,
              dismissDirection: DismissDirection.horizontal,
              action: SnackBarAction(
                label: 'HOÀN TÁC',
                textColor: Colors.amberAccent,
                onPressed: () {
                  widget.service.restoreContact(removedData.contact, removedData.index);
                },
              ),
            ),
          );
        }
      }
    }
  }

  void _editContact() async {
    final updated = await Navigator.of(context).push<Contact>(
      MaterialPageRoute(
        builder: (_) => AddEditContactScreen(
          contact: _currentContact,
          service: widget.service,
        ),
      ),
    );
    if (updated != null && mounted) {
      setState(() {
        _currentContact = updated;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết liên hệ'),
        actions: [
          IconButton(
            tooltip: _currentContact.isFavorite ? 'Bỏ yêu thích' : 'Yêu thích',
            icon: Icon(
              _currentContact.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
              color: _currentContact.isFavorite ? const Color(0xFFFFB300) : null,
              size: 28,
            ),
            onPressed: () async {
              await widget.service.toggleFavorite(_currentContact.id);
              setState(() {
                _currentContact = _currentContact.copyWith(
                  isFavorite: !_currentContact.isFavorite,
                );
              });
            },
          ),
          IconButton(
            tooltip: 'Chỉnh sửa',
            icon: const Icon(Icons.edit_outlined),
            onPressed: _editContact,
          ),
          IconButton(
            tooltip: 'Xóa liên hệ',
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header lớn với Avatar và Tên
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 54,
                    backgroundColor: _currentContact.avatarColor,
                    child: Text(
                      _currentContact.initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _currentContact.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Nhóm: ${_currentContact.category}',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Thanh tác vụ nhanh (Quick actions)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _QuickActionButton(
                        icon: Icons.call,
                        label: 'Gọi điện',
                        color: Colors.green,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => CallSimulationScreen(contact: _currentContact),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 16),
                      _QuickActionButton(
                        icon: Icons.sms,
                        label: 'Nhắn tin',
                        color: Colors.blue,
                        onTap: () {
                          SmsDialog.show(context, _currentContact);
                        },
                      ),
                      const SizedBox(width: 16),
                      _QuickActionButton(
                        icon: Icons.copy,
                        label: 'Sao chép',
                        color: Colors.teal,
                        onTap: () => _copyToClipboard(_currentContact.phone, 'số điện thoại'),
                      ),
                      const SizedBox(width: 16),
                      _QuickActionButton(
                        icon: Icons.edit,
                        label: 'Chỉnh sửa',
                        color: Colors.orange,
                        onTap: _editContact,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Các mục chi tiết
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _DetailCard(
                    icon: Icons.phone,
                    title: 'Số điện thoại',
                    value: _currentContact.phone,
                    trailing: IconButton(
                      icon: const Icon(Icons.copy, size: 20),
                      onPressed: () => _copyToClipboard(_currentContact.phone, 'số điện thoại'),
                      tooltip: 'Sao chép',
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CallSimulationScreen(contact: _currentContact),
                        ),
                      );
                    },
                  ),
                  if (_currentContact.email.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _DetailCard(
                      icon: Icons.email,
                      title: 'Email',
                      value: _currentContact.email,
                      trailing: IconButton(
                        icon: const Icon(Icons.copy, size: 20),
                        onPressed: () => _copyToClipboard(_currentContact.email, 'email'),
                        tooltip: 'Sao chép',
                      ),
                    ),
                  ],
                  if (_currentContact.address.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _DetailCard(
                      icon: Icons.location_on,
                      title: 'Địa chỉ',
                      value: _currentContact.address,
                    ),
                  ],
                  if (_currentContact.note.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _DetailCard(
                      icon: Icons.notes,
                      title: 'Ghi chú',
                      value: _currentContact.note,
                    ),
                  ],
                  const SizedBox(height: 10),
                  _DetailCard(
                    icon: Icons.calendar_today_outlined,
                    title: 'Ngày thêm vào danh bạ',
                    value: '${_currentContact.createdAt.day.toString().padLeft(2, '0')}/'
                        '${_currentContact.createdAt.month.toString().padLeft(2, '0')}/'
                        '${_currentContact.createdAt.year}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _DetailCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _DetailCard({
    required this.icon,
    required this.title,
    required this.value,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: trailing,
      ),
    );
  }
}
