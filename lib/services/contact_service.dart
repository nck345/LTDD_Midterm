/* 
 * MSSV: 102230299
 * Họ và tên: Nguyễn Chánh Khiêm
 * Lớp: 23T_DT3
 */

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/contact.dart';

enum SortOption {
  nameAsc,
  nameDesc,
  newest,
}

class ContactService extends ChangeNotifier {
  static const String _storageKey = 'saved_contacts_v1';
  static const String _themeKey = 'app_theme_dark_mode';

  final ValueNotifier<bool> themeNotifier = ValueNotifier<bool>(false);

  List<Contact> _contacts = Contact.sampleContacts();
  bool _isLoading = false;
  bool _isDarkMode = false;
  String _searchQuery = '';
  String _selectedCategory = 'Tất cả';
  bool _onlyFavorites = false;
  SortOption _currentSort = SortOption.nameAsc;

  List<Contact> get allContacts => List.unmodifiable(_contacts);
  bool get isLoading => _isLoading;
  bool get isDarkMode => _isDarkMode;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  bool get onlyFavorites => _onlyFavorites;
  SortOption get currentSort => _currentSort;

  /// Tổng số liên hệ
  int get totalCount => _contacts.length;

  /// Số liên hệ yêu thích
  int get favoriteCount => _contacts.where((c) => c.isFavorite).length;

  /// Số liên hệ theo danh mục cụ thể
  int countByCategory(String category) {
    if (category == 'Tất cả') return _contacts.length;
    if (category == 'Yêu thích' || category == '⭐ Yêu thích') {
      return favoriteCount;
    }
    return _contacts.where((c) => c.category == category).length;
  }

  /// Danh sách danh bạ sau khi áp dụng Tìm kiếm, Bộ lọc và Sắp xếp
  List<Contact> get filteredContacts {
    var result = List<Contact>.from(_contacts);

    // 1. Lọc theo trạng thái Yêu thích
    if (_onlyFavorites) {
      result = result.where((c) => c.isFavorite).toList();
    }

    // 2. Lọc theo Nhóm/Danh mục
    if (_selectedCategory != 'Tất cả' && _selectedCategory != '⭐ Yêu thích') {
      result = result.where((c) => c.category == _selectedCategory).toList();
    } else if (_selectedCategory == '⭐ Yêu thích') {
      result = result.where((c) => c.isFavorite).toList();
    }

    // 3. Tìm kiếm theo Tên, Số điện thoại hoặc Email (hỗ trợ tiếng Việt không dấu)
    if (_searchQuery.trim().isNotEmpty) {
      result = result.where((c) {
        final matchesName = VietnameseSearchHelper.containsIgnoreCaseAndDiacritics(
          c.name,
          _searchQuery,
        );
        final cleanDigits = _searchQuery.replaceAll(RegExp(r'\D'), '');
        final matchesPhone = cleanDigits.isNotEmpty &&
            c.phone.replaceAll(RegExp(r'\D'), '').contains(cleanDigits);
        final matchesEmail = VietnameseSearchHelper.containsIgnoreCaseAndDiacritics(
          c.email,
          _searchQuery,
        );
        return matchesName || matchesPhone || matchesEmail;
      }).toList();
    }

    // 4. Sắp xếp danh sách
    switch (_currentSort) {
      case SortOption.nameAsc:
        result.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case SortOption.nameDesc:
        result.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        break;
      case SortOption.newest:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }

    return result;
  }

  ContactService();

  /// Khởi tạo và tải dữ liệu từ SharedPreferences
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool(_themeKey) ?? false;
      themeNotifier.value = _isDarkMode;

      final rawData = prefs.getString(_storageKey);
      if (rawData != null && rawData.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(rawData);
        _contacts = decoded
            .map((item) => Contact.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        // Lần đầu mở app: nạp danh sách danh bạ mẫu sinh động
        _contacts = Contact.sampleContacts();
        await _saveToStorage();
      }
    } catch (e) {
      debugPrint('Lỗi tải dữ liệu danh bạ: $e');
      _contacts = Contact.sampleContacts();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Lưu danh sách vào bộ nhớ cục bộ (SharedPreferences)
  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_contacts.map((c) => c.toJson()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (e) {
      debugPrint('Lỗi lưu danh bạ: $e');
    }
  }

  /// Chuyển đổi Dark Mode / Light Mode
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    themeNotifier.value = _isDarkMode;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, _isDarkMode);
    } catch (e) {
      debugPrint('Lỗi lưu theme: $e');
    }
  }

  /// Cập nhật từ khóa tìm kiếm
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Cập nhật danh mục lọc
  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  /// Bật/tắt lọc chỉ xem yêu thích
  void toggleOnlyFavorites() {
    _onlyFavorites = !_onlyFavorites;
    notifyListeners();
  }

  /// Đặt kiểu sắp xếp
  void setSortOption(SortOption sort) {
    _currentSort = sort;
    notifyListeners();
  }

  /// Thêm danh bạ mới
  Future<void> addContact(Contact contact) async {
    _contacts.insert(0, contact);
    notifyListeners();
    await _saveToStorage();
  }

  /// Chỉnh sửa thông tin liên hệ
  Future<void> updateContact(Contact updatedContact) async {
    final index = _contacts.indexWhere((c) => c.id == updatedContact.id);
    if (index != -1) {
      _contacts[index] = updatedContact;
      notifyListeners();
      await _saveToStorage();
    }
  }

  /// Xóa danh bạ (trả về contact bị xóa kèm vị trí để hỗ trợ Hoàn tác)
  Future<({Contact contact, int index})?> deleteContact(String id) async {
    final index = _contacts.indexWhere((c) => c.id == id);
    if (index != -1) {
      final removed = _contacts.removeAt(index);
      notifyListeners();
      await _saveToStorage();
      return (contact: removed, index: index);
    }
    return null;
  }

  /// Hoàn tác xóa danh bạ
  Future<void> restoreContact(Contact contact, int index) async {
    if (index >= 0 && index <= _contacts.length) {
      _contacts.insert(index, contact);
    } else {
      _contacts.add(contact);
    }
    notifyListeners();
    await _saveToStorage();
  }

  /// Đánh dấu / bỏ đánh dấu yêu thích nhanh
  Future<void> toggleFavorite(String id) async {
    final index = _contacts.indexWhere((c) => c.id == id);
    if (index != -1) {
      final old = _contacts[index];
      _contacts[index] = old.copyWith(isFavorite: !old.isFavorite);
      notifyListeners();
      await _saveToStorage();
    }
  }

  /// Khôi phục dữ liệu mẫu
  Future<void> resetToSampleData() async {
    _contacts = Contact.sampleContacts();
    _searchQuery = '';
    _selectedCategory = 'Tất cả';
    _onlyFavorites = false;
    _currentSort = SortOption.nameAsc;
    notifyListeners();
    await _saveToStorage();
  }

  /// Xóa toàn bộ danh bạ
  Future<void> clearAll() async {
    _contacts.clear();
    notifyListeners();
    await _saveToStorage();
  }
}
