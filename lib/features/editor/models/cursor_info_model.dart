import 'package:flutter/material.dart';

class CursorInfo {
  final int line;
  final int column;
  final bool selected;
  final int selectionStart;
  final int selectionEnd;

  CursorInfo({
    required this.line,
    required this.column,
    required this.selected,
    required this.selectionStart,
    required this.selectionEnd,
  });

  int get selectionLength => selectionEnd - selectionStart;

  factory CursorInfo.fromSelection(TextSelection selection) {
    return CursorInfo(
      line: selection.baseOffset,
      column: selection.extentOffset,
      selected: selection.isValid,
      selectionStart: selection.start,
      selectionEnd: selection.end,
    );
  }

  factory CursorInfo.empty() {
    return CursorInfo(line: 1, column: 1, selected: false, selectionStart: 0, selectionEnd: 0);
  }
}
