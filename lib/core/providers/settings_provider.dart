import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_settings.dart';
import 'database_provider.dart';

final settingsProvider =
    NotifierProvider<SettingsNotifier, AsyncValue<AppSettings>>(() {
  return SettingsNotifier();
});

class SettingsNotifier extends Notifier<AsyncValue<AppSettings>> {
  @override
  AsyncValue<AppSettings> build() {
    _loadSettings();
    return const AsyncValue.loading();
  }

  Future<void> _loadSettings() async {
    try {
      final databaseService = ref.read(databaseServiceProvider);
      final settings = await databaseService.getSettings();
      state = AsyncValue.data(settings);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateThemeMode(AppThemeMode themeMode) async {
    final currentSettings = state.value;
    if (currentSettings == null) return;

    final newSettings = currentSettings.copyWith(themeMode: themeMode);
    await _updateSettings(newSettings);
  }

  Future<void> updateKeepHistory(bool keepHistory) async {
    final currentSettings = state.value;
    if (currentSettings == null) return;

    final newSettings = currentSettings.copyWith(keepHistory: keepHistory);
    await _updateSettings(newSettings);
  }

  Future<void> updateHistoryRetention(int days) async {
    final currentSettings = state.value;
    if (currentSettings == null) return;

    final newSettings = currentSettings.copyWith(historyRetentionDays: days);
    await _updateSettings(newSettings);
  }

  Future<void> updateDefaultToInAppViewer(bool value) async {
    final currentSettings = state.value;
    if (currentSettings == null) return;

    final newSettings = currentSettings.copyWith(defaultToInAppViewer: value);
    await _updateSettings(newSettings);
  }

  Future<void> updatePdfSettings({
    double? defaultZoom,
    bool? continuousScroll,
  }) async {
    final currentSettings = state.value;
    if (currentSettings == null) return;

    final newSettings = currentSettings.copyWith(
      pdfDefaultZoom: defaultZoom,
      pdfContinuousScroll: continuousScroll,
    );
    await _updateSettings(newSettings);
  }

  Future<void> _updateSettings(AppSettings settings) async {
    try {
      final databaseService = ref.read(databaseServiceProvider);
      await databaseService.updateSettings(settings);
      state = AsyncValue.data(settings);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    await _loadSettings();
  }
}
