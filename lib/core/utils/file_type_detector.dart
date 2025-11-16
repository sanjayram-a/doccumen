import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import '../models/document_record.dart';

class FileTypeDetector {
  static const _imageExtensions = [
    'png', 'jpg', 'jpeg', 'gif', 'bmp', 'webp', 'heic', 'heif', 'svg'
  ];

  static const _textExtensions = [
    'txt', 'md', 'json', 'log', 'xml', 'csv', 'yaml', 'yml'
  ];

  static const _officeExtensions = [
    'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'odt', 'ods', 'odp'
  ];

  static const _videoExtensions = [
    'mp4', 'avi', 'mkv', 'mov', 'wmv', 'flv', 'webm', 'm4v', '3gp'
  ];

  static const _audioExtensions = [
    'mp3', 'wav', 'aac', 'flac', 'ogg', 'm4a', 'wma', 'opus'
  ];

  static const _archiveExtensions = [
    'zip', 'rar', '7z', 'tar', 'gz', 'bz2', 'xz', 'iso'
  ];

  static FileType detectFileType(String filePath) {
    final ext = path.extension(filePath).toLowerCase().replaceAll('.', '');
    
    if (ext == 'pdf') return FileType.pdf;
    if (_imageExtensions.contains(ext)) return FileType.image;
    if (_textExtensions.contains(ext)) return FileType.text;
    if (_officeExtensions.contains(ext)) return FileType.office;
    if (_videoExtensions.contains(ext)) return FileType.video;
    if (_audioExtensions.contains(ext)) return FileType.audio;
    if (_archiveExtensions.contains(ext)) return FileType.archive;
    
    return FileType.other;
  }

  static String? getMimeType(String filePath) {
    return lookupMimeType(filePath);
  }

  static bool canOpenInApp(FileType fileType) {
    return fileType == FileType.pdf ||
           fileType == FileType.image ||
           fileType == FileType.text;
  }

  static String getFileTypeLabel(FileType fileType) {
    switch (fileType) {
      case FileType.pdf:
        return 'PDF Document';
      case FileType.image:
        return 'Image';
      case FileType.text:
        return 'Text Document';
      case FileType.office:
        return 'Office Document';
      case FileType.video:
        return 'Video';
      case FileType.audio:
        return 'Audio';
      case FileType.archive:
        return 'Archive';
      case FileType.other:
        return 'File';
    }
  }
}
