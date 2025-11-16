import 'package:flutter/material.dart';
import '../../core/models/document_record.dart';

class FileTypeIcon extends StatelessWidget {
  final FileType fileType;
  final double size;
  final Color? color;

  const FileTypeIcon({
    super.key,
    required this.fileType,
    this.size = 24,
    this.color,
  });

  IconData _getIcon() {
    switch (fileType) {
      case FileType.pdf:
        return Icons.picture_as_pdf;
      case FileType.image:
        return Icons.image;
      case FileType.text:
        return Icons.description;
      case FileType.office:
        return Icons.article;
      case FileType.video:
        return Icons.video_file;
      case FileType.audio:
        return Icons.audio_file;
      case FileType.archive:
        return Icons.folder_zip;
      case FileType.other:
        return Icons.insert_drive_file;
    }
  }

  Color _getColor(BuildContext context) {
    if (color != null) return color!;

    switch (fileType) {
      case FileType.pdf:
        return const Color(0xFFEF4444);
      case FileType.image:
        return const Color(0xFF10B981);
      case FileType.text:
        return const Color(0xFF3B82F6);
      case FileType.office:
        return const Color(0xFF8B5CF6);
      case FileType.video:
        return const Color(0xFFF59E0B);
      case FileType.audio:
        return const Color(0xFFEC4899);
      case FileType.archive:
        return const Color(0xFF6366F1);
      case FileType.other:
        return Theme.of(context).colorScheme.onSurface.withOpacity(0.6);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Icon(
      _getIcon(),
      size: size,
      color: _getColor(context),
    );
  }
}
