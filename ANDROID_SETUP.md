# Android Setup Guide for Doccumen

## Required Android Permissions

### 1. Update AndroidManifest.xml

Navigate to `android/app/src/main/AndroidManifest.xml` and add these permissions:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    
    <!-- Storage Permissions -->
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
        android:maxSdkVersion="32" />
    <uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE"
        tools:ignore="ScopedStorage" />
    
    <!-- Android 13+ Photo/Video/Audio permissions -->
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
    <uses-permission android:name="android.permission.READ_MEDIA_VIDEO"/>
    <uses-permission android:name="android.permission.READ_MEDIA_AUDIO"/>
    
    <application
        android:label="Doccumen"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher"
        android:requestLegacyExternalStorage="true">
        
        <!-- Rest of your application config -->
        
    </application>
</manifest>
```

### 2. Update build.gradle (Module level)

File: `android/app/build.gradle`

```gradle
android {
    namespace 'com.doccumen.app'  // Change this to your package name
    compileSdk 34  // Update to latest

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = '1.8'
    }

    defaultConfig {
        applicationId "com.doccumen.app"  // Change this to your package name
        minSdk 21  // Minimum Android 5.0
        targetSdk 34
        versionCode 1
        versionName "1.0.0"
    }

    buildTypes {
        release {
            signingConfig signingConfigs.debug
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

### 3. Update build.gradle (Project level)

File: `android/build.gradle`

```gradle
buildscript {
    ext.kotlin_version = '1.9.0'
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath 'com.android.tools.build:gradle:8.1.0'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
```

### 4. ProGuard Rules (Optional)

Create `android/app/proguard-rules.pro` if it doesn't exist:

```proguard
# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# PDFrx
-keep class com.pdfium.** { *; }

# Sqflite
-keep class com.tekartik.sqflite.** { *; }
```

### 5. Storage Permission Request Flow

The app automatically handles storage permissions through the `PermissionService` class:

1. **On first file access**: App requests storage permission
2. **If denied**: Shows rationale dialog
3. **If permanently denied**: Opens app settings

### 6. Testing Permissions

```bash
# Grant permissions via ADB (for testing)
adb shell pm grant com.doccumen.app android.permission.READ_EXTERNAL_STORAGE
adb shell pm grant com.doccumen.app android.permission.WRITE_EXTERNAL_STORAGE

# Check current permissions
adb shell dumpsys package com.doccumen.app | grep permission
```

### 7. File Provider Configuration (for sharing files)

Create `android/app/src/main/res/xml/file_paths.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<paths>
    <external-path name="external_files" path="." />
    <root-path name="root" path="." />
    <files-path name="files" path="." />
    <cache-path name="cache" path="." />
</paths>
```

Add to AndroidManifest.xml inside `<application>`:

```xml
<provider
    android:name="androidx.core.content.FileProvider"
    android:authorities="${applicationId}.fileprovider"
    android:exported="false"
    android:grantUriPermissions="true">
    <meta-data
        android:name="android.support.FILE_PROVIDER_PATHS"
        android:resource="@xml/file_paths" />
</provider>
```

### 8. Min SDK Requirements

- **Minimum SDK**: 21 (Android 5.0 Lollipop)
- **Target SDK**: 34 (Android 14)
- **Compile SDK**: 34

### 9. App Icon

Replace default launcher icon in:
- `android/app/src/main/res/mipmap-hdpi/ic_launcher.png`
- `android/app/src/main/res/mipmap-mdpi/ic_launcher.png`
- `android/app/src/main/res/mipmap-xhdpi/ic_launcher.png`
- `android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png`
- `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png`

Or use [flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons) package.

### 10. Testing on Different Android Versions

**Android 10 (API 29) - Scoped Storage**
- Limited access to external storage
- Use `requestLegacyExternalStorage="true"` for compatibility

**Android 11+ (API 30+) - Enhanced Scoped Storage**
- Requires MANAGE_EXTERNAL_STORAGE for full access
- Or use MediaStore API for specific file types

**Android 13+ (API 33+) - Granular Media Permissions**
- READ_MEDIA_IMAGES, READ_MEDIA_VIDEO, READ_MEDIA_AUDIO
- More fine-grained control

### 11. Common Issues & Solutions

**Issue**: Permission denied even after granting
- **Solution**: Uninstall and reinstall the app, or clear app data

**Issue**: File picker not working
- **Solution**: Check if storage permission is granted in Settings

**Issue**: Can't open files from Downloads folder
- **Solution**: On Android 11+, might need MANAGE_EXTERNAL_STORAGE

**Issue**: PDF viewer shows blank screen
- **Solution**: Ensure file path is correct and file exists

### 12. Build Commands

```bash
# Debug build
flutter run

# Release APK
flutter build apk --release

# Release App Bundle (for Play Store)
flutter build appbundle --release

# Split APK by ABI
flutter build apk --release --split-per-abi
```

### 13. App Signing (for release)

Create `android/key.properties`:

```properties
storePassword=<your-store-password>
keyPassword=<your-key-password>
keyAlias=upload
storeFile=<path-to-keystore.jks>
```

Update `android/app/build.gradle`:

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

---

**Note**: Remember to update all instances of `com.doccumen.app` to your actual package name.
