import 'package:uuid/uuid.dart';

class FileModel {
  final String id;
  final String? path;
  final String content;
  final bool isDirty;
  final int? inode;

  FileModel({required this.id, this.path, required this.content, this.isDirty = false, this.inode});

  FileModel copyWith({String? path, String? content, bool? isDirty, int? inode}) {
    return FileModel(
      id: id,
      path: path ?? this.path,
      content: content ?? this.content,
      isDirty: isDirty ?? this.isDirty,
      inode: inode ?? this.inode,
    );
  }

  factory FileModel.newUnsaved([String content = '']) {
    return FileModel(id: const Uuid().v4(), content: content, isDirty: content.isNotEmpty);
  }

  String get name {
    if (path == null) return 'Untitled';
    return path!.split('/').last;
  }

  int get lineCount {
    if (content.isEmpty) return 1;
    return '\n'.allMatches(content).length + 1;
  }

  bool isNotSavedAs() {
    return path == null;
  }
}
