# 🔌 Integrating Firebase into Existing Screens

Quick reference guide for updating your existing screens to use Firebase services.

---

## 1. ProfileScreen Integration

### Current Flow
User enters name, age → Saves to local state → Navigates to home

### New Flow
User enters name, age → **Create Firebase user profile** → Navigates to home

### Code Changes

**Add imports:**
```dart
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';
```

**In your save/continue button handler:**
```dart
Future<void> _saveProfileAndContinue() async {
  if (_nameCtrl.text.trim().isEmpty) {
    // Show validation error
    return;
  }

  setState(() => _isLoading = true);

  try {
    final authService = AuthService();
    final userService = UserService();
    final userId = authService.currentUserId!;

    // Check if profile already exists
    final existingUser = await userService.getUser(userId);
    
    if (existingUser == null) {
      // Create new profile
      final user = UserModel(
        userId: userId,
        name: _nameCtrl.text.trim(),
        age: int.parse(_ageCtrl.text),
        gender: _selectedGender,
        disabilityType: _selectedDisability,
        createdAt: DateTime.now(),
      );
      
      await userService.createUser(user);
    } else {
      // Update existing profile
      await userService.updateUser(userId, {
        'name': _nameCtrl.text.trim(),
        'age': int.parse(_ageCtrl.text),
        'gender': _selectedGender,
        'disability_type': _selectedDisability,
      });
    }

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}
```

---

## 2. IQTestScreen Integration

### Current Flow
User completes test → Calculate score → Show results

### New Flow
User completes test → Calculate score → **Save to Firestore** → Show results

### Code Changes

**Add imports:**
```dart
import '../services/auth_service.dart';
import '../services/iq_service.dart';
```

**After calculating test score:**
```dart
Future<void> _submitTest() async {
  // Your existing score calculation
  int totalScore = _calculateTotalScore();
  
  setState(() => _isLoading = true);

  try {
    final iqService = IQService();
    final authService = AuthService();
    final userId = authService.currentUserId!;

    // Get user age (you might need to fetch from UserService)
    final userService = UserService();
    final user = await userService.getUser(userId);
    
    if (user != null) {
      // Save IQ result
      final resultId = await iqService.calculateAndSaveIQ(
        userId: userId,
        totalScore: totalScore,
        userAge: user.age,
        totalQuestions: 20, // Adjust based on your test
      );

      debugPrint('✅ IQ result saved: $resultId');

      if (mounted) {
        // Navigate to results with the result ID
        Navigator.pushReplacementNamed(
          context,
          '/results',
          arguments: {'iq_result_id': resultId},
        );
      }
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving test result: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}
```

---

## 3. UploadScreen Integration

### Current Flow
User selects image → Display preview → Navigate to processing

### New Flow
User selects image → Display preview → **Upload to Storage** → **Call FastAPI** → Save analysis → Navigate to results

### Code Changes

**Add imports:**
```dart
import 'dart:io';
import '../services/auth_service.dart';
import '../services/handwriting_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
```

**After image selection:**
```dart
Future<void> _uploadAndAnalyze() async {
  if (_selectedImage == null) return;

  setState(() => _isLoading = true);

  try {
    final handwritingService = HandwritingService();
    final authService = AuthService();
    final userId = authService.currentUserId!;

    // Step 1: Upload image to Firebase Storage
    final imageUrl = await handwritingService.uploadHandwritingImage(
      userId: userId,
      imageFile: File(_selectedImage!.path),
    );

    debugPrint('✅ Image uploaded: $imageUrl');

    // Step 2: Send image URL to FastAPI for ML analysis
    final response = await http.post(
      Uri.parse('http://localhost:8000/api/analyze-handwriting'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'image_url': imageUrl,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final riskScore = data['risk_score'] as double;
      final recommendation = data['recommendation'] as String;

      // Step 3: Save analysis result to Firestore
      final analysisId = await handwritingService.saveAnalysisResult(
        HandwritingAnalysisModel(
          userId: userId,
          imageUrl: imageUrl,
          riskScore: riskScore,
          recommendation: recommendation,
          analyzedAt: DateTime.now(),
        ),
      );

      debugPrint('✅ Analysis saved: $analysisId');

      if (mounted) {
        // Navigate to results with analysis ID
        Navigator.pushReplacementNamed(
          context,
          '/results',
          arguments: {'handwriting_id': analysisId},
        );
      }
    } else {
      throw Exception('FastAPI analysis failed: ${response.statusCode}');
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error analyzing handwriting: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}
```

**Note:** Add `http: ^1.2.0` to `pubspec.yaml` for HTTP requests.

---

## 4. ResultsScreen Integration

### Current Flow
Show mock results

### New Flow
**Fetch real data from Firestore** → Display IQ + handwriting analysis → **Generate comprehensive report**

### Code Changes

**Add imports:**
```dart
import '../services/auth_service.dart';
import '../services/report_service.dart';
import '../models/report_model.dart';
```

