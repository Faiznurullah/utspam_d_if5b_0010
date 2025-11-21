# 💊 Medicine Store App - UTS PAM

![Medicine Store App](https://github.com/user-attachments/assets/b95263f8-d4f8-41e5-8806-65d778a41d29)

A modern and intuitive medicine store management application built with Flutter. This app provides a comprehensive solution for managing pharmaceutical transactions, user profiles, and prescription handling.

## 📱 Features

### 🔐 Authentication System
- **User Registration** - Create new user accounts with validation
- **User Login** - Secure login with username/password
- **Profile Management** - Complete user profile editing with database integration

### 💊 Product Management
- **Product Catalog** - Browse available medicines and supplements
- **Product Details** - Detailed information for each product
- **Category Filtering** - Organized product categories

### 🛒 Transaction Management
- **Add Transaction** - Create new purchase transactions
- **Transaction History** - View personal transaction history
- **Transaction Details** - Complete transaction information view
- **Edit Transactions** - Modify existing transactions
- **Cancel Transactions** - Cancel transactions with status updates

### 📋 Prescription Handling
- **Prescription Upload** - Take photos or select from gallery
- **Prescription Management** - Store and manage prescription images
- **Direct Purchase** - Support for both direct and prescription-based purchases

### 👤 User Management
- **Profile View** - Display user information
- **Profile Edit** - Update personal information
- **Password Change** - Secure password updates
- **Data Validation** - Comprehensive form validation

## 🛠️ Technical Stack

### Frontend
- **Flutter** - Cross-platform mobile framework
- **Dart** - Programming language
- **Material Design** - UI/UX design system

### Database
- **SQLite** - Local database storage
- **sqflite** - Flutter SQLite plugin

### Key Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.3.0
  path: ^1.8.3
  image_picker: ^1.0.4
  path_provider: ^2.1.1
  carousel_slider: ^4.2.1
```

## 🗃️ Database Schema

### Users Table
```sql
CREATE TABLE users(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  fullname VARCHAR(255) NOT NULL,
  username VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL,
  password VARCHAR(255) NOT NULL,
  phone VARCHAR(20) NOT NULL,
  address TEXT
);
```

### Transactions Table
```sql
CREATE TABLE transactions(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  transaction_id VARCHAR(50) UNIQUE NOT NULL,
  user_id INTEGER NOT NULL,
  buyer_name VARCHAR(255) NOT NULL,
  drug_id INTEGER NOT NULL,
  drug_name VARCHAR(255) NOT NULL,
  drug_category VARCHAR(100) NOT NULL,
  drug_price REAL NOT NULL,
  quantity INTEGER NOT NULL,
  total_cost REAL NOT NULL,
  purchase_method VARCHAR(50) NOT NULL DEFAULT 'langsung',
  prescription_number VARCHAR(100),
  prescription_image_path TEXT,
  additional_notes TEXT,
  status VARCHAR(20) NOT NULL DEFAULT 'selesai',
  purchase_date DATETIME NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
);
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK (>=2.17.0)
- Android Studio / VS Code
- Android/iOS device or emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Faiznurullah/utspam_d_if5b_0010.git
   cd utspam_d_if5b_0010
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

### Build for Release

**Android APK:**
```bash
flutter build apk --release
```

**Android App Bundle:**
```bash
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

## 📱 App Screenshots

| Home Screen | Transaction History | Profile Page |
|------------|-------------------|-------------|
| ![Home](https://github.com/user-attachments/assets/b95263f8-d4f8-41e5-8806-65d778a41d29) | Transaction management interface | User profile management |

## 🎥 Demo Video

Watch the full app demonstration: [Demo Video](https://drive.google.com/file/d/1a961wbZkbhtcmOHp0oW3XumNTTrraM4t/view?usp=sharing)

## 🎨 Design Inspiration

The app design is inspired by: [Figma Design](https://www.figma.com/design/hjarXhofqljA8mxwVvcx9W/medicine2--Community-?node-id=1-1099&t=eswSmQZTzSASopLV-1)

## ✨ Key Features Implemented

### 🔒 Security & Privacy
- **User Ownership** - Each user can only view and manage their own transactions
- **Data Validation** - Comprehensive input validation
- **Secure Storage** - SQLite database with proper constraints

### 🖼️ Media Handling
- **Image Upload** - Camera and gallery integration for prescriptions
- **File Management** - Secure file storage for prescription images
- **Permission Handling** - Proper Android/iOS permissions

### 🎯 User Experience
- **Responsive Design** - Optimized for various screen sizes
- **Intuitive Navigation** - Clean and user-friendly interface
- **Real-time Updates** - Immediate UI updates after data changes
- **Error Handling** - Graceful error management with user feedback

### 📊 Data Management
- **CRUD Operations** - Complete Create, Read, Update, Delete functionality
- **Data Relationships** - Proper foreign key relationships
- **Transaction Tracking** - Comprehensive transaction history
- **Status Management** - Transaction status tracking (completed/cancelled)

## 🔧 Configuration

### Android Permissions
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
```

### iOS Permissions
```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to take prescription photos</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access to select prescription images</string>
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📞 Contact

**Developer:** Faiz Nurullah  
**Repository:** [utspam_d_if5b_0010](https://github.com/Faiznurullah/utspam_d_if5b_0010)  
**Branch:** dev

## 📄 License

This project is created for academic purposes as part of UTS PAM (Ujian Tengah Semester - Pemrograman Aplikasi Mobile).

---

⭐ **Don't forget to star this repository if you found it helpful!**
