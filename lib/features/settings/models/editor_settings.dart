import 'package:flutter/material.dart';

class EditorSettings {
  final String storagePath;
  final bool showLineNumbers;
  final ThemeMode themeMode;

  const EditorSettings({required this.storagePath, this.showLineNumbers = true, this.themeMode = ThemeMode.system});

  EditorSettings copyWith({String? storagePath, bool? showLineNumbers, ThemeMode? themeMode}) {
    return EditorSettings(
      storagePath: storagePath ?? this.storagePath,
      showLineNumbers: showLineNumbers ?? this.showLineNumbers,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}
