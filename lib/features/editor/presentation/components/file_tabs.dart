import 'package:flutter/material.dart';
import 'package:nate/features/editor/models/file_model.dart';

class FileTabs extends StatelessWidget {
  final List<FileModel> files;
  final int activeIndex;
  final Function(int) onTap;
  final Function(int) onClose;

  const FileTabs({
    super.key,
    required this.files,
    required this.activeIndex,
    required this.onTap,
    required this.onClose,
  });

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
                  InkWell(
                    onTap: () async {
                      if (file.isNotSavedAs() && file.isDirty) {
                        if (!await _showDiscardDialog(context, 'Discard Unsaved File?')) {
                          return;
                        }
                      } else if (file.isDirty) {
                        if (!await _showDiscardDialog(context, 'Discard Changes?')) {
                          return;
                        }
                      }
                      onClose(index);
                    },
                    child: const Icon(Icons.close, size: 16),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<bool> _showDiscardDialog(BuildContext context, String dialogTitle) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(dialogTitle),
        content: const Text('You have unsaved changes. Are you sure you want to discard them?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
  }
}
