import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_service.dart';
import '../services/document_opener_service.dart';
import '../services/permission_service.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService.instance;
});

final documentOpenerServiceProvider = Provider<DocumentOpenerService>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  return DocumentOpenerService(databaseService);
});

final permissionServiceProvider = Provider<PermissionService>((ref) {
  return PermissionService();
});