**Load data on screen init:**
```dart
class _ResultsScreenState extends State<ResultsScreen> {
  bool _isLoading = true;
  ReportModel? _report;

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    setState(() => _isLoading = true);

    try {
      final reportService = ReportService();
      final authService = AuthService();
      final userId = authService.currentUserId!;

      // Generate report combining latest IQ + handwriting
      final reportId = await reportService.generateReport(userId: userId);
      
      // Fetch the generated report
      final report = await reportService.getReport(reportId);
      
      setState(() {
        _report = report;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Error loading results: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading results: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_report == null) {
      return Scaffold(
        body: Center(
          child: Text('No results available'),
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          // Display risk level
          Text('Risk Level: ${_report!.overallRiskLabel}'),
          
          // Display feedback
          Text(_report!.overallFeedback),
          
          // Add your UI components here
        ],
      ),
    );
  }
}
```

---

## 5. HistoryScreen Integration

### Current Flow
Show empty or mock history

### New Flow
**Fetch all past IQ tests and handwriting analyses** → Display in list

### Code Changes

**Add imports:**
```dart
import '../services/auth_service.dart';
import '../services/iq_service.dart';
import '../services/handwriting_service.dart';
import '../models/iq_result_model.dart';
import '../models/handwriting_analysis_model.dart';
```

**Use StreamBuilder for real-time updates:**
```dart
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final userId = authService.currentUserId!;
    final iqService = IQService();
    final handwritingService = HandwritingService();

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // IQ Test History
            Text('IQ Test History', style: TextStyle(fontSize: 20)),
            StreamBuilder<List<IQResultModel>>(
              stream: iqService.streamUserIQResults(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('No IQ tests yet');
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final result = snapshot.data![index];
                    return ListTile(
                      title: Text('IQ: ${result.iqValue.toStringAsFixed(1)}'),
                      subtitle: Text('Date: ${result.testDate}'),
                      trailing: Icon(Icons.arrow_forward),
                    );
                  },
                );
              },
            ),

            SizedBox(height: 20),

            // Handwriting Analysis History
            Text('Handwriting Analysis History', style: TextStyle(fontSize: 20)),
            StreamBuilder<List<HandwritingAnalysisModel>>(
              stream: handwritingService.streamUserAnalyses(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('No analyses yet');
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final analysis = snapshot.data![index];
                    return ListTile(
                      title: Text('Risk: ${analysis.riskLabel}'),
                      subtitle: Text('Date: ${analysis.analyzedAt}'),
                      leading: Image.network(
                        analysis.imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                      trailing: Icon(Icons.arrow_forward),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 6. HomeScreen Integration (Optional)

### Show User Greeting

**Add at the top of HomeScreen:**
```dart
import '../services/auth_service.dart';
import '../services/user_service.dart';

// In build method:
StreamBuilder<UserModel?>(
  stream: UserService().streamUser(AuthService().currentUserId!),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      return Text('Welcome, ${snapshot.data!.name}!');
    }
    return Text('Welcome!');
  },
);
```

---

## 🚀 Quick Integration Checklist

### ProfileScreen
- [ ] Import AuthService, UserService, UserModel
- [ ] On save, call `userService.createUser()` or `updateUser()`
- [ ] Add loading state

### IQTestScreen
- [ ] Import AuthService, IQService
- [ ] After test, call `iqService.calculateAndSaveIQ()`
- [ ] Pass result ID to ResultsScreen

### UploadScreen
- [ ] Import AuthService, HandwritingService
- [ ] Upload image with `handwritingService.uploadHandwritingImage()`
- [ ] Call FastAPI for analysis
- [ ] Save analysis with `handwritingService.saveAnalysisResult()`
- [ ] Add `http` package to pubspec.yaml

### ResultsScreen
- [ ] Import ReportService
- [ ] Generate report with `reportService.generateReport()`
- [ ] Display report data

### HistoryScreen
- [ ] Import IQService, HandwritingService
- [ ] Use StreamBuilder with `streamUserIQResults()` and `streamUserAnalyses()`
- [ ] Display lists of past results

---

## 💡 Common Patterns

### Loading State
```dart
bool _isLoading = false;

// Before async operation
setState(() => _isLoading = true);

// In finally block
setState(() => _isLoading = false);
```

### Error Handling
```dart
try {
  await someService.doSomething();
} catch (e) {
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}
```

### Real-time Updates
```dart
StreamBuilder<DataModel>(
  stream: service.streamData(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();
    }
    
    if (!snapshot.hasData) {
      return Text('No data');
    }
    
    return Text(snapshot.data!.someField);
  },
);
```

---

## 🎯 Testing Steps

1. **Register** → Check Firestore users collection
2. **Complete IQ test** → Check iq_results collection
3. **Upload handwriting** → Check Storage + handwriting_analysis collection
4. **View results** → Check reports collection
5. **View history** → Should show all past results
6. **Logout & login again** → Data should persist

---

## 📞 Need Help?

- Check `FIREBASE_IMPLEMENTATION_SUMMARY.md` for service details
- Check `FIREBASE_SETUP.md` for deployment instructions
- Use `debugPrint()` to trace data flow
- Check Firebase Console to verify data is being saved

---

**🎉 Ready to integrate! Start with ProfileScreen and work your way through.**
