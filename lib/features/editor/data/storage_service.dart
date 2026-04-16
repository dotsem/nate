import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;

class StorageService {
  static const String _keyStoragePath = 'storage_path';
  static const String _keyShowLineNumbers = 'show_line_numbers';
  static const String _keyThemeMode = 'theme_mode';
  static const String _keySessionFiles = 'session_files';

  Future<String> getDefaultStoragePath() async {
    final home = Platform.environment['HOME'] ?? (await getApplicationDocumentsDirectory()).path;
    final natePath = p.join(home, 'nate');
    final dir = Directory(natePath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return natePath;
  }

  Future<void> saveSettings({
    required String storagePath,
    required bool showLineNumbers,
    required String themeMode,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyStoragePath, storagePath);
    await prefs.setBool(_keyShowLineNumbers, showLineNumbers);
    await prefs.setString(_keyThemeMode, themeMode);
  }

  Future<Map<String, dynamic>> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final defaultPath = await getDefaultStoragePath();
    return {
      'storagePath': prefs.getString(_keyStoragePath) ?? defaultPath,
      'showLineNumbers': prefs.getBool(_keyShowLineNumbers) ?? true,
      'themeMode': prefs.getString(_keyThemeMode) ?? 'system',
    };
  }

  // Session persistence: store list of open file paths and temporary content for unsaved files
  Future<void> saveSession(List<Map<String, String>> files) async {
    final prefs = await SharedPreferences.getInstance();
    // In a real app, we'd probably save temp content to a file, but for simplicity we'll use SharedPreferences if it's small or just paths
    // Actually, I'll save temp files in a hidden .nate_session folder
    final sessionDir = Directory(p.join(await _getAppSupportDir(), '.session'));
    if (!await sessionDir.exists()) await sessionDir.create(recursive: true);

    // Clear old session files
    await for (final file in sessionDir.list()) {
      await file.delete();
    }

    List<String> sessionMetadata = [];
    for (var i = 0; i < files.length; i++) {
      final f = files[i];
      final path = f['path'];
      final content = f['content']!;

      final tempFile = File(p.join(sessionDir.path, 'file_$i.tmp'));
      await tempFile.writeAsString(content);

      sessionMetadata.add('${path ?? ""}|${tempFile.path}');
    }
    await prefs.setStringList(_keySessionFiles, sessionMetadata);
  }

  Future<List<Map<String, String>>> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionMetadata = prefs.getStringList(_keySessionFiles) ?? [];
    List<Map<String, String>> files = [];

    for (final meta in sessionMetadata) {
      final parts = meta.split('|');
      final originalPath = parts[0].isEmpty ? null : parts[0];
      final tempPath = parts[1];

      final tempFile = File(tempPath);
      if (await tempFile.exists()) {
        final content = await tempFile.readAsString();
        files.add({'path': originalPath ?? '', 'content': content});
      }
    }
    return files;
  }

  Future<String> _getAppSupportDir() async {
    return (await getApplicationSupportDirectory()).path;
  }
}
