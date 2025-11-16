import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';
import '../../core/models/document_record.dart';

class PdfViewerScreen extends ConsumerStatefulWidget {
  final DocumentRecord document;

  const PdfViewerScreen({
    super.key,
    required this.document,
  });

  @override
  ConsumerState<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends ConsumerState<PdfViewerScreen> {
  late final PdfViewerController _controller;
  int _currentPage = 1;
  int _totalPages = 0;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _controller = PdfViewerController();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _showControls
          ? AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.document.fileName,
                    style: const TextStyle(fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (_totalPages > 0)
                    Text(
                      'Page $_currentPage of $_totalPages',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
              backgroundColor: Colors.black87,
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _showSearchDialog,
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'share':
                        _shareDocument();
                        break;
                      case 'info':
                        _showDocumentInfo();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'share',
                      child: Row(
                        children: [
                          Icon(Icons.share),
                          SizedBox(width: 12),
                          Text('Share'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'info',
                      child: Row(
                        children: [
                          Icon(Icons.info_outline),
                          SizedBox(width: 12),
                          Text('Document Info'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            )
          : null,
      body: GestureDetector(
        onTap: () {
          setState(() {
            _showControls = !_showControls;
          });
        },
        child: Stack(
          children: [
            PdfViewer.file(
              widget.document.filePath,
              controller: _controller,
              params: PdfViewerParams(
                backgroundColor: Colors.black,
                pageAnchor: PdfPageAnchor.top,
                onPageChanged: (pageNumber) {
                  setState(() {
                    _currentPage = pageNumber ?? 1;
                  });
                },
                onViewerReady: (document, controller) {
                  setState(() {
                    _totalPages = document.pages.length;
                  });
                },
                viewerOverlayBuilder: (context, size, handleLinkTap) => [
                  if (_showControls)
                    PdfViewerScrollThumb(
                      controller: _controller,
                      orientation: ScrollbarOrientation.right,
                    ),
                ],
              ),
            ),
            if (_showControls && _totalPages > 0)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildBottomControls(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black87,
            Colors.black54,
            Colors.transparent,
          ],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, color: Colors.white),
              onPressed: _currentPage > 1 ? _previousPage : null,
            ),
            Expanded(
              child: Slider(
                value: _currentPage.toDouble(),
                min: 1,
                max: _totalPages.toDouble(),
                divisions: _totalPages,
                onChanged: (value) {
                  _goToPage(value.toInt());
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, color: Colors.white),
              onPressed: _currentPage < _totalPages ? _nextPage : null,
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.zoom_in, color: Colors.white),
              onPressed: _zoomIn,
            ),
            IconButton(
              icon: const Icon(Icons.zoom_out, color: Colors.white),
              onPressed: _zoomOut,
            ),
          ],
        ),
      ),
    );
  }

  void _previousPage() {
    if (_currentPage > 1) {
      _controller.goToPage(pageNumber: _currentPage - 1);
    }
  }

  void _nextPage() {
    if (_currentPage < _totalPages) {
      _controller.goToPage(pageNumber: _currentPage + 1);
    }
  }

  void _goToPage(int page) {
    _controller.goToPage(pageNumber: page);
  }

  void _zoomIn() {
    final currentZoom = _controller.currentZoom;
    final newZoom = currentZoom * 1.2;
    _controller.setZoom(Offset.zero, newZoom);
  }

  void _zoomOut() {
    final currentZoom = _controller.currentZoom;
    final newZoom = currentZoom / 1.2;
    _controller.setZoom(Offset.zero, newZoom);
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search PDF'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Enter search term',
          ),
          onSubmitted: (query) {
            Navigator.pop(context);
            // Implement PDF text search
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Searching for: $query')),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _shareDocument() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sharing ${widget.document.fileName}')),
    );
  }

  void _showDocumentInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Document Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('File: ${widget.document.fileName}'),
            const SizedBox(height: 8),
            Text('Pages: $_totalPages'),
            const SizedBox(height: 8),
            Text('Path: ${widget.document.filePath}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
