# 📱 Mobile Testing Guide for En-HanZ

Quick reference for testing Firebase features on your Android device.

---

## ✅ Testing Checklist

### 1. **App Launch**
- [ ] App opens successfully
- [ ] Splash screen displays with modern blue gradient
- [ ] Shows Login screen (not Home) since no user is logged in

### 2. **Registration Flow**
- [ ] Tap "Register" button
- [ ] Fill in all fields:
  - Child Name: "Mobile Test User"
  - Age: 10
  - Gender: Select any
  - Known Condition: Select any or None
  - Email: "mobiletest@example.com"
  - Password: "test123456"
  - Confirm Password: "test123456"
- [ ] Tap "Create Account"
- [ ] Should show success message and navigate
- [ ] **Check Firebase Console** → Authentication → Should see new user

### 3. **Profile Creation**
- [ ] After registration, should show profile screen or home
- [ ] If profile screen: Enter name and age, tap Continue
- [ ] **Check Firestore** → `users` collection → Should see profile document

### 4. **Login Test**
- [ ] Tap "Logout" from Settings (if logged in)
- [ ] Enter email: "mobiletest@example.com"
- [ ] Enter password: "test123456"
- [ ] Tap "Login"
- [ ] Should navigate to Home screen
- [ ] Top should show greeting with user name

### 5. **Home Screen Navigation**
- [ ] All action cards should display:
  - New Test (Blue to Cyan)
  - View Report (Cyan to Green)
  - Practice (Amber to Orange)
  - History (Blue to Purple)
  - HandyBot (Purple)
  - Settings (Gray)
  - About (Cyan to Blue)
- [ ] Tap each card to ensure navigation works

### 6. **IQ Test**
- [ ] Tap "New Test" from Home
- [ ] Complete the IQ test questions
- [ ] Submit test
- [ ] **Expected**: Should save to Firestore `iq_results` collection
- [ ] **Check**: Firebase Console → Firestore → `iq_results`

### 7. **Handwriting Upload**
- [ ] Navigate to Upload screen
- [ ] Tap "Select Image" or camera button
- [ ] Choose/capture handwriting sample
- [ ] Preview should display
- [ ] Tap "Analyze" or "Upload"
- [ ] **Expected**: Image uploads to Firebase Storage
- [ ] **Check**: Firebase Console → Storage → `handwriting_uploads/`

### 8. **Results Screen**
- [ ] After completing IQ test or handwriting upload
- [ ] Navigate to "View Report"
- [ ] Should display:
  - IQ Score (if IQ test completed)
  - Risk Level (if handwriting uploaded)
  - Recommendations
  - Overall feedback

### 9. **History Screen**
- [ ] Tap "History" from Home
- [ ] Should show list of past:
  - IQ test results with dates
  - Handwriting analyses with images
- [ ] Empty state if no history yet

### 10. **Practice Games**
- [ ] Tap "Practice" from Home
- [ ] Should show 3 game options:
  - Letter Tracing
  - Dot Join
  - Copy Word
- [ ] Try each game to ensure they work

### 11. **HandyBot Chat**
- [ ] Tap "HandyBot" from Home
- [ ] Chat interface should load
- [ ] Type a message
- [ ] Bot should respond

### 12. **Settings**
- [ ] Tap "Settings" from Home
- [ ] Should display:
  - Language selection
  - Voice toggle
  - Notifications toggle
  - Logout button (NEW!)
  - Clear Data button
- [ ] Test logout:
  - Tap "Logout"
  - Confirm logout
  - Should return to Login screen

### 13. **Logout & Re-login**
- [ ] Logout from Settings
- [ ] Close app completely
- [ ] Reopen app
- [ ] Should show Login screen (not Home)
- [ ] Login again
- [ ] Should navigate to Home
- [ ] All data should persist

---

## 🔍 What to Check in Firebase Console

### Authentication Tab
```
Users → Should see:
- Email: mobiletest@example.com
- UID: abc123xyz...
- Created: [timestamp]
```

