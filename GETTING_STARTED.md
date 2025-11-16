# 🚀 Getting Started with Doccumen

## ✅ Setup Complete!

All core components have been implemented. The app is now ready for testing and customization.

## 📋 What's Been Implemented

### ✓ Core Architecture
- Clean architecture with feature-based folders
- Riverpod state management with providers
- SQLite database with proper schema
- Go Router for navigation
- Material 3 theme (Light/Dark/System)

### ✓ Features
- **Recent Documents Screen** - Main home with search, filters, favorites
- **PDF Viewer** - Full-featured viewer with zoom, navigation, controls
- **Image Viewer** - Photo zoom/pan with PhotoView
- **Settings Screen** - Theme, history, preferences
- **File Opening Service** - Smart routing based on file type
- **Permission Handling** - Storage permission management

### ✓ UI Components
- Empty states, loading widgets, error handling
- Document cards with swipe actions
- Filter chips for file types
- File type icons with colors
- Responsive design helpers

## 🔧 Next Steps

### 1. Configure Android Manifest

**File**: `android/app/src/main/AndroidManifest.xml`

Add these permissions inside `<manifest>`:

```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
    android:maxSdkVersion="32" />
<uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
```

Add inside `<application>`:

```xml
android:requestLegacyExternalStorage="true"
```

**See `ANDROID_SETUP.md` for complete configuration.**

### 2. Test the App

```bash
# Check for connected devices
flutter devices

# Run in debug mode
flutter run

# Run on specific device
flutter run -d <device-id>
```

### 3. First Run Testing

1. **Grant Storage Permission**: The app will request it on first file access
2. **Pick a File**: Use the "Open File" button
3. **Test PDF Viewing**: Open a PDF file
4. **Test Image Viewing**: Open an image file
5. **Check Recent Documents**: Should appear in the list
6. **Test Favorites**: Star/unstar documents
7. **Test Settings**: Change theme, clear history
8. **Test Search**: Search for documents by name
9. **Test Filters**: Filter by file type

### 4. Common First-Run Issues

#### **Issue**: "Target of URI doesn't exist" errors in IDE
- **Solution**: This is normal before running `flutter pub get`. Dependencies are now installed.

#### **Issue**: Can't pick files
- **Solution**: Grant storage permission in Android settings

#### **Issue**: PDF shows blank screen
- **Solution**: Ensure the PDF file is valid and accessible

#### **Issue**: Navigation not working
- **Solution**: Make sure go_router is properly configured (already done)

### 5. Customization Options

#### Change App Name
**File**: `pubspec.yaml`
```yaml
name: your_app_name
description: "Your app description"
```

#### Change Package Name
1. Update `android/app/build.gradle`:
   ```gradle
   namespace 'com.yourcompany.appname'
   applicationId "com.yourcompany.appname"
   ```

2. Update `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <manifest xmlns:android="http://schemas.android.com/apk/res/android"
       package="com.yourcompany.appname">
   ```

#### Change App Icon
Use [flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons):

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.15.1

flutter_launcher_icons:
  android: true
  image_path: "assets/icons/app_icon.png"
```

Then run:
```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

#### Change Theme Colors
**File**: `lib/core/theme/app_theme.dart`

```dart
static const primaryColor = Color(0xFFYOUR_COLOR);
```

### 6. Add Features

#### Text File Viewer
Create `lib/features/text_viewer/text_viewer_screen.dart`:

```dart
class TextViewerScreen extends StatelessWidget {
  final DocumentRecord document;

  const TextViewerScreen({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(document.fileName)),
      body: FutureBuilder<String>(
        future: File(document.filePath).readAsString(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Text(
                snapshot.data!,
                style: TextStyle(fontFamily: 'monospace'),
              ),
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
```

Add route to `lib/core/navigation/app_router.dart`:

```dart
GoRoute(
  path: '/text-viewer',
  name: 'textViewer',
  builder: (context, state) {
    final document = state.extra as DocumentRecord;
    return TextViewerScreen(document: document);
  },
),
```

Update `recent_documents_screen.dart`:

```dart
case FileType.text:
  context.push('/text-viewer', extra: document);
  break;
```

### 7. Build for Release

```bash
# Build APK
flutter build apk --release

# Build App Bundle (Google Play)
flutter build appbundle --release

# Build with obfuscation
flutter build apk --release --obfuscate --split-debug-info=build/debug-info
```

Output location: `build/app/outputs/flutter-apk/app-release.apk`

### 8. Performance Optimization

```bash
# Analyze app size
flutter build apk --analyze-size

# Profile mode for performance testing
flutter run --profile

# Check for performance issues
flutter pub run dart_code_metrics:metrics analyze lib
```

### 9. Testing

```bash
# Run tests
flutter test

# Run with coverage
flutter test --coverage

# Integration tests
flutter drive --target=test_driver/app.dart
```

### 10. Debugging Tips

#### Enable debug logging:
```dart
// In main.dart
debugPrint('Debug message');
```

#### Check database:
```bash
adb root
adb pull /data/data/com.doccumen.app/databases/doccumen.db
sqlite3 doccumen.db
```

#### Clear app data:
```bash
adb shell pm clear com.doccumen.app
```

## 📚 Documentation Files

- `PROJECT_STRUCTURE.md` - Complete architecture documentation
- `ANDROID_SETUP.md` - Android configuration guide
- `GETTING_STARTED.md` - This file

## 🐛 Known Limitations

1. **Text Viewer**: Not implemented (easy to add, see section 6)
2. **PDF Search**: UI ready, backend not implemented
3. **File Browser**: Could be enhanced with folder navigation
4. **Thumbnails**: Generation not implemented
5. **Share Functionality**: Placeholder, needs implementation

## 🔜 Suggested Enhancements

1. **Cloud Sync**: Add Firebase or other cloud storage
2. **OCR**: Add text extraction from images
3. **PDF Annotations**: Add highlighting, notes
4. **Bookmarks**: Save page positions
5. **Recent Files Widget**: Home screen widget
6. **Dark Mode Toggle**: Quick toggle in app bar
7. **File Categories**: Auto-categorize by type
8. **Export/Import**: Backup and restore functionality

## 📱 Device Testing Checklist

Test on:
- [ ] Android 5.0 (API 21) - Minimum supported
- [ ] Android 10 (API 29) - Scoped storage
- [ ] Android 11+ (API 30+) - Enhanced permissions
- [ ] Android 13+ (API 33+) - Granular media permissions
- [ ] Small screen (< 6")
- [ ] Large screen (> 6.5")
- [ ] Tablet (> 7")

## ❓ Need Help?

1. Check the documentation files
2. Review the code comments
3. Check Flutter documentation: https://docs.flutter.dev
4. Check package documentation:
   - pdfrx: https://pub.dev/packages/pdfrx
   - riverpod: https://riverpod.dev
   - go_router: https://pub.dev/packages/go_router

## 🎉 You're Ready!

Run `flutter run` and start testing your document viewer app!

---

**Built with Flutter • Clean Architecture • Material 3**
