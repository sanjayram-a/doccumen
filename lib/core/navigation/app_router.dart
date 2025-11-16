import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/recent_documents/recent_documents_screen.dart';
import '../../features/pdf_viewer/pdf_viewer_screen.dart';
import '../../features/image_viewer/image_viewer_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../models/document_record.dart';

class AppRouter {
  static const String home = '/';
  static const String pdfViewer = '/pdf-viewer';
  static const String imageViewer = '/image-viewer';
  static const String settings = '/settings';

  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const RecentDocumentsScreen(),
      ),
      GoRoute(
        path: pdfViewer,
        name: 'pdfViewer',
        builder: (context, state) {
          final document = state.extra as DocumentRecord;
          return PdfViewerScreen(document: document);
        },
      ),
      GoRoute(
        path: imageViewer,
        name: 'imageViewer',
        builder: (context, state) {
          final document = state.extra as DocumentRecord;
          return ImageViewerScreen(document: document);
        },
      ),
      GoRoute(
        path: settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64),
            const SizedBox(height: 16),
            Text('Page not found: ${state.uri.path}'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
