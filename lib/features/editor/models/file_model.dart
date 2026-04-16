import 'package:uuid/uuid.dart';

class FileModel {
  final String id;
  final String? path;
  final String content;
  final bool isDirty;

  FileModel({required this.id, this.path, required this.content, this.isDirty = false});

  FileModel copyWith({String? path, String? content, bool? isDirty}) {
    return FileModel(
      id: id,
      path: path ?? this.path,
      content: content ?? this.content,
      isDirty: isDirty ?? this.isDirty,
    );
  }

  factory FileModel.newUnsaved([String content = '']) {
    return FileModel(id: const Uuid().v4(), content: content, isDirty: content.isNotEmpty);
  }

  String get name {
    if (path == null) return 'Untitled';
    return path!.split('/').last;
  }
}
