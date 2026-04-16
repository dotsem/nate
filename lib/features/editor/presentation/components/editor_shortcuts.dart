import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SaveIntent extends Intent {
  const SaveIntent();
}

class NewFileIntent extends Intent {
  const NewFileIntent();
}

class OpenFileIntent extends Intent {
  const OpenFileIntent();
}

class EditorShortcuts extends StatelessWidget {
  final Widget child;
  final VoidCallback onSave;
  final VoidCallback onNewFile;
  final VoidCallback onOpenFile;

  const EditorShortcuts({
    super.key,
    required this.child,
    required this.onSave,
    required this.onNewFile,
    required this.onOpenFile,
  });

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyS): const SaveIntent(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyN): const NewFileIntent(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyO): const OpenFileIntent(),
        // Map both Ctrl+Shift+Z and Ctrl+Y to Redo
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.shift, LogicalKeyboardKey.keyZ):
            const RedoTextIntent(SelectionChangedCause.keyboard),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyY): const RedoTextIntent(
          SelectionChangedCause.keyboard,
        ),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          SaveIntent: CallbackAction<SaveIntent>(onInvoke: (_) => onSave()),
          NewFileIntent: CallbackAction<NewFileIntent>(onInvoke: (_) => onNewFile()),
          OpenFileIntent: CallbackAction<OpenFileIntent>(onInvoke: (_) => onOpenFile()),
        },
        child: child,
      ),
    );
  }
}
