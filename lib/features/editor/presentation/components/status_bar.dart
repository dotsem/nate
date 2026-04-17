import 'package:flutter/material.dart';
import 'package:nate/features/editor/models/cursor_info_model.dart';

class StatusBar extends StatefulWidget {
  final CursorInfo cursorInfo;

  const StatusBar({super.key, required this.cursorInfo});

  @override
  State<StatusBar> createState() => StatusBarState();
}

class StatusBarState extends State<StatusBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          Text(
            'Ln ${widget.cursorInfo.line}, Col ${widget.cursorInfo.column}',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          if (widget.cursorInfo.selected) ...[
            const SizedBox(width: 8),
            Text('(${widget.cursorInfo.selectionLength} selected)', style: Theme.of(context).textTheme.labelSmall),
          ],
        ],
      ),
    );
  }
}
