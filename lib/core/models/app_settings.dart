import 'package:flutter/material.dart';

enum AppThemeMode {
  light,
  dark,
  system,
}

class AppSettings {
  final AppThemeMode themeMode;
  final bool keepHistory;
  final int historyRetentionDays;
  final bool defaultToInAppViewer;
  final bool showThumbnails;
  final double pdfDefaultZoom;
  final bool pdfContinuousScroll;

  const AppSettings({
    this.themeMode = AppThemeMode.system,
    this.keepHistory = true,
    this.historyRetentionDays = 90,
    this.defaultToInAppViewer = true,
    this.showThumbnails = true,
    this.pdfDefaultZoom = 1.0,
    this.pdfContinuousScroll = true,
  });

  AppSettings copyWith({
    AppThemeMode? themeMode,
    bool? keepHistory,
    int? historyRetentionDays,
    bool? defaultToInAppViewer,
    bool? showThumbnails,
    double? pdfDefaultZoom,
    bool? pdfContinuousScroll,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      keepHistory: keepHistory ?? this.keepHistory,
      historyRetentionDays: historyRetentionDays ?? this.historyRetentionDays,
      defaultToInAppViewer: defaultToInAppViewer ?? this.defaultToInAppViewer,
      showThumbnails: showThumbnails ?? this.showThumbnails,
      pdfDefaultZoom: pdfDefaultZoom ?? this.pdfDefaultZoom,
      pdfContinuousScroll: pdfContinuousScroll ?? this.pdfContinuousScroll,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'theme_mode': themeMode.name,
      'keep_history': keepHistory ? 1 : 0,
      'history_retention_days': historyRetentionDays,
      'default_to_in_app_viewer': defaultToInAppViewer ? 1 : 0,
      'show_thumbnails': showThumbnails ? 1 : 0,
      'pdf_default_zoom': pdfDefaultZoom,
      'pdf_continuous_scroll': pdfContinuousScroll ? 1 : 0,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      themeMode: AppThemeMode.values.firstWhere(
        (e) => e.name == map['theme_mode'],
        orElse: () => AppThemeMode.system,
      ),
      keepHistory: map['keep_history'] == 1,
      historyRetentionDays: map['history_retention_days'] as int,
      defaultToInAppViewer: map['default_to_in_app_viewer'] == 1,
      showThumbnails: map['show_thumbnails'] == 1,
      pdfDefaultZoom: (map['pdf_default_zoom'] as num).toDouble(),
      pdfContinuousScroll: map['pdf_continuous_scroll'] == 1,
    );
  }

  ThemeMode get flutterThemeMode {
    switch (themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}
