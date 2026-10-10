/* 
 * MSSV: 102230299
 * Họ và tên: Nguyễn Chánh Khiêm
 * Lớp: 23T_DT3
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/services/contact_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Khởi chạy ứng dụng danh bạ thành công', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final service = ContactService();
    await service.init();

    // Khởi dựng cây widget chính
    await tester.pumpWidget(MyApp(contactService: service));
    await tester.pumpAndSettle();

    // Xác nhận ứng dụng khởi động và hiển thị tiêu đề chính xác
    expect(find.text('Danh Bạ Điện Thoại'), findsOneWidget);
  });
}
