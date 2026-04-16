import 'package:flutter/material.dart';
import 'package:nate/core/config/editor_config.dart';

class LeftSidebar extends StatelessWidget {
  final int lineCount;
  final bool showLineNumbers;
  final ScrollController scrollController;
  const LeftSidebar({super.key, required this.lineCount, this.showLineNumbers = true, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    if (!showLineNumbers) {
      // don't show sidebar when nothing is enabled
      return const SizedBox.shrink();
    }
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: Container(
        width: 45,
        padding: const EdgeInsets.only(top: EditorConfig.topPadding, right: 8, bottom: EditorConfig.bottomPadding),
        color: Theme.of(context).colorScheme.surfaceContainerHigh.withValues(alpha: 0.3),
        child: ListView.builder(
          padding: EdgeInsets.zero,
          controller: scrollController,
          itemCount: lineCount,
          itemBuilder: (context, index) {
            return SizedBox(
              height: EditorConfig.linePixelHeight,
              child: Text(
                '${index + 1}',
                textAlign: TextAlign.right,
                style: EditorConfig.textStyle.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            );
          },
        ),
      ),
    );
  }
}
