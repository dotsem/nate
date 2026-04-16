import 'package:flutter/material.dart';
import 'package:nate/features/editor/presentation/components/left_sidebar.dart';
import 'package:nate/core/config/editor_config.dart';

class Editor extends StatefulWidget {
  final String content;
  final bool showLineNumbers;
  final ValueChanged<String> onChanged;

  const Editor({super.key, required this.content, required this.showLineNumbers, required this.onChanged});

  @override
  State<Editor> createState() => _EditorState();
}

class _EditorState extends State<Editor> {
  late TextEditingController _controller;
  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _sidebarController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.content);
    _verticalController.addListener(() {
      if (_sidebarController.hasClients) {
        _sidebarController.jumpTo(_verticalController.offset);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _verticalController.dispose();
    _horizontalController.dispose();
    _sidebarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LeftSidebar(
          lineCount: widget.showLineNumbers
              ? '\n'.allMatches(_controller.text).length + 1
              : 0, // only calculate when needed
          showLineNumbers: widget.showLineNumbers,
          scrollController: _sidebarController,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: EditorConfig.topPadding, top: EditorConfig.topPadding),
            child: Scrollbar(
              thumbVisibility: true,
              controller: _horizontalController,
              notificationPredicate: (n) => n.metrics.axis == Axis.horizontal,
              child: Scrollbar(
                thumbVisibility: true,
                controller: _verticalController,
                notificationPredicate: (n) => n.metrics.axis == Axis.vertical,
                child: SingleChildScrollView(
                  controller: _horizontalController,
                  scrollDirection: Axis.horizontal,
                  child: IntrinsicWidth(
                    child: TextField(
                      controller: _controller,
                      scrollController: _verticalController,
                      maxLines: null,
                      minLines: 1,
                      keyboardType: TextInputType.multiline,
                      autofocus: true,
                      style: EditorConfig.textStyle,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.only(
                          left: 8,
                          top: EditorConfig.topPadding,
                          bottom: EditorConfig.bottomPadding,
                        ),
                      ),
                      onChanged: widget.onChanged,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
