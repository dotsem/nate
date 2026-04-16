import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nate/features/editor/presentation/components/editor.dart';
import 'package:nate/features/editor/presentation/components/file_tabs.dart';
import 'package:nate/features/editor/presentation/components/change_filename_dialog.dart';
import 'package:nate/features/editor/data/editor_state.dart';

class EditorScreen extends ConsumerWidget {
  const EditorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(editorProvider);

    if (state.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nate'),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            onPressed: () => _showOpenDialog(context, ref),
            tooltip: 'Open File',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => ref.read(editorProvider.notifier).addNewFile(),
            tooltip: 'New File',
          ),
          IconButton(
            icon: const Icon(Icons.drive_file_rename_outline),
            tooltip: 'Rename File',
            onPressed: () async {
              final active = state.activeFile;
              if (active == null) return;
              final newPath = await showDialog<String>(
                context: context,
                builder: (context) => ChangeFilenameDialog(initialPath: active.path ?? ''),
              );
              if (newPath != null && context.mounted) {
                ref.read(editorProvider.notifier).renameFile(state.activeFileIndex, newPath);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              final active = state.activeFile;
              if (active == null) return;
              if (active.isNotSavedAs()) {
                final path = await showDialog<String>(
                  context: context,
                  builder: (context) =>
                      ChangeFilenameDialog(initialPath: active.path ?? '', dialogTitle: 'Save File As'),
                );
                if (path != null && context.mounted) {
                  ref.read(editorProvider.notifier).saveActiveFile(path: path);
                }
              } else {
                ref.read(editorProvider.notifier).saveActiveFile();
              }
            },
            tooltip: 'Save',
          ),
          IconButton(icon: const Icon(Icons.settings), onPressed: () => context.push('/settings'), tooltip: 'Settings'),
        ],
        bottom: state.openFiles.isEmpty
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(40),
                child: FileTabs(
                  files: state.openFiles,
                  activeIndex: state.activeFileIndex,
                  onTap: (index) => ref.read(editorProvider.notifier).setActiveFile(index),
                  onClose: (index) => ref.read(editorProvider.notifier).closeFile(index),
                ),
              ),
      ),
      body: state.openFiles.isEmpty
          ? const Center(child: Text('No files open'))
          : Editor(
              key: ValueKey(state.activeFile?.id),
              content: state.activeFile?.content ?? '',
              showLineNumbers: state.settings.showLineNumbers,
              onChanged: (val) => ref.read(editorProvider.notifier).updateContent(val),
            ),
    );
  }

  void _showOpenDialog(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(editorProvider.notifier);
    final settings = ref.read(editorProvider).settings;
    final controller = TextEditingController(text: settings.storagePath);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Open File'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Full Path'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              notifier.openFile(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Open'),
          ),
        ],
      ),
    );
  }
}
