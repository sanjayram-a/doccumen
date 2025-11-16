# Doccumen - Project Structure Documentation

## 📱 Overview
**Doccumen** is a premium, production-ready Flutter document viewer app for Android that supports PDFs, images, text files, and Office documents with clean architecture and modern Material 3 design.

## 🏗️ Architecture
The project follows **Clean Architecture** with a feature-based folder structure for scalability and maintainability.

```
lib/
├── core/                           # Core functionality
│   ├── models/                     # Data models
│   │   ├── document_record.dart    # Document metadata model
│   │   └── app_settings.dart       # App settings model
│   ├── services/                   # Business logic services
│   │   ├── database_service.dart   # SQLite database operations
│   │   ├── document_opener_service.dart  # File opening logic
│   │   └── permission_service.dart # Storage permissions
│   ├── providers/                  # Riverpod state management
│   │   ├── database_provider.dart  # Service providers
│   │   ├── settings_provider.dart  # Settings state
│   │   └── documents_provider.dart # Documents state
│   ├── navigation/                 # Routing
│   │   └── app_router.dart         # Go Router configuration
│   ├── theme/                      # UI theming
│   │   └── app_theme.dart          # Material 3 themes
│   └── utils/                      # Utility classes
│       ├── file_type_detector.dart # File type detection
│       └── responsive_helper.dart  # Responsive design
│
├── features/                       # Feature modules
│   ├── recent_documents/           # Main home screen
│   │   ├── recent_documents_screen.dart
│   │   └── widgets/
│   │       ├── document_card.dart
│   │       └── filter_chips.dart
│   ├── pdf_viewer/                 # PDF viewing
│   │   └── pdf_viewer_screen.dart
│   ├── image_viewer/               # Image viewing
│   │   └── image_viewer_screen.dart
│   └── settings/                   # App settings
│       └── settings_screen.dart
│
├── shared/                         # Shared components
│   ├── widgets/                    # Reusable widgets
│   │   ├── empty_state_widget.dart
│   │   ├── loading_widget.dart
│   │   ├── error_widget.dart
│   │   └── file_type_icon.dart
│   └── formatters/                 # Data formatters
│       ├── file_size_formatter.dart
│       └── date_formatter.dart
│
└── main.dart                       # App entry point
```

## 🔑 Key Features

### 1. **File Type Support**
- **PDF** - In-app viewing with pdfrx (zoom, page navigation, search)
- **Images** - In-app viewing with photo_view (zoom, pan)
- **Text** - .txt, .md, .json, .log files
- **Office** - .doc, .docx, .xls, .xlsx, .ppt, .pptx (opens with native apps)
- **Media** - Video and audio files (opens with native apps)
- **Archives** - .zip, .rar, .7z (opens with native apps)

### 2. **Document Management**
- Recent documents list with SQLite persistence
- Favorites system
- Search and filter by file type
- File metadata tracking (size, date, path)
- Swipe actions and context menus

### 3. **PDF Viewer Features**
- Full-screen viewing
- Page navigation (slider, buttons, thumbnails)
- Zoom in/out controls
- Page counter
- Text search (ready for implementation)
- Document info modal
- Share functionality

### 4. **Settings**
- Theme modes (Light/Dark/System)
- History management
- Retention periods (30/90/forever days)
- Default viewer preferences
- Clear history option

### 5. **State Management**
- **Riverpod** for reactive state
- Provider-based dependency injection
- Async state handling with error/loading states
- Automatic state persistence

## 📦 Dependencies

### Core
- `flutter_riverpod` - State management
- `riverpod_annotation` - Code generation support
- `go_router` - Declarative routing

### File Handling
- `file_picker` - File selection
- `open_file` - Native app intents
- `path_provider` - File paths
- `permission_handler` - Storage permissions

### Viewing
- `pdfrx` - PDF rendering (PDFium-based)
- `photo_view` - Image zoom/pan

### Database
- `sqflite` - SQLite database

### UI
- `flutter_screenutil` - Responsive design
- Material 3 design system

### Utilities
- `uuid` - Unique IDs
- `intl` - Internationalization
- `timeago` - Relative timestamps
- `mime` - MIME type detection

## 🗄️ Database Schema

### `recent_documents` Table
```sql
CREATE TABLE recent_documents (
  id TEXT PRIMARY KEY,
  file_path TEXT NOT NULL,
  file_name TEXT NOT NULL,
  file_type TEXT NOT NULL,
  file_size INTEGER NOT NULL,
  opened_at INTEGER NOT NULL,
  thumbnail_path TEXT,
  is_favorite INTEGER NOT NULL DEFAULT 0
)

-- Indexes
CREATE INDEX idx_opened_at ON recent_documents(opened_at DESC)
CREATE INDEX idx_file_type ON recent_documents(file_type)
CREATE INDEX idx_is_favorite ON recent_documents(is_favorite)
```

### `app_settings` Table
```sql
CREATE TABLE app_settings (
  id INTEGER PRIMARY KEY CHECK (id = 1),
  theme_mode TEXT NOT NULL DEFAULT 'system',
  keep_history INTEGER NOT NULL DEFAULT 1,
  history_retention_days INTEGER NOT NULL DEFAULT 90,
  default_to_in_app_viewer INTEGER NOT NULL DEFAULT 1,
  show_thumbnails INTEGER NOT NULL DEFAULT 1,
  pdf_default_zoom REAL NOT NULL DEFAULT 1.0,
  pdf_continuous_scroll INTEGER NOT NULL DEFAULT 1
)
```

## 🎨 Theme & Design

### Material 3 Design System
- Primary Color: `#6366F1` (Indigo)
- Secondary Color: `#8B5CF6` (Purple)
- Error Color: `#EF4444` (Red)
- Success Color: `#10B981` (Green)

### Responsive Design
- **Mobile** (<600dp): Single column, compact spacing
- **Tablet** (600-900dp): Multi-column grids
- **Desktop** (>900dp): Wide layouts with sidebars

## 🔄 File Opening Logic

```
File Selected
    ↓
Detect File Type (by extension)
    ↓
Create DocumentRecord
    ↓
Save to Database
    ↓
Check if in-app viewable?
    ├─ YES → Navigate to viewer (PDF/Image/Text)
    └─ NO → Open with native app intent
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.9.2+)
- Android SDK (API 21+)
- Dart SDK (included with Flutter)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repo-url>
   cd doccumen
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Android Permissions

Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE"/>
```

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Generate coverage
flutter test --coverage
```

## 📝 Code Generation

For Riverpod code generation (when using @riverpod annotations):
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## 🔒 Security & Privacy
- No data collection
- All data stored locally
- No network requests (except native app intents)
- Permissions requested only when needed
- Open-source, auditable code

## 📱 Supported Platforms
- ✅ Android (Primary target)
- ⚠️ iOS (Not tested, may require adjustments)
- ❌ Web (Not supported - file system limitations)
- ❌ Desktop (Not implemented)

## 🛠️ Build for Production

```bash
# Build APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release

# Build with obfuscation
flutter build apk --release --obfuscate --split-debug-info=build/debug-info
```

## 📄 License
All dependencies use permissive licenses (MIT/BSD) suitable for commercial use.

## 🤝 Contributing
Contributions welcome! Please follow clean architecture principles and Material 3 design guidelines.

---
**Built with ❤️ using Flutter**
