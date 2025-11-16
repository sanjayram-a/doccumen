import 'package:uuid/uuid.dart';

enum FileType {
  pdf,
  image,
  text,
  office,
  video,
  audio,
  archive,
  other,
}

class DocumentRecord {
  final String id;
  final String filePath;
  final String fileName;
  final FileType fileType;
  final int fileSize;
  final DateTime openedAt;
  final String? thumbnailPath;
  final bool isFavorite;

  DocumentRecord({
    required this.id,
    required this.filePath,
    required this.fileName,
    required this.fileType,
    required this.fileSize,
    required this.openedAt,
    this.thumbnailPath,
    this.isFavorite = false,
  });

  DocumentRecord copyWith({
    String? id,
    String? filePath,
    String? fileName,
    FileType? fileType,
    int? fileSize,
    DateTime? openedAt,
    String? thumbnailPath,
    bool? isFavorite,
  }) {
    return DocumentRecord(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
      openedAt: openedAt ?? this.openedAt,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'file_path': filePath,
      'file_name': fileName,
      'file_type': fileType.name,
      'file_size': fileSize,
      'opened_at': openedAt.millisecondsSinceEpoch,
      'thumbnail_path': thumbnailPath,
      'is_favorite': isFavorite ? 1 : 0,
    };
  }

  factory DocumentRecord.fromMap(Map<String, dynamic> map) {
    return DocumentRecord(
      id: map['id'] as String,
      filePath: map['file_path'] as String,
      fileName: map['file_name'] as String,
      fileType: FileType.values.firstWhere(
        (e) => e.name == map['file_type'],
        orElse: () => FileType.other,
      ),
      fileSize: map['file_size'] as int,
      openedAt: DateTime.fromMillisecondsSinceEpoch(map['opened_at'] as int),
      thumbnailPath: map['thumbnail_path'] as String?,
      isFavorite: map['is_favorite'] == 1,
    );
  }

  factory DocumentRecord.create({
    required String filePath,
    required String fileName,
    required FileType fileType,
    required int fileSize,
  }) {
    return DocumentRecord(
      id: const Uuid().v4(),
      filePath: filePath,
      fileName: fileName,
      fileType: fileType,
      fileSize: fileSize,
      openedAt: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'DocumentRecord(id: $id, fileName: $fileName, fileType: $fileType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DocumentRecord && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
