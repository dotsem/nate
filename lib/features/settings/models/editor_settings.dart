import 'package:flutter/material.dart';

class EditorSettings {
  final String storagePath;
  final bool showLineNumbers;
  final ThemeMode themeMode;
  final bool showStatusBar;

  const EditorSettings({
    required this.storagePath,
    this.showLineNumbers = true,
    this.themeMode = ThemeMode.system,
    this.showStatusBar = true,
  });

  EditorSettings copyWith({String? storagePath, bool? showLineNumbers, ThemeMode? themeMode, bool? showStatusBar}) {
    return EditorSettings(
      storagePath: storagePath ?? this.storagePath,
      showLineNumbers: showLineNumbers ?? this.showLineNumbers,
      themeMode: themeMode ?? this.themeMode,
      showStatusBar: showStatusBar ?? this.showStatusBar,
    );
  }
}
