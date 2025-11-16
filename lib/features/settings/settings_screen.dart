import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/app_settings.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/providers/documents_provider.dart';
import '../../shared/widgets/loading_widget.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: settingsAsync.when(
        data: (settings) => ListView(
          children: [
            _buildSection(
              context,
              title: 'Appearance',
              children: [
                ListTile(
                  leading: const Icon(Icons.palette_outlined),
                  title: const Text('Theme'),
                  subtitle: Text(_getThemeLabel(settings.themeMode)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showThemeDialog(context, ref, settings),
                ),
              ],
            ),
            _buildSection(
              context,
              title: 'History',
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.history),
                  title: const Text('Keep History'),
                  subtitle: const Text('Track recently opened documents'),
                  value: settings.keepHistory,
                  onChanged: (value) {
                    ref
                        .read(settingsProvider.notifier)
                        .updateKeepHistory(value);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.schedule),
                  title: const Text('History Retention'),
                  subtitle: Text('${settings.historyRetentionDays} days'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () =>
                      _showRetentionDialog(context, ref, settings),
                ),
                ListTile(
                  leading: const Icon(Icons.delete_sweep),
                  title: const Text('Clear History'),
                  subtitle: const Text('Remove all recent documents'),
                  onTap: () => _clearHistory(context, ref),
                ),
              ],
            ),
            _buildSection(
              context,
              title: 'Viewer Settings',
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.open_in_new),
                  title: const Text('Open in App'),
                  subtitle: const Text('Open supported files in-app'),
                  value: settings.defaultToInAppViewer,
                  onChanged: (value) {
                    ref
                        .read(settingsProvider.notifier)
                        .updateDefaultToInAppViewer(value);
                  },
                ),
              ],
            ),
            _buildSection(
              context,
              title: 'About',
              children: [
                const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Version'),
                  subtitle: Text('1.0.0'),
                ),
                ListTile(
                  leading: const Icon(Icons.star_outline),
                  title: const Text('Rate App'),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Opening app store...')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        loading: () => const LoadingWidget(),
        error: (error, stack) => Center(
          child: Text('Error loading settings: $error'),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        ...children,
      ],
    );
  }

  String _getThemeLabel(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.system:
        return 'System';
    }
  }

  void _showThemeDialog(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<AppThemeMode>(
              title: const Text('Light'),
              value: AppThemeMode.light,
              groupValue: settings.themeMode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).updateThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<AppThemeMode>(
              title: const Text('Dark'),
              value: AppThemeMode.dark,
              groupValue: settings.themeMode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).updateThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<AppThemeMode>(
              title: const Text('System'),
              value: AppThemeMode.system,
              groupValue: settings.themeMode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).updateThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRetentionDialog(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('History Retention'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<int>(
              title: const Text('30 days'),
              value: 30,
              groupValue: settings.historyRetentionDays,
              onChanged: (value) {
                if (value != null) {
                  ref
                      .read(settingsProvider.notifier)
                      .updateHistoryRetention(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<int>(
              title: const Text('90 days'),
              value: 90,
              groupValue: settings.historyRetentionDays,
              onChanged: (value) {
                if (value != null) {
                  ref
                      .read(settingsProvider.notifier)
                      .updateHistoryRetention(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<int>(
              title: const Text('Forever'),
              value: 365 * 10,
              groupValue: settings.historyRetentionDays,
              onChanged: (value) {
                if (value != null) {
                  ref
                      .read(settingsProvider.notifier)
                      .updateHistoryRetention(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _clearHistory(BuildContext context, WidgetRef ref) async {
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

    if (confirmed == true && context.mounted) {
      await ref.read(recentDocumentsProvider.notifier).clearHistory();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('History cleared')),
        );
      }
    }
  }
}
