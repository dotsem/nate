import 'package:go_router/go_router.dart';
import 'package:nate/features/editor/presentation/pages/editor_screen.dart';
import 'package:nate/features/settings/presentation/pages/settings_screen.dart';
import 'router_constants.dart';

final router = GoRouter(
  initialLocation: editorRoute,
  routes: [
    GoRoute(path: editorRoute, builder: (context, state) => const EditorScreen()),
    GoRoute(path: settingsRoute, builder: (context, state) => const SettingsScreen()),
  ],
);
