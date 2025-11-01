# 🔥 En-HanZ Firebase Backend Setup Guide

Complete guide for setting up Firebase Authentication, Firestore Database, and Storage for the En-HanZ dysgraphia detection app.

---

## 📋 Table of Contents
1. [Firebase Setup](#firebase-setup)
2. [Deploy Security Rules](#deploy-security-rules)
3. [Firebase Services Overview](#firebase-services-overview)
4. [FastAPI Integration](#fastapi-integration)
5. [Testing the Backend](#testing-the-backend)

---

## 🚀 Firebase Setup

### 1. Enable Firebase Services

In your [Firebase Console](https://console.firebase.google.com/project/en-hanz):

#### **Enable Authentication**
1. Go to **Build → Authentication**
2. Click **Get Started**
3. Enable **Email/Password** sign-in method
4. Save changes

#### **Enable Firestore Database**
1. Go to **Build → Firestore Database**
2. Click **Create database**
3. Start in **Production mode** (we'll deploy our custom rules)
4. Choose your preferred location (e.g., `us-central1`)

#### **Enable Storage**
1. Go to **Build → Storage**
2. Click **Get started**
3. Start in **Production mode**
4. Use the same location as Firestore

---

## 🔐 Deploy Security Rules

### Deploy Firestore Rules

The `firestore.rules` file is already created in your project root. Deploy it:

```powershell
# From your project root
firebase deploy --only firestore:rules
```

**What these rules do:**
- ✅ Users can only read/write their own data
- ✅ All collections filtered by `user_id` field
- ✅ Authentication required for all operations
- ❌ No cross-user data access

### Deploy Storage Rules

The `storage.rules` file is already created. Deploy it:

```powershell
firebase deploy --only storage:rules
```

**What these rules do:**
- ✅ Users can only upload to `/handwriting_uploads/{userId}/` folder
- ✅ Maximum 10MB file size
- ✅ Only image files allowed
- ❌ No updates (delete and recreate instead)

---

## 📊 Firebase Services Overview

### Collections Structure

Your Firestore database has these collections:

#### 1️⃣ **users**
```dart
{
  user_id: String,
  name: String,
  age: Number,
  gender?: String,
  disability_type?: String,
  created_at: Timestamp
}
```

#### 2️⃣ **iq_results**
```dart
{
  user_id: String,
  total_score: Number,
  mental_age: Number,
  iq_value: Number,
  test_date: Timestamp
}
```

#### 3️⃣ **handwriting_analysis**
```dart
{
  user_id: String,
  image_url: String,
  risk_score: Number (0.0 - 1.0),
  recommendation: String,
  analyzed_at: Timestamp
}
```

#### 4️⃣ **reports**
```dart
{
  user_id: String,
  iq_result_id?: String,
  handwriting_id?: String,
  overall_risk_label: String (Low/Moderate/High),
  overall_feedback: String,
  report_date: Timestamp
}
```

### Storage Structure

```
handwriting_uploads/
  ├── {user_id_1}/
  │   ├── {user_id_1}_1730000001234.jpg
  │   └── {user_id_1}_1730000002345.jpg
  └── {user_id_2}/
      └── {user_id_2}_1730000003456.jpg
```

---

## 🤖 FastAPI Integration

### 1. Install Firebase Admin SDK

Create a `backend/` folder (outside Flutter project) and install dependencies:

```bash
pip install firebase-admin fastapi python-multipart uvicorn pillow
```

### 2. Get Service Account Key

1. Go to **Project Settings** → **Service Accounts**
2. Click **Generate new private key**
3. Save as `backend/firebase/service-account-key.json`
4. ⚠️ **NEVER commit this file to Git!**

### 3. Create FastAPI Backend Structure

```
backend/
├── main.py
├── firebase/
│   ├── service-account-key.json  # ⚠️ Keep secret!
│   └── firebase_init.py
├── services/
│   ├── ml_service.py
│   └── iq_service.py
├── requirements.txt
└── .env
```

### 4. Sample FastAPI Code

**backend/firebase/firebase_init.py**
```python
import firebase_admin
from firebase_admin import credentials, firestore, storage

# Initialize Firebase Admin
cred = credentials.Certificate('firebase/service-account-key.json')
firebase_admin.initialize_app(cred, {
    'storageBucket': 'en-hanz.firebasestorage.app'
})

# Get Firestore client
db = firestore.client()

# Get Storage bucket
bucket = storage.bucket()
```

**backend/main.py**
```python
from fastapi import FastAPI, File, UploadFile
from firebase.firebase_init import db, bucket
import datetime
import uuid

app = FastAPI()

@app.post("/api/analyze-handwriting")
async def analyze_handwriting(
    user_id: str,
    file: UploadFile = File(...)
):
    # 1. Upload image to Firebase Storage
    blob = bucket.blob(f'handwriting_uploads/{user_id}/{user_id}_{int(datetime.datetime.now().timestamp())}.jpg')
    blob.upload_from_file(file.file, content_type=file.content_type)
    blob.make_public()
    image_url = blob.public_url
    
    # 2. Run ML model (mock for now)
    risk_score = 0.45  # Replace with actual ML prediction
    recommendation = "Shows some signs of dysgraphia. Continue monitoring."
    
    # 3. Save to Firestore
    doc_ref = db.collection('handwriting_analysis').add({
        'user_id': user_id,
        'image_url': image_url,
        'risk_score': risk_score,
        'recommendation': recommendation,
        'analyzed_at': datetime.datetime.now()
    })
    
    return {
        'analysis_id': doc_ref[1].id,
        'risk_score': risk_score,
        'recommendation': recommendation,
        'image_url': image_url
    }

@app.post("/api/save-iq-result")
async def save_iq_result(
    user_id: str,
    total_score: int,
    user_age: int
):
    # Calculate IQ
    mental_age = (total_score / 20) * 18  # Assuming 20 questions
    iq_value = (mental_age / user_age) * 100
    
    # Save to Firestore
    doc_ref = db.collection('iq_results').add({
        'user_id': user_id,
        'total_score': total_score,
        'mental_age': mental_age,
        'iq_value': iq_value,
        'test_date': datetime.datetime.now()
    })
    
    return {
        'result_id': doc_ref[1].id,
        'iq_value': iq_value,
        'mental_age': mental_age
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
```

### 5. Run FastAPI Server

```bash
cd backend
uvicorn main:app --reload
```

Access at: `http://localhost:8000/docs` for Swagger UI

---

## ✅ Testing the Backend

### Test Authentication

1. Run your Flutter app:
   ```powershell
   flutter run -d windows
   ```

2. Register a new account with:
   - Child Name: "Test Child"
   - Age: 10
   - Email: "test@example.com"
   - Password: "test123456"

3. Check Firebase Console → Authentication → Users
   - You should see the new user

4. Check Firestore → users collection
   - You should see the user profile document

### Test Handwriting Upload

1. In your Flutter app, navigate to Upload screen
2. Select a handwriting image
3. The image should upload to Firebase Storage
4. Check Storage in Firebase Console → `handwriting_uploads/`

### Test IQ Test

1. Complete the IQ test in the app
2. Check Firestore → `iq_results` collection
3. You should see the calculated IQ score

### Test Reports

1. After completing both IQ test and handwriting upload
2. Generate a report
3. Check Firestore → `reports` collection

---

## 🔧 Environment Variables

Create `backend/.env`:

```env
FIREBASE_SERVICE_ACCOUNT_PATH=firebase/service-account-key.json
STORAGE_BUCKET=en-hanz.firebasestorage.app
PROJECT_ID=en-hanz
```

---

## 📱 Flutter Services Usage Examples

### Using AuthService
```dart
final authService = AuthService();

// Sign up
await authService.signUpWithEmail(
  email: 'user@example.com',
  password: 'password123',
);

// Sign in
await authService.signInWithEmail(
  email: 'user@example.com',
  password: 'password123',
);

// Sign out
await authService.signOut();
```

### Using UserService
```dart
final userService = UserService();
final userId = AuthService().currentUserId!;

// Create profile
await userService.createUser(UserModel(
  userId: userId,
  name: 'John Doe',
  age: 10,
  createdAt: DateTime.now(),
));

// Get profile
final user = await userService.getUser(userId);
```

### Using IQService
```dart
final iqService = IQService();

// Save IQ result
final resultId = await iqService.calculateAndSaveIQ(
  userId: userId,
  totalScore: 15,
  userAge: 10,
  totalQuestions: 20,
);

// Get user's IQ history
final results = await iqService.getUserIQResults(userId);
```

### Using HandwritingService
```dart
final handwritingService = HandwritingService();

// Upload and save analysis
final analysisId = await handwritingService.uploadAndSaveAnalysis(
  userId: userId,
  imageFile: File('/path/to/image.jpg'),
  riskScore: 0.45,
  recommendation: 'Shows some signs...',
);

// Get user's handwriting history
final analyses = await handwritingService.getUserAnalyses(userId);
```

### Using ReportService
```dart
final reportService = ReportService();

// Generate comprehensive report
final reportId = await reportService.generateReport(userId: userId);

// Get latest report
final report = await reportService.getLatestReport(userId);
print(report?.overallFeedback);
```

---

## 🎯 Next Steps

1. ✅ Deploy security rules to Firebase
2. ✅ Set up FastAPI backend with Firebase Admin SDK
3. ✅ Update existing screens to use Firebase services
4. ✅ Test complete flow: Register → IQ Test → Upload → Results
5. ✅ Add logout functionality in Settings screen
6. 🔄 Train and integrate actual ML model
7. 🔄 Add progress tracking and graphs
8. 🔄 Implement HandyBot with chat logs

---

## 🔥 Quick Deploy Commands

```powershell
# Deploy Firestore rules
firebase deploy --only firestore:rules

# Deploy Storage rules
firebase deploy --only storage:rules

# Deploy all rules
firebase deploy --only firestore:rules,storage:rules

# Run Flutter app
flutter run -d windows

# Run FastAPI backend
cd backend
uvicorn main:app --reload
```

---

## 📞 Need Help?

- **Firebase Docs**: https://firebase.google.com/docs
- **FlutterFire**: https://firebase.flutter.dev
- **FastAPI + Firebase**: https://firebase.google.com/docs/admin/setup

---

**🎉 Your Firebase backend is now ready for En-HanZ!**
