import 'package:flutter/material.dart';
import 'core/di/injection.dart';
import 'core/theme/app_colors.dart';
import 'presentation/card_management/screen/card_management_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const CredApp());
}

class CredApp extends StatelessWidget {
  const CredApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CRED',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.screenBg,
        colorScheme: const ColorScheme.light(
          surface: AppColors.screenBg,
          primary: AppColors.textPrimary,
        ),
        fontFamily: 'Roboto',
      ),
      home: const CardManagementScreen(),
    );
  }
}
