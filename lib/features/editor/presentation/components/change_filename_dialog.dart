import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:nate/features/editor/data/editor_state.dart';

class ChangeFilenameDialog extends ConsumerStatefulWidget {
  final String initialPath;
  final String dialogTitle;

  const ChangeFilenameDialog({super.key, required this.initialPath, this.dialogTitle = 'Rename File'});

  @override
  ConsumerState<ChangeFilenameDialog> createState() => _ChangeFilenameDialogState();
}

class _ChangeFilenameDialogState extends ConsumerState<ChangeFilenameDialog> {
  late TextEditingController _dirController;
  late TextEditingController _nameController;
  late TextEditingController _extController;

  @override
  void initState() {
    super.initState();

    String dir = '';
    String name = '';
    String ext = '';

    if (widget.initialPath.isNotEmpty) {
      dir = p.dirname(widget.initialPath);
      ext = p.extension(widget.initialPath);
      name = p.basenameWithoutExtension(widget.initialPath);
    }

    _dirController = TextEditingController(text: dir);
    _nameController = TextEditingController(text: name);
    _extController = TextEditingController(text: ext.isNotEmpty ? ext.substring(1) : 'txt');
  }

  @override
  void dispose() {
    _dirController.dispose();
    _nameController.dispose();
    _extController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(editorProvider.select((s) => s.settings));
    if (_dirController.text.isEmpty) {
      _dirController.text = settings.storagePath;
    }

    return AlertDialog(
      title: Text(widget.dialogTitle),
      content: SizedBox(
        width: 600,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              flex: 4,
              child: TextField(
                controller: _dirController,
                decoration: const InputDecoration(labelText: 'Path', hintText: '/home/user/nate'),
              ),
            ),
            const Padding(padding: EdgeInsets.only(left: 4, right: 4, bottom: 4), child: Text('/')),
            Expanded(
              flex: 3,
              child: TextField(
                controller: _nameController,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Name', hintText: 'filename'),
              ),
            ),
            const Padding(padding: EdgeInsets.only(left: 4, right: 4, bottom: 4), child: Text('.')),
            Expanded(
              flex: 1,
              child: TextField(
                controller: _extController,
                decoration: const InputDecoration(labelText: 'Ext', hintText: 'txt'),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            final dir = _dirController.text.trim();
            final name = _nameController.text.trim();
            final ext = _extController.text.trim();

            if (name.isNotEmpty) {
              String fullExt = ext;
              if (fullExt.isNotEmpty && !fullExt.startsWith('.')) {
                fullExt = '.$fullExt';
              }
              final fullPath = p.join(dir, '$name$fullExt');
              Navigator.pop(context, fullPath);
            }
          },
          child: const Text('Rename'),
        ),
      ],
    );
  }
}
