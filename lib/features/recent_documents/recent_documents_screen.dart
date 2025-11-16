import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart' hide FileType;
import 'package:go_router/go_router.dart';
import '../../core/models/document_record.dart';
import '../../core/providers/documents_provider.dart';
import '../../core/providers/database_provider.dart';
import '../../shared/widgets/empty_state_widget.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../shared/widgets/error_widget.dart';
import 'widgets/document_card.dart';
import 'widgets/filter_chips.dart';

class RecentDocumentsScreen extends ConsumerStatefulWidget {
  const RecentDocumentsScreen({super.key});

  @override
  ConsumerState<RecentDocumentsScreen> createState() =>
      _RecentDocumentsScreenState();
}

class _RecentDocumentsScreenState
    extends ConsumerState<RecentDocumentsScreen> {
  FileType? _selectedFilter;
  bool _showFavoritesOnly = false;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final documentsAsync = ref.watch(
      filteredDocumentsProvider(DocumentsFilter(
        fileType: _selectedFilter,
        favoritesOnly: _showFavoritesOnly,
        searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
      )),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doccumen'),
        actions: [
          IconButton(
            icon: Icon(
              _showFavoritesOnly ? Icons.favorite : Icons.favorite_border,
            ),
            onPressed: () {
              setState(() {
                _showFavoritesOnly = !_showFavoritesOnly;
              });
            },
            tooltip: 'Favorites',
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showOptionsMenu,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search documents...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          FilterChips(
            selectedFilter: _selectedFilter,
            onFilterChanged: (filter) {
              setState(() {
                _selectedFilter = filter;
              });
            },
          ),
          Expanded(
            child: documentsAsync.when(
              data: (documents) {
                if (documents.isEmpty) {
                  return EmptyStateWidget(
                    icon: _showFavoritesOnly
                        ? Icons.favorite_border
                        : Icons.description_outlined,
                    title: _showFavoritesOnly
                        ? 'No favorite documents'
                        : 'No documents yet',
                    subtitle: _showFavoritesOnly
                        ? 'Mark documents as favorite to see them here'
                        : 'Open a document to get started',
                    actionLabel: 'Browse files',
                    onAction: _pickFile,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    return DocumentCard(
                      document: documents[index],
                      onTap: () => _openDocument(documents[index]),
                      onToggleFavorite: () =>
                          _toggleFavorite(documents[index].id),
                      onDelete: () => _deleteDocument(documents[index].id),
                      onShare: () => _shareDocument(documents[index]),
                    );
                  },
                );
              },
              loading: () => const LoadingWidget(message: 'Loading documents...'),
              error: (error, stack) => ErrorDisplayWidget(
                message: error.toString(),
                onRetry: () {
                  ref.read(recentDocumentsProvider.notifier).refresh();
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pickFile,
        icon: const Icon(Icons.add),
        label: const Text('Open File'),
      ),
    );
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      
      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        final documentOpener = ref.read(documentOpenerServiceProvider);
        
        final document = await documentOpener.openDocument(filePath);
        if (document != null && mounted) {
          _openDocument(document);
        }
        
        ref.read(recentDocumentsProvider.notifier).refresh();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening file: $e')),
        );
      }
    }
  }

  void _openDocument(DocumentRecord document) async {
    final documentOpener = ref.read(documentOpenerServiceProvider);
    
    if (await documentOpener.shouldOpenInApp(document)) {
      if (!mounted) return;
      
      switch (document.fileType) {
        case FileType.pdf:
          context.push('/pdf-viewer', extra: document);
          break;
        case FileType.image:
          context.push('/image-viewer', extra: document);
          break;
        case FileType.text:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Text viewer not yet implemented')),
          );
          break;
        default:
          await documentOpener.openWithNativeApp(document.filePath);
      }
    } else {
      try {
        await documentOpener.openWithNativeApp(document.filePath);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to open file: $e')),
          );
        }
      }
    }
  }

  Future<void> _toggleFavorite(String documentId) async {
    await ref.read(recentDocumentsProvider.notifier).toggleFavorite(documentId);
  }

  Future<void> _deleteDocument(String documentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document'),
        content: const Text(
          'Remove this document from recent history? The file will not be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(recentDocumentsProvider.notifier).deleteDocument(documentId);
    }
  }

  void _shareDocument(DocumentRecord document) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sharing ${document.fileName}')),
    );
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                context.push('/settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_sweep),
              title: const Text('Clear History'),
              onTap: () async {
                Navigator.pop(context);
                await _clearHistory();
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text(
          'This will remove all documents from your recent list. Files will not be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(recentDocumentsProvider.notifier).clearHistory();
    }
  }
}
