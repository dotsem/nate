import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'package:nate/core/theme/theme.dart';
import 'core/router/router.dart';
import 'features/editor/data/editor_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    titleBarStyle: TitleBarStyle.hidden,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    title: 'Nate',
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const ProviderScope(child: NateApp()));
}

class NateApp extends ConsumerWidget {
  const NateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(editorProvider);
    final themeMode = state.settings.themeMode;
    final title = state.activeFile?.name ?? 'Untitled';

    return MaterialApp.router(
      title: 'Nate - $title',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
