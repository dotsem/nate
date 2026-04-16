import 'package:flutter/material.dart';

class ChangeFilenameDialog extends StatefulWidget {
  final String initialPath;

  const ChangeFilenameDialog({super.key, required this.initialPath});

  @override
  State<ChangeFilenameDialog> createState() => _ChangeFilenameDialogState();
}

class _ChangeFilenameDialogState extends State<ChangeFilenameDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialPath);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rename File'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'New File Path', hintText: '/path/to/file.txt'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            final path = _controller.text.trim();
            if (path.isNotEmpty) {
              Navigator.pop(context, path);
            }
          },
          child: const Text('Rename'),
        ),
      ],
    );
  }
}
