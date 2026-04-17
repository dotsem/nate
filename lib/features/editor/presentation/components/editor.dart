import 'package:flutter/material.dart';
import 'package:nate/features/editor/models/cursor_info_model.dart';
import 'package:nate/features/editor/presentation/components/left_sidebar.dart';
import 'package:nate/core/config/editor_config.dart';

class Editor extends StatefulWidget {
  final String content;
  final bool showLineNumbers;
  final ValueChanged<String> onChanged;
  final Function(CursorInfo) cursorPosition;

  const Editor({
    super.key,
    required this.content,
    required this.showLineNumbers,
    required this.onChanged,
    required this.cursorPosition,
  });

  @override
  State<Editor> createState() => _EditorState();
}

class _EditorState extends State<Editor> {
  late TextEditingController _controller;
  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _sidebarController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.content);
    _verticalController.addListener(() {
      if (_sidebarController.hasClients) {
        _sidebarController.jumpTo(_verticalController.offset);
      }
    });

    _controller.addListener(() {
      final selection = _controller.selection;
      if (selection.isValid) {
        final text = _controller.text;
        final offset = selection.extentOffset;

        final textBefore = text.substring(0, offset);
        final line = '\n'.allMatches(textBefore).length + 1;
        final lastNewline = textBefore.lastIndexOf('\n');
        final column = offset - lastNewline;

        final cursorInfo = CursorInfo(
          line: line,
          column: column,
          selected: !selection.isCollapsed,
          selectionStart: selection.start,
          selectionEnd: selection.end,
        );

        widget.cursorPosition(cursorInfo);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _verticalController.dispose();
    _horizontalController.dispose();
    _sidebarController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LeftSidebar(
            lineCount: widget.showLineNumbers ? '\n'.allMatches(_controller.text).length + 1 : 0,
            showLineNumbers: widget.showLineNumbers,
            scrollController: _sidebarController,
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _focusNode.requestFocus(),
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
                            child: ConstrainedBox(
                              constraints: BoxConstraints(minWidth: constraints.maxWidth),
                              child: TextField(
                                controller: _controller,
                                focusNode: _focusNode,
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
