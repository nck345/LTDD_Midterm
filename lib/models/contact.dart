import 'package:flutter/material.dart';

class Contact {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String category; // 'Gia đình', 'Bạn bè', 'Công việc', 'VIP', 'Khác'
  final String address;
  final String note;
  final bool isFavorite;
  final int avatarColorValue;
  final DateTime createdAt;

  const Contact({
    required this.id,
    required this.name,
    required this.phone,
    this.email = '',
    this.category = 'Bạn bè',
    this.address = '',
    this.note = '',
    this.isFavorite = false,
    required this.avatarColorValue,
    required this.createdAt,
  });

  Contact copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? category,
    String? address,
    String? note,
    bool? isFavorite,
    int? avatarColorValue,
    DateTime? createdAt,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      category: category ?? this.category,
      address: address ?? this.address,
      note: note ?? this.note,
      isFavorite: isFavorite ?? this.isFavorite,
      avatarColorValue: avatarColorValue ?? this.avatarColorValue,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'category': category,
      'address': address,
      'note': note,
      'isFavorite': isFavorite,
      'avatarColorValue': avatarColorValue,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: (json['email'] as String?) ?? '',
      category: (json['category'] as String?) ?? 'Khác',
      address: (json['address'] as String?) ?? '',
      note: (json['note'] as String?) ?? '',
      isFavorite: (json['isFavorite'] as bool?) ?? false,
      avatarColorValue:
          (json['avatarColorValue'] as int?) ?? Colors.blue.toARGB32(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// Trích xuất chữ cái đầu để hiển thị trên Avatar
  String get initials {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    final firstChar = parts[0].isNotEmpty ? parts[0].substring(0, 1) : '';
    final lastChar = parts.last.isNotEmpty ? parts.last.substring(0, 1) : '';
    return '$firstChar$lastChar'.toUpperCase();
  }

  Color get avatarColor => Color(avatarColorValue);

  /// Bảng màu gợi ý cho Avatar
  static const List<int> availableColors = [
    0xFF1E88E5, // Blue
    0xFF43A047, // Green
    0xFFE53935, // Red
    0xFFFB8C00, // Orange
    0xFF8E24AA, // Purple
    0xFF00ACC1, // Cyan
    0xFFD81B60, // Pink
    0xFF3949AB, // Indigo
    0xFF00897B, // Teal
    0xFF6D4C41, // Brown
  ];

  /// Danh mục liên hệ mặc định
  static const List<String> categories = [
    'Tất cả',
    'Gia đình',
    'Bạn bè',
    'Công việc',
    'VIP',
    'Khác',
  ];

  /// Danh sách danh bạ mẫu ban đầu phục vụ chấm bài và trải nghiệm
  static List<Contact> sampleContacts() {
    return [
      Contact(
        id: '1',
        name: 'Nguyễn Chánh Khiêm',
        phone: '0905123456',
        email: 'khiem.nguyen@example.com',
        category: 'VIP',
        address: '54 Nguyễn Lương Bằng, Đà Nẵng',
        note: 'Liên hệ cá nhân',
        isFavorite: true,
        avatarColorValue: 0xFF1E88E5,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      Contact(
        id: '2',
        name: 'Trần Thị Thu Thảo',
        phone: '0912345678',
        email: 'thuthao@gmail.com',
        category: 'Gia đình',
        address: 'Hải Châu, Đà Nẵng',
        note: 'Chị hai',
        isFavorite: true,
        avatarColorValue: 0xFFD81B60,
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
      ),
      Contact(
        id: '3',
        name: 'Lê Hoàng Minh',
        phone: '0987654321',
        email: 'minh.le@example.com',
        category: 'Bạn bè',
        address: 'Liên Chiểu, Đà Nẵng',
        note: 'Bạn cùng lớp',
        isFavorite: false,
        avatarColorValue: 0xFF43A047,
        createdAt: DateTime.now().subtract(const Duration(days: 6)),
      ),
      Contact(
        id: '4',
        name: 'Phạm Quốc Bảo',
        phone: '0935112233',
        email: 'baopq@techcorp.vn',
        category: 'Công việc',
        address: 'Tòa nhà FPT Complex, Đà Nẵng',
        note: 'Trưởng nhóm dự án Flutter',
        isFavorite: true,
        avatarColorValue: 0xFF8E24AA,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Contact(
        id: '5',
        name: 'Võ Mai Anh',
        phone: '0978223344',
        email: 'maianh.vo@outlook.com',
        category: 'Gia đình',
        address: 'Cẩm Lệ, Đà Nẵng',
        note: 'Em gái họ',
        isFavorite: false,
        avatarColorValue: 0xFFFB8C00,
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
      Contact(
        id: '6',
        name: 'Hoàng Đình Trọng',
        phone: '0903445566',
        email: 'tronghd@example.com',
        category: 'Công việc',
        address: 'Hải Châu, Đà Nẵng',
        note: 'Đồng nghiệp',
        isFavorite: false,
        avatarColorValue: 0xFF00ACC1,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Contact(
        id: '7',
        name: 'Đặng Ngọc Hương',
        phone: '0944778899',
        email: 'huong.dang@gmail.com',
        category: 'Bạn bè',
        address: 'Sơn Trà, Đà Nẵng',
        note: 'Bạn thời cấp 3',
        isFavorite: true,
        avatarColorValue: 0xFF00897B,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Contact(
        id: '8',
        name: 'Bùi Tuấn Kiệt',
        phone: '0966889900',
        email: 'kietbt@gmail.com',
        category: 'Khác',
        address: 'Ngũ Hành Sơn, Đà Nẵng',
        note: 'Chủ câu lạc bộ cầu lông',
        isFavorite: false,
        avatarColorValue: 0xFF6D4C41,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }
}

/// Tiện ích hỗ trợ tìm kiếm tiếng Việt không dấu
class VietnameseSearchHelper {
  static const _vietnameseMap = {
    'a': 'áàảãạăắằẳẵặâấầẩẫậ',
    'd': 'đ',
    'e': 'éèẻẽẹêếềểễệ',
    'i': 'íìỉĩị',
    'o': 'óòỏõọôốồổỗộơớờởỡợ',
    'u': 'úùủũụưứừửữự',
    'y': 'ýỳỷỹỵ',
  };

  /// Chuyển chuỗi tiếng Việt có dấu thành không dấu và viết thường
  static String removeDiacritics(String str) {
    var result = str.toLowerCase();
    _vietnameseMap.forEach((nonAccent, accents) {
      for (var i = 0; i < accents.length; i++) {
        result = result.replaceAll(accents[i], nonAccent);
      }
    });
    return result;
  }

  /// Kiểm tra chuỗi [source] có chứa từ khóa [query] (không phân biệt dấu và hoa thường)
  static bool containsIgnoreCaseAndDiacritics(String source, String query) {
    if (query.trim().isEmpty) return true;
    final normalizedSource = removeDiacritics(source);
    final normalizedQuery = removeDiacritics(query);
    return normalizedSource.contains(normalizedQuery);
  }
}
