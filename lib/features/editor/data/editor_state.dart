import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/file_model.dart';
import '../../settings/models/editor_settings.dart';
import 'storage_service.dart';

final storageServiceProvider = Provider((ref) => StorageService());

class EditorState {
  final List<FileModel> openFiles;
  final int activeFileIndex;
  final EditorSettings settings;
  final bool isLoading;

  EditorState({this.openFiles = const [], this.activeFileIndex = 0, required this.settings, this.isLoading = true});

  EditorState copyWith({List<FileModel>? openFiles, int? activeFileIndex, EditorSettings? settings, bool? isLoading}) {
    return EditorState(
      openFiles: openFiles ?? this.openFiles,
      activeFileIndex: activeFileIndex ?? this.activeFileIndex,
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  FileModel? get activeFile =>
      openFiles.isNotEmpty && activeFileIndex < openFiles.length ? openFiles[activeFileIndex] : null;
}

class EditorNotifier extends Notifier<EditorState> {
  StorageService get _storage => ref.read(storageServiceProvider);

  @override
  EditorState build() {
    // Start with a loading state
    final initialState = EditorState(settings: const EditorSettings(storagePath: ''), isLoading: true);

    // Trigger initialization
    _init();

    return initialState;
  }

  Future<void> _init() async {
    final settingsMap = await _storage.loadSettings();
    final settings = EditorSettings(
      storagePath: settingsMap['storagePath'],
      showLineNumbers: settingsMap['showLineNumbers'],
      themeMode: _parseThemeMode(settingsMap['themeMode']),
    );

    final sessionFiles = await _storage.loadSession();
    List<FileModel> openFiles = [];
    if (sessionFiles.isEmpty) {
      openFiles = [FileModel.newUnsaved()];
    } else {
      openFiles = sessionFiles.map((f) {
        return FileModel(
          id: DateTime.now().toIso8601String() + f['path']!,
          path: f['path']!.isEmpty ? null : f['path'],
          content: f['content']!,
          isDirty: true,
        );
      }).toList();
    }

    state = state.copyWith(settings: settings, openFiles: openFiles, activeFileIndex: 0, isLoading: false);
  }

  ThemeMode _parseThemeMode(String mode) {
    return ThemeMode.values.firstWhere((e) => e.name == mode, orElse: () => ThemeMode.system);
  }

  void setActiveFile(int index) {
    if (index >= 0 && index < state.openFiles.length) {
      state = state.copyWith(activeFileIndex: index);
    }
  }

  void updateContent(String content) {
    if (state.activeFile == null) return;
    final active = state.activeFile!;
    final updated = active.copyWith(content: content, isDirty: true);

    final newFiles = List<FileModel>.from(state.openFiles);
    newFiles[state.activeFileIndex] = updated;

    state = state.copyWith(openFiles: newFiles);
    _persistSession();
  }

  void addNewFile() {
    final newFiles = [...state.openFiles, FileModel.newUnsaved()];
    state = state.copyWith(openFiles: newFiles, activeFileIndex: newFiles.length - 1);
    _persistSession();
  }

  void closeFile(int index) {
    final newFiles = List<FileModel>.from(state.openFiles);
    newFiles.removeAt(index);

    if (newFiles.isEmpty) {
      newFiles.add(FileModel.newUnsaved());
    }

    int newIndex = state.activeFileIndex;
    if (newIndex >= newFiles.length) {
      newIndex = newFiles.length - 1;
    }
    if (newIndex < 0) newIndex = 0;

    state = state.copyWith(openFiles: newFiles, activeFileIndex: newIndex);
    _persistSession();
  }

  Future<void> _persistSession() async {
    final sessionData = state.openFiles.map((f) => {'path': f.path ?? '', 'content': f.content}).toList();
    await _storage.saveSession(sessionData);
  }

  Future<void> openFile(String path) async {
    final file = File(path);
    if (!await file.exists()) return;

    final content = await file.readAsString();

    final existingIndex = state.openFiles.indexWhere((f) => f.path == path);
    if (existingIndex != -1) {
      state = state.copyWith(activeFileIndex: existingIndex);
      return;
    }

    final newFile = FileModel(
      id: DateTime.now().toIso8601String() + path,
      path: path,
      content: content,
      isDirty: false,
    );

    state = state.copyWith(openFiles: [...state.openFiles, newFile], activeFileIndex: state.openFiles.length);
    _persistSession();
  }

  Future<void> saveActiveFile() async {
    final active = state.activeFile;
    if (active == null) return;

    if (active.path == null) {
      final fileName = 'untitled_${DateTime.now().millisecondsSinceEpoch}.txt';
      final path = '${state.settings.storagePath}/$fileName';
      return saveAs(path);
    }

    await File(active.path!).writeAsString(active.content);

    final updated = active.copyWith(isDirty: false);
    final newFiles = List<FileModel>.from(state.openFiles);
    newFiles[state.activeFileIndex] = updated;

    state = state.copyWith(openFiles: newFiles);
    _persistSession();
  }

  Future<void> saveAs(String path) async {
    final active = state.activeFile;
    if (active == null) return;

    await File(path).writeAsString(active.content);

    final updated = active.copyWith(path: path, isDirty: false);
    final newFiles = List<FileModel>.from(state.openFiles);
    newFiles[state.activeFileIndex] = updated;

    state = state.copyWith(openFiles: newFiles);
    _persistSession();
  }

  void updateSettings(EditorSettings settings) {
    state = state.copyWith(settings: settings);
    _storage.saveSettings(
      storagePath: settings.storagePath,
      showLineNumbers: settings.showLineNumbers,
      themeMode: settings.themeMode.name,
    );
  }
}

final editorProvider = NotifierProvider<EditorNotifier, EditorState>(() {
  return EditorNotifier();
});
