import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/state/app_state_notifier.dart';
import 'core/router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  runApp(const ProviderScope(child: FinPilotApp()));
}
//we are not using normal StatefulWidget because it does'nt know RiverPod

class FinPilotApp extends ConsumerStatefulWidget {
//standard Flutter widget constructor pattern. track widgets, preserve state, optimize rebuilds.
  const FinPilotApp({super.key});  //immutable compile-time optimized widget
  @override
  ConsumerState<FinPilotApp> createState() {
    return _FinPilotAppState();
  }
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
      home: AppRouter.getScreen(appState),
    );
  }
}
// class FinPilotApp extends ConsumerStatefulWidget{
//   const FinPilotApp({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
    // ref.read(appStateProvider.notifier).initializeApp();//CANT BE INSIDE BUILD AS BUILDS RANDOMLY
//     final appState = ref.watch(appStateProvider);

//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: AppRouter.getScreen(appState),
//     );
//   }
// }

//ConsumerWidget has no lifecycle but ConsumerStatefulWidget does.