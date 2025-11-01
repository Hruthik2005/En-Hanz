# En-HanZ - Dysgraphia Detection System

A comprehensive Flutter application for detecting and managing dysgraphia in children through IQ testing and handwriting analysis.

## 🌟 Features

- **User Authentication** - Secure login/register with Firebase Auth
- **IQ Testing** - Interactive cognitive assessment with automated scoring
- **Handwriting Analysis** - AI-powered handwriting sample evaluation
- **Comprehensive Reports** - Combined IQ and handwriting risk assessment
- **Practice Games** - Letter tracing, dot joining, and word copying exercises
- **HandyBot** - AI chatbot for guidance and support
- **History Tracking** - View past assessments and track progress
- **Multi-language Support** - English, Hindi, Telugu, Tamil

## 🔥 Firebase Backend

This app uses Firebase for:
- **Authentication** - Email/password user accounts
- **Firestore Database** - Store user profiles, IQ results, handwriting analyses, and reports
- **Storage** - Upload and store handwriting images
- **Security** - Users can only access their own data

### Collections
- `users` - User profiles (name, age, disability type)
- `iq_results` - IQ test scores and calculations
- `handwriting_analysis` - Handwriting samples and AI analysis
- `reports` - Comprehensive assessment reports

## 📱 Screens

1. **Splash Screen** - App loading animation
2. **Login/Register** - User authentication
3. **Profile** - Create/edit child profile
4. **Home** - Main navigation hub
5. **IQ Test** - Interactive quiz with auto-scoring
6. **Upload** - Handwriting sample submission
7. **Results** - View assessment reports
8. **Practice Zone** - Educational games
9. **HandyBot** - AI chat assistant
10. **History** - Past assessments
11. **Settings** - App preferences and logout
12. **About** - App information

## 🛠️ Tech Stack

- **Frontend**: Flutter 3.35.7
- **Backend**: Firebase (Auth, Firestore, Storage)
- **ML Backend**: FastAPI (Python) - for handwriting analysis
- **State Management**: Provider
- **UI**: Material 3 with custom modern theme

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.35.7 or higher
- Firebase project (en-hanz)
- Node.js (for Firebase tools)
- Python 3.8+ (for FastAPI backend)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Hruthik2005/En-Hanz.git
   cd flutter_application_1
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Already configured for project `en-hanz`
   - `firebase_options.dart` is generated
   - Deploy security rules:
     ```bash
     firebase deploy --only firestore:rules,storage:rules
     ```

4. **Enable Firebase Services**
   - Go to [Firebase Console](https://console.firebase.google.com/project/en-hanz)
   - Enable Authentication (Email/Password)
   - Enable Firestore Database
   - Enable Storage

5. **Run the app**
   ```bash
   flutter run -d windows
   ```

## 📚 Documentation

- **[FIREBASE_SETUP.md](FIREBASE_SETUP.md)** - Complete Firebase setup and deployment guide
- **[FIREBASE_IMPLEMENTATION_SUMMARY.md](FIREBASE_IMPLEMENTATION_SUMMARY.md)** - Detailed overview of Firebase backend implementation
- **[SCREEN_INTEGRATION_GUIDE.md](SCREEN_INTEGRATION_GUIDE.md)** - Step-by-step guide to integrate Firebase into screens

## 🔐 Security

- Firebase Security Rules ensure users can only access their own data
- Authentication required for all operations
- Image uploads limited to 10MB and images only
- All sensitive operations use proper authentication checks

## 🎨 UI Theme

Modern theme with:
- Primary Blue (#2563EB)
- Secondary Purple (#7C3AED)
- Accent Amber (#F59E0B)
- Success Green (#10B981)
- Danger Red (#EF4444)
- Info Cyan (#06B6D4)

## 📦 Packages

### Core
- `firebase_core` - Firebase initialization
- `firebase_auth` - User authentication
- `cloud_firestore` - Database
- `firebase_storage` - File storage

### UI
- `google_fonts` - Custom fonts
- `provider` - State management
- `confetti` - Celebration animations

### Others
- `image_picker` - Select images
- `flutter_colorpicker` - Color selection
- `http` - API calls (for FastAPI)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License.

## 👥 Team

- **Hruthik2005** - Lead Developer
- **En-HanZ Team** - Design & Development

## 🆘 Support

For questions or issues:
- Check documentation files in the repository
- Open an issue on GitHub
- Contact the development team

## 🎯 Roadmap

- [x] User authentication system
- [x] Firebase backend integration
- [x] IQ testing module
- [x] Handwriting upload
- [ ] FastAPI ML model integration
- [ ] Progress graphs and analytics
- [ ] Teacher dashboard
- [ ] Parent notifications
- [ ] Multi-user profiles

## 📊 Architecture

```
Flutter App (Frontend)
    ↓
Firebase Services
    ├── Authentication
    ├── Firestore (Database)
    └── Storage (Images)
    ↓
FastAPI Backend (Python)
    └── ML Model (Handwriting Analysis)
```

---

**Built with ❤️ for helping children overcome dysgraphia**

