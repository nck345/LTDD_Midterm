/* 
 * MSSV: 102230299
 * Họ và tên: Nguyễn Chánh Khiêm
 * Lớp: 23T_DT3
 */

import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../services/contact_service.dart';

class AddEditContactScreen extends StatefulWidget {
  final Contact? contact;
  final ContactService service;

  const AddEditContactScreen({
    super.key,
    this.contact,
    required this.service,
  });

  @override
  State<AddEditContactScreen> createState() => _AddEditContactScreenState();
}

class _AddEditContactScreenState extends State<AddEditContactScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _noteController;

  late String _selectedCategory;
  late int _selectedColor;
  late bool _isFavorite;

  bool get _isEditing => widget.contact != null;

  @override
  void initState() {
    super.initState();
    final c = widget.contact;
    _nameController = TextEditingController(text: c?.name ?? '');
    _phoneController = TextEditingController(text: c?.phone ?? '');
    _emailController = TextEditingController(text: c?.email ?? '');
    _addressController = TextEditingController(text: c?.address ?? '');
    _noteController = TextEditingController(text: c?.note ?? '');

    _selectedCategory = c?.category ?? 'Bạn bè';
    _selectedColor = c?.avatarColorValue ?? Contact.availableColors[0];
    _isFavorite = c?.isFavorite ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _saveContact() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final newContact = Contact(
      id: widget.contact?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      category: _selectedCategory,
      address: _addressController.text.trim(),
      note: _noteController.text.trim(),
      isFavorite: _isFavorite,
      avatarColorValue: _selectedColor,
      createdAt: widget.contact?.createdAt ?? DateTime.now(),
    );

    if (_isEditing) {
      await widget.service.updateContact(newContact);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green.shade700,
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('Đã cập nhật thông tin "${newContact.name}"!'),
              ],
            ),
          ),
        );
        Navigator.of(context).pop(newContact);
      }
    } else {
      await widget.service.addContact(newContact);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green.shade700,
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('Đã thêm "${newContact.name}" vào danh bạ!'),
              ],
            ),
          ),
        );
        Navigator.of(context).pop(newContact);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Chỉnh sửa liên hệ' : 'Thêm danh bạ mới'),
        actions: [
          IconButton(
            tooltip: 'Lưu',
            icon: const Icon(Icons.check, size: 28),
            onPressed: _saveContact,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar Preview với Initials tự động thay đổi theo Họ và tên
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 46,
                          backgroundColor: Color(_selectedColor),
                          child: Text(
                            _nameController.text.trim().isNotEmpty
                                ? Contact(
                                    id: '',
                                    name: _nameController.text,
                                    phone: '',
                                    avatarColorValue: _selectedColor,
                                    createdAt: DateTime.now(),
                                  ).initials
                                : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (_isFavorite)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.amber,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.star,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Chọn màu đại diện avatar:',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    // Palette chọn màu
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: Contact.availableColors.map((colorValue) {
                        final isPicked = _selectedColor == colorValue;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedColor = colorValue;
                            });
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Color(colorValue),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isPicked ? Colors.white : Colors.transparent,
                                width: 2,
                              ),
                              boxShadow: isPicked
                                  ? [
                                      BoxShadow(
                                        color: Color(colorValue).withValues(alpha: 0.6),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: isPicked
                                ? const Icon(Icons.check, color: Colors.white, size: 18)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Trường 1: Họ và tên (Bắt buộc)
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Họ và tên *',
                  hintText: 'Nhập họ và tên',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                onChanged: (_) => setState(() {}),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Họ và tên không được để trống!';
                  }
                  if (val.trim().length < 2) {
                    return 'Họ và tên cần ít nhất 2 ký tự!';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Trường 2: Số điện thoại (Bắt buộc)
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại *',
                  hintText: 'Ví dụ: 0905123456 hoặc +84905123456',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Số điện thoại không được để trống!';
                  }
                  final clean = val.replaceAll(RegExp(r'[\s\-\.]'), '');
                  final phoneRegex = RegExp(r'^(\+84|0)[0-9]{8,11}$');
                  if (!phoneRegex.hasMatch(clean)) {
                    return 'Số điện thoại không hợp lệ (9-11 chữ số, bắt đầu bằng 0 hoặc +84)!';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Trường 3: Email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Ví dụ: example@domain.com',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (val) {
                  if (val != null && val.trim().isNotEmpty) {
                    final emailRegex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$');
                    if (!emailRegex.hasMatch(val.trim())) {
                      return 'Định dạng email không hợp lệ!';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Trường 4: Nhóm / Phân loại (Category)
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Nhóm liên hệ',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: Contact.categories
                    .where((c) => c != 'Tất cả')
                    .map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedCategory = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Trường 5: Địa chỉ
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Địa chỉ',
                  hintText: 'Nhập địa chỉ liên hệ',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 16),

              // Trường 6: Ghi chú
              TextFormField(
                controller: _noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Ghi chú',
                  hintText: 'Thêm thông tin ghi chú...',
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
              ),
              const SizedBox(height: 16),

              // Tùy chọn: Đánh dấu Yêu thích
              Card(
                elevation: 0,
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: SwitchListTile(
                  title: const Text(
                    'Đánh dấu Yêu thích (Favorites)',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  subtitle: const Text(
                    'Ưu tiên hiển thị và lọc nhanh trong danh bạ',
                    style: TextStyle(fontSize: 12),
                  ),
                  secondary: Icon(
                    _isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: _isFavorite ? Colors.amber : Colors.grey,
                  ),
                  value: _isFavorite,
                  activeThumbColor: Colors.amber,
                  onChanged: (val) {
                    setState(() {
                      _isFavorite = val;
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Nút bấm Lưu
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                  ),
                  onPressed: _saveContact,
                  icon: const Icon(Icons.save),
                  label: Text(
                    _isEditing ? 'LƯU THAY ĐỔI' : 'THÊM VÀO DANH BẠ',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
