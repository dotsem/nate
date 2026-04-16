import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/editor_state.dart';
import '../components/line_number_editor.dart';

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
            icon: const Icon(Icons.save),
            onPressed: () => ref.read(editorProvider.notifier).saveActiveFile(),
            tooltip: 'Save',
          ),
          IconButton(icon: const Icon(Icons.settings), onPressed: () => context.push('/settings'), tooltip: 'Settings'),
        ],
        bottom: state.openFiles.isEmpty
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(40),
                child: _FileTabs(
                  files: state.openFiles,
                  activeIndex: state.activeFileIndex,
                  onTap: (index) => ref.read(editorProvider.notifier).setActiveFile(index),
                  onClose: (index) => ref.read(editorProvider.notifier).closeFile(index),
                ),
              ),
      ),
      body: state.openFiles.isEmpty
          ? const Center(child: Text('No files open'))
          : LineNumberEditor(
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

class _FileTabs extends StatelessWidget {
  final List<dynamic> files;
  final int activeIndex;
  final Function(int) onTap;
  final Function(int) onClose;

  const _FileTabs({required this.files, required this.activeIndex, required this.onTap, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: files.length,
        itemBuilder: (context, index) {
          final file = files[index];
          final isActive = index == activeIndex;

          return GestureDetector(
            onTap: () => onTap(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: isActive ? Theme.of(context).colorScheme.surfaceContainerHigh : null,
                border: Border(
                  bottom: BorderSide(
                    color: isActive ? Theme.of(context).colorScheme.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    file.name + (file.isDirty ? '*' : ''),
                    style: TextStyle(fontWeight: isActive ? FontWeight.bold : FontWeight.normal),
                  ),
                  const SizedBox(width: 8),
                  InkWell(onTap: () => onClose(index), child: const Icon(Icons.close, size: 16)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
