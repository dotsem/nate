import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nate/core/theme/theme.dart';
import 'core/router/router.dart';
import 'features/editor/data/editor_state.dart';

void main() {
  runApp(const ProviderScope(child: NateApp()));
}

class NateApp extends ConsumerWidget {
  const NateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(editorProvider);
    final themeMode = state.settings.themeMode;

    return MaterialApp.router(
      title: 'Nate',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
