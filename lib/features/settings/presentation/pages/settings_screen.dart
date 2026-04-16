import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nate/features/editor/data/editor_state.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(editorProvider);
    final notifier = ref.read(editorProvider.notifier);
    final settings = state.settings;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Storage Path'),
            subtitle: Text(settings.storagePath),
            trailing: const Icon(Icons.edit),
            onTap: () async {
              // In a real app we'd use a directory picker
              // For now, let's just show a snackbar or a dialog
              _showPathDialog(context, settings.storagePath, (newPath) {
                notifier.updateSettings(settings.copyWith(storagePath: newPath));
              });
            },
          ),
          SwitchListTile(
            title: const Text('Show Line Numbers'),
            value: settings.showLineNumbers,
            onChanged: (val) {
              notifier.updateSettings(settings.copyWith(showLineNumbers: val));
            },
          ),
          ListTile(
            title: const Text('Theme'),
            trailing: DropdownButton<ThemeMode>(
              value: settings.themeMode,
              items: ThemeMode.values.map((mode) {
                return DropdownMenuItem(value: mode, child: Text(mode.name.toUpperCase()));
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  notifier.updateSettings(settings.copyWith(themeMode: val));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showPathDialog(BuildContext context, String currentPath, Function(String) onSave) {
    final controller = TextEditingController(text: currentPath);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Storage Path'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Path'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
