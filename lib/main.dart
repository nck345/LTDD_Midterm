/* 
 * MSSV: 102230299
 * Họ và tên: Nguyễn Chánh Khiêm
 * Lớp: 23T_DT3
 */

import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/contact_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final contactService = ContactService();
  await contactService.init();

  runApp(MyApp(contactService: contactService));
}

class MyApp extends StatelessWidget {
  final ContactService contactService;

  const MyApp({super.key, required this.contactService});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: contactService.themeNotifier,
      builder: (context, isDark, _) {
        return MaterialApp(
          title: 'Danh Bạ Điện Thoại',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          home: HomeScreen(service: contactService),
        );
      },
    );
  }
}
