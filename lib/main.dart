import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'controller/collection_controller.dart';
import 'controller/scan_controller.dart';
import 'theme/app_theme.dart';
import 'ui/main_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ScanController()..init()),
        ChangeNotifierProvider(create: (_) => CollectionController()..load()),
      ],
      child: const HerbaScanApp(),
    ),
  );
}

class HerbaScanApp extends StatelessWidget {
  const HerbaScanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HerbaScan',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const MainShell(),
    );
  }
}
