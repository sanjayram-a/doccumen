import 'dart:io';
import 'package:open_file/open_file.dart';
import '../models/document_record.dart';
import '../utils/file_type_detector.dart';
import 'database_service.dart';

class DocumentOpenerService {
  final DatabaseService _databaseService;

  DocumentOpenerService(this._databaseService);

  Future<DocumentRecord?> openDocument(String filePath) async {
    final file = File(filePath);
    
    if (!await file.exists()) {
      throw Exception('File not found: $filePath');
    }

    final fileType = FileTypeDetector.detectFileType(filePath);
    final fileSize = await file.length();
    final fileName = filePath.split(Platform.pathSeparator).last;

    final document = DocumentRecord.create(
      filePath: filePath,
      fileName: fileName,
      fileType: fileType,
      fileSize: fileSize,
    );

    await _databaseService.insertDocument(document);

    return document;
  }

  Future<void> openWithNativeApp(String filePath) async {
    final result = await OpenFile.open(filePath);
    
    if (result.type != ResultType.done) {
      throw Exception('Failed to open file: ${result.message}');
    }
  }

  Future<bool> shouldOpenInApp(DocumentRecord document) async {
    return FileTypeDetector.canOpenInApp(document.fileType);
  }

  Future<void> deleteDocumentRecord(String documentId) async {
    await _databaseService.deleteDocument(documentId);
  }

  Future<void> toggleFavorite(String documentId) async {
    await _databaseService.toggleFavorite(documentId);
  }
}
