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

  // Session persistence: store list of open file paths, inodes, and temporary content
  Future<void> saveSession(List<Map<String, dynamic>> files) async {
    final prefs = await SharedPreferences.getInstance();
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
      final inode = f['inode'];

      final tempFile = File(p.join(sessionDir.path, 'file_$i.tmp'));
      await tempFile.writeAsString(content);

      // Metadata format: path|tempPath|inode
      sessionMetadata.add('${path ?? ""}|${tempFile.path}|${inode ?? ""}');
    }
    await prefs.setStringList(_keySessionFiles, sessionMetadata);
  }

  Future<List<Map<String, dynamic>>> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionMetadata = prefs.getStringList(_keySessionFiles) ?? [];
    List<Map<String, dynamic>> files = [];

    for (final meta in sessionMetadata) {
      final parts = meta.split('|');
      final originalPath = parts[0].isEmpty ? null : parts[0];
      final tempPath = parts[1];
      final inodeString = parts.length > 2 ? parts[2] : '';
      final inode = int.tryParse(inodeString);

      final tempFile = File(tempPath);
      if (await tempFile.exists()) {
        final content = await tempFile.readAsString();
        files.add({'path': originalPath ?? '', 'content': content, 'inode': inode});
      }
    }
    return files;
  }

  Future<int?> getInode(String path) async {
    if (!Platform.isLinux) return null;
    try {
      final result = await Process.run('stat', ['-c', '%i', path]);
      if (result.exitCode == 0) {
        return int.tryParse(result.stdout.toString().trim());
      }
    } catch (_) {}
    return null;
  }

  Future<String> _getAppSupportDir() async {
    return (await getApplicationSupportDirectory()).path;
  }
}
