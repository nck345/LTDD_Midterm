/* 
 * MSSV: 102230299
 * Họ và tên: Nguyễn Chánh Khiêm
 * Lớp: 23T_DT3
 */

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/models/contact.dart';
import 'package:flutter_application_1/services/contact_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Kiểm thử Giao diện (Câu 1)', () {
    testWidgets('1.1 & 1.2: Hiển thị giao diện danh bạ và Custom Layout thẻ liên hệ', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final service = ContactService();
      await service.init();

      await tester.pumpWidget(MyApp(contactService: service));
      await tester.pumpAndSettle();

      // Kiểm tra tiêu đề AppBar
      expect(find.text('Danh Bạ Điện Thoại'), findsOneWidget);

      // Kiểm tra ô tìm kiếm và bộ lọc nhóm (Custom Layout)
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Tất cả'), findsOneWidget);
      expect(find.text('Gia đình'), findsWidgets);

      // Kiểm tra các thẻ liên hệ Custom Layout hiển thị
      expect(find.text('Trần Thị Thu Thảo'), findsOneWidget);
      expect(find.text('Lê Hoàng Minh'), findsOneWidget);
      expect(find.text('Nguyễn Chánh Khiêm'), findsOneWidget);

      // Kiểm tra nút FloatingActionButton
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.text('Thêm liên hệ'), findsOneWidget);
    });

    testWidgets('1.3: Chuyển đổi Dark Mode / Light Mode', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final service = ContactService();
      await service.init();

      await tester.pumpWidget(MyApp(contactService: service));
      await tester.pumpAndSettle();

      expect(service.isDarkMode, false);

      // Bấm nút chuyển đổi Theme trên AppBar
      final themeBtn = find.byTooltip('Chế độ Tối');
      expect(themeBtn, findsOneWidget);
      await tester.tap(themeBtn);
      await tester.pumpAndSettle();

      expect(service.isDarkMode, true);
    });
  });

  group('Kiểm thử Chức năng (Câu 2)', () {
    test('2.1: Thêm danh bạ mới', () async {
      final service = ContactService();
      await service.init();
      final initialCount = service.allContacts.length;

      final contact = Contact(
        id: 'new_1',
        name: 'Hoàng Văn Thắng',
        phone: '0905123987',
        email: 'thang.hoang@gmail.com',
        category: 'Công việc',
        address: 'Hải Châu, Đà Nẵng',
        note: 'Đối tác mới',
        isFavorite: true,
        avatarColorValue: Colors.indigo.toARGB32(),
        createdAt: DateTime.now(),
      );

      await service.addContact(contact);
      expect(service.allContacts.length, initialCount + 1);
      expect(service.allContacts.first.name, 'Hoàng Văn Thắng');
      expect(service.allContacts.first.isFavorite, true);
    });

    test('2.2: Chỉnh sửa thông tin liên hệ', () async {
      final service = ContactService();
      await service.init();

      final first = service.allContacts.first;
      final updated = first.copyWith(
        name: 'Nguyễn Chánh Khiêm (Đã cập nhật)',
        phone: '0905999999',
        category: 'VIP',
      );

      await service.updateContact(updated);
      final found = service.allContacts.firstWhere((c) => c.id == first.id);
      expect(found.name, 'Nguyễn Chánh Khiêm (Đã cập nhật)');
      expect(found.phone, '0905999999');
      expect(found.category, 'VIP');
    });

    test('2.3: Xóa danh bạ và Hoàn tác (Undo)', () async {
      final service = ContactService();
      await service.init();
      final countBefore = service.allContacts.length;
      final toDeleteId = service.allContacts[1].id;

      final removed = await service.deleteContact(toDeleteId);
      expect(removed, isNotNull);
      expect(service.allContacts.length, countBefore - 1);
      expect(service.allContacts.any((c) => c.id == toDeleteId), false);

      // Hoàn tác
      await service.restoreContact(removed!.contact, removed.index);
      expect(service.allContacts.length, countBefore);
      expect(service.allContacts.any((c) => c.id == toDeleteId), true);
    });

    test('2.4: Tìm kiếm theo tên (không dấu), số điện thoại và email', () async {
      final service = ContactService();
      await service.init();

      // Tìm theo tên có dấu bằng từ khóa không dấu "khiem"
      service.setSearchQuery('khiem');
      expect(service.filteredContacts.any((c) => c.name.contains('Khiêm')), true);

      // Tìm theo số điện thoại
      service.setSearchQuery('0912345678');
      expect(service.filteredContacts.length, 1);
      expect(service.filteredContacts.first.name, 'Trần Thị Thu Thảo');

      // Tìm theo email
      service.setSearchQuery('techcorp.vn');
      expect(service.filteredContacts.length, 1);
      expect(service.filteredContacts.first.name, 'Phạm Quốc Bảo');

      // Xóa từ khóa tìm kiếm
      service.setSearchQuery('');
      expect(service.filteredContacts.length, service.allContacts.length);
    });

    test('2.5: Bộ lọc danh mục, lọc Yêu thích và Sắp xếp', () async {
      final service = ContactService();
      await service.init();

      // Lọc theo nhóm Gia đình
      service.setCategory('Gia đình');
      expect(service.filteredContacts.every((c) => c.category == 'Gia đình'), true);

      // Lọc chỉ xem Yêu thích
      service.setCategory('Tất cả');
      service.toggleOnlyFavorites();
      expect(service.filteredContacts.every((c) => c.isFavorite), true);
      service.toggleOnlyFavorites(); // Tắt lọc yêu thích

      // Sắp xếp A-Z
      service.setSortOption(SortOption.nameAsc);
      final namesAsc = service.filteredContacts.map((c) => c.name.toLowerCase()).toList();
      final sortedAsc = List<String>.from(namesAsc)..sort();
      expect(namesAsc, sortedAsc);

      // Sắp xếp Z-A
      service.setSortOption(SortOption.nameDesc);
      final namesDesc = service.filteredContacts.map((c) => c.name.toLowerCase()).toList();
      final sortedDesc = List<String>.from(namesDesc)..sort((a, b) => b.compareTo(a));
      expect(namesDesc, sortedDesc);
    });

    test('2.6: Đánh dấu yêu thích nhanh và Khôi phục dữ liệu mẫu', () async {
      final service = ContactService();
      await service.init();

      final firstContact = service.allContacts.first;
      final initialFav = firstContact.isFavorite;

      await service.toggleFavorite(firstContact.id);
      expect(service.allContacts.first.isFavorite, !initialFav);

      // Đảo lại
      await service.toggleFavorite(firstContact.id);
      expect(service.allContacts.first.isFavorite, initialFav);

      // Reset về dữ liệu mẫu
      await service.clearAll();
      expect(service.allContacts.isEmpty, true);

      await service.resetToSampleData();
      expect(service.allContacts.isNotEmpty, true);
      expect(service.allContacts.length, Contact.sampleContacts().length);
    });
  });
}