### Firestore Tab
```
users/
  └── {user_id}
       ├── user_id: "abc123..."
       ├── name: "Mobile Test User"
       ├── age: 10
       └── created_at: [timestamp]

iq_results/ (if IQ test completed)
  └── {result_id}
       ├── user_id: "abc123..."
       ├── total_score: 15
       ├── iq_value: 135.0
       └── test_date: [timestamp]

handwriting_analysis/ (if image uploaded)
  └── {analysis_id}
       ├── user_id: "abc123..."
       ├── image_url: "https://..."
       ├── risk_score: 0.45
       └── analyzed_at: [timestamp]
```

### Storage Tab
```
handwriting_uploads/
  └── {user_id}/
       └── {user_id}_1730xxx.jpg
```

---

## 🐛 Common Issues & Fixes

### Issue: "Permission Denied" errors
**Fix**: Make sure Firebase security rules are deployed
```powershell
firebase deploy --only firestore:rules,storage:rules
```

### Issue: Can't upload images
**Fix**: 
1. Check image size < 10MB
2. Verify Storage is enabled in Firebase Console
3. Check Storage rules are deployed

### Issue: Login/Register not working
**Fix**:
1. Enable Authentication in Firebase Console
2. Enable Email/Password sign-in method
3. Check internet connection

### Issue: Data not showing in History
**Fix**:
1. Complete at least one IQ test or handwriting upload
2. Check Firestore has data in collections
3. Verify user is logged in

### Issue: App crashes on startup
**Fix**:
1. Check Firebase is initialized properly in main.dart
2. Verify firebase_options.dart exists
3. Run `flutter clean` and `flutter pub get`

---

## 📊 Performance Checks

### App Should:
- [ ] Open in < 3 seconds
- [ ] Smooth scrolling on all screens
- [ ] No lag when typing in text fields
- [ ] Image upload shows progress indicator
- [ ] Buttons respond immediately on tap
- [ ] Navigation transitions are smooth

### Memory:
- [ ] App doesn't crash during long usage
- [ ] Images don't cause memory issues
- [ ] No memory leaks (controllers disposed properly)

---

## 🎯 Critical Features to Test

### Must Work:
1. ✅ Register new account
2. ✅ Login with credentials
3. ✅ Logout from Settings
4. ✅ Data persists after logout/login
5. ✅ IQ test saves to Firestore
6. ✅ Image uploads to Storage

### Should Work:
1. ⚠️ Handwriting analysis (requires FastAPI backend)
2. ⚠️ Report generation (requires IQ + handwriting data)
3. ⚠️ History displays past data
4. ⚠️ Real-time updates across screens

---

## 🚀 Quick Test Script

**5-Minute Test:**
1. Register → Login (2 min)
2. Complete IQ test → Check Firestore (2 min)
3. Upload image → Check Storage (1 min)
4. Logout → Login → Verify data persists (1 min)

**Full Test:**
1. Registration & Profile (5 min)
2. IQ Test (5 min)
3. Handwriting Upload (3 min)
4. View Results (2 min)
5. Practice Games (5 min)
6. History Screen (2 min)
7. Settings & Logout (3 min)
**Total: ~25 minutes**

---

## 📱 Device-Specific Checks

### For Android:
- [ ] Permissions granted (Storage, Camera)
- [ ] Back button works on all screens
- [ ] Status bar shows properly
- [ ] Keyboard doesn't overlap input fields
- [ ] App works in portrait and landscape

### Network:
- [ ] Test on WiFi
- [ ] Test on mobile data
- [ ] Test offline behavior (should show error messages)

---

## ✅ Success Criteria

Your Firebase backend is working if:
1. ✅ Users can register and login
2. ✅ Profile data saves to Firestore `users` collection
3. ✅ IQ test results save to `iq_results` collection
4. ✅ Images upload to Storage `handwriting_uploads/` folder
5. ✅ Logout works and redirects to login
6. ✅ Data persists after app restart

---

## 📝 Notes

- **First login**: May take a few seconds to fetch data
- **Image upload**: Shows progress indicator during upload
- **Offline**: App will cache data and sync when online
- **Security**: Each user can only see their own data

---

## 🎉 What to Celebrate

When all tests pass, you have:
- ✅ Production-ready authentication system
- ✅ Secure cloud database with user data
- ✅ Image storage and retrieval
- ✅ Real-time data synchronization
- ✅ Complete user history tracking

---

**Happy Testing! 🚀**

Check Firebase Console as you test to see data being created in real-time!
