import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class NateAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;

  const NateAppBar({super.key, this.title, this.actions, this.bottom});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: DragToMoveArea(child: title ?? const Text('Nate')),
      flexibleSpace: const DragToMoveArea(child: SizedBox.expand()),
      actions: [
        ...?actions,
        const VerticalDivider(width: 1, indent: 12, endIndent: 12),
        IconButton(
          icon: const Icon(Icons.remove, size: 20),
          onPressed: () => windowManager.minimize(),
          tooltip: 'Minimize',
        ),
        IconButton(
          icon: const Icon(Icons.crop_square, size: 20),
          onPressed: () async {
            if (await windowManager.isMaximized()) {
              windowManager.unmaximize();
            } else {
              windowManager.maximize();
            }
          },
          tooltip: 'Maximize',
        ),
        IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () => windowManager.close(), tooltip: 'Close'),
        const SizedBox(width: 4),
      ],
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0.0));
}
