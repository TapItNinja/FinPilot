//lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mobile_app/core/theme/app_theme.dart';

import 'core/state/app_state_notifier.dart';
import 'core/router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Lock orientation to portrait — standard for finance apps
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ProviderScope(child: FinPilotApp()));
}

class FinPilotApp extends ConsumerStatefulWidget {
  const FinPilotApp({super.key});

  @override
  ConsumerState<FinPilotApp> createState() => _FinPilotAppState();
}

class _FinPilotAppState extends ConsumerState<FinPilotApp> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(appStateProvider.notifier).initializeApp();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appStateProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FinPilot',
      theme: FinPilotTheme.light(),
      darkTheme: FinPilotTheme.dark(),
      themeMode: ThemeMode.dark, // dark first, will add toggle in profile later
      home: AppRouter.getScreen(appState),
    );
  }
}