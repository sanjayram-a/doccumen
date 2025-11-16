import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/document_record.dart';
import 'database_provider.dart';

final recentDocumentsProvider = NotifierProvider<
    RecentDocumentsNotifier, AsyncValue<List<DocumentRecord>>>(() {
  return RecentDocumentsNotifier();
});

final filteredDocumentsProvider = Provider.family<
    AsyncValue<List<DocumentRecord>>, DocumentsFilter>((ref, filter) {
  final documents = ref.watch(recentDocumentsProvider);
  
  return documents.when(
    data: (docs) {
      var filtered = docs;

      if (filter.fileType != null) {
        filtered = filtered.where((d) => d.fileType == filter.fileType).toList();
      }

      if (filter.favoritesOnly) {
        filtered = filtered.where((d) => d.isFavorite).toList();
      }

      if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
        final query = filter.searchQuery!.toLowerCase();
        filtered = filtered
            .where((d) => d.fileName.toLowerCase().contains(query))
            .toList();
      }

      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (e, s) => AsyncValue.error(e, s),
  );
});

class DocumentsFilter {
  final FileType? fileType;
  final bool favoritesOnly;
  final String? searchQuery;

  const DocumentsFilter({
    this.fileType,
    this.favoritesOnly = false,
    this.searchQuery,
  });

  DocumentsFilter copyWith({
    FileType? fileType,
    bool? favoritesOnly,
    String? searchQuery,
  }) {
    return DocumentsFilter(
      fileType: fileType ?? this.fileType,
      favoritesOnly: favoritesOnly ?? this.favoritesOnly,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class RecentDocumentsNotifier
    extends Notifier<AsyncValue<List<DocumentRecord>>> {
  @override
  AsyncValue<List<DocumentRecord>> build() {
    _loadDocuments();
    return const AsyncValue.loading();
  }

  Future<void> _loadDocuments() async {
    try {
      final databaseService = ref.read(databaseServiceProvider);
      final documents = await databaseService.getAllDocuments();
      state = AsyncValue.data(documents);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> toggleFavorite(String documentId) async {
    try {
      final databaseService = ref.read(databaseServiceProvider);
      await databaseService.toggleFavorite(documentId);
      await refresh();
    } catch (error) {
      // Handle error
    }
  }

  Future<void> deleteDocument(String documentId) async {
    try {
      final databaseService = ref.read(databaseServiceProvider);
      await databaseService.deleteDocument(documentId);
      await refresh();
    } catch (error) {
      // Handle error
    }
  }

  Future<void> clearHistory() async {
    try {
      final databaseService = ref.read(databaseServiceProvider);
      await databaseService.clearHistory();
      state = const AsyncValue.data([]);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    await _loadDocuments();
  }
}
