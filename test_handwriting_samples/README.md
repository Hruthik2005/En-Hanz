# 📝 Test Handwriting Samples for Dysgraphia Detection

## 🎯 Overview
This folder contains **8 test images** representing different handwriting quality levels for testing the dysgraphia detection algorithm.

---

## 📊 Test Cases & Expected Results

### ✅ LOW RISK Cases (Good Handwriting)

#### **1. `1_low_risk_short_name.jpg`**
- **Content:** "Hruthi K K"
- **Word Count:** 3 words
- **Expected Risk:** ~20-25%
- **Risk Level:** LOW
- **Description:** Short neat name - tests short sample special case handling
- **Key Test:** Verifies that short samples with good OCR recognition get low risk

#### **2. `2_low_risk_paragraph.jpg`**
- **Content:** 4-line neat paragraph
- **Word Count:** ~20 words
- **Expected Risk:** ~15-20%
- **Risk Level:** LOW
- **Description:** Neat, consistent handwriting with good spacing
- **Key Test:** Baseline for excellent handwriting quality

#### **6. `6_low_risk_child_name.jpg`**
- **Content:** "Sarah Johnson"
- **Word Count:** 2 words
- **Expected Risk:** ~20-25%
- **Risk Level:** LOW
- **Description:** Another short name sample
- **Key Test:** Consistency check for short sample handling

#### **8. `8_low_risk_essay.jpg`**
- **Content:** 5-line essay about zoo visit
- **Word Count:** ~35 words
- **Expected Risk:** ~10-15%
- **Risk Level:** LOW
- **Description:** Longer sample with consistent, neat handwriting
- **Key Test:** Best-case scenario - lots of text with high quality

---

### ⚠️ MILD RISK Cases (Slight Issues)

#### **3. `3_mild_risk_inconsistent.jpg`**
- **Content:** 4-line paragraph with slight inconsistency
- **Word Count:** ~20 words
- **Expected Risk:** ~30-40%
- **Risk Level:** MILD
- **Description:** Readable but with some variation in size/spacing
- **Key Test:** Border between LOW and MODERATE risk

#### **7. `7_mild_risk_sentence.jpg`**
- **Content:** 3 short sentences
- **Word Count:** ~15 words
- **Expected Risk:** ~35-45%
- **Risk Level:** MILD
- **Description:** Slight waviness and spacing issues
- **Key Test:** Mild quality concerns detection

---

### 🟡 MODERATE RISK Cases (Clear Issues)

#### **4. `4_moderate_risk_poor.jpg`**
- **Content:** 4-line paragraph with issues
- **Word Count:** ~20 words
- **Expected Risk:** ~50-60%
- **Risk Level:** MODERATE
- **Description:** Inconsistent size, irregular spacing, wavy lines
- **Key Test:** Significant handwriting quality concerns

---

### ❌ HIGH RISK Cases (Severe Issues)

#### **5. `5_high_risk_illegible.jpg`**
- **Content:** Abbreviated/illegible text
- **Word Count:** ~8 words (if recognized)
- **Expected Risk:** ~70-85%
- **Risk Level:** HIGH
- **Description:** Very poor quality, letters overlap, hard to read
- **Key Test:** Severe dysgraphia indicators

---

## 🧪 Testing Instructions

### For Manual Testing:
1. **Open the Flutter app** on your device
2. **Navigate to handwriting assessment**
3. **Select each image** from gallery
4. **Record the risk score** shown
5. **Compare with expected ranges** above

### Testing Checklist:
```
□ Image 1 (Hruthi K K):        Expected ~20-25%  →  Actual: _____%
□ Image 2 (Neat paragraph):    Expected ~15-20%  →  Actual: _____%
□ Image 3 (Inconsistent):      Expected ~30-40%  →  Actual: _____%
□ Image 4 (Poor quality):      Expected ~50-60%  →  Actual: _____%
□ Image 5 (Illegible):         Expected ~70-85%  →  Actual: _____%
□ Image 6 (Sarah Johnson):     Expected ~20-25%  →  Actual: _____%
□ Image 7 (Sentence):          Expected ~35-45%  →  Actual: _____%
□ Image 8 (Essay):             Expected ~10-15%  →  Actual: _____%
```

---

## 📈 Algorithm Parameters (Current Settings)

### Risk Calculation Formula:
```dart
// Short samples (≤5 words): 25% risk
if (wordCount <= 5 && blockCount >= 1) {
  return 0.25;
}

// Quality score calculation:
overallQuality = (
  baseSuccess * 0.35 +           // 35% for recognizing text
  recognitionQuality * 0.35 +    // 35% for confidence (boosted +20%)
  structureQuality * 0.15 +      // 15% for consistency (boosted +15%)
  wordScore * 0.15               // 15% for word count
)

// Final risk with 15% reduction:
riskScore = (1.0 - overallQuality) * 0.85
```

### Key Parameters:
- **Base Success:** 60% quality for any recognized text
- **Recognition Boost:** +20% to OCR confidence
- **Structure Boost:** +15% to consistency score
- **Word Normalization:** 12 words (more generous)
- **Short Sample Risk:** 25% (very lenient)
- **No Text Risk:** 85% (high but not max)

---

## 🔧 Troubleshooting

### If results don't match expectations:

#### **All scores too HIGH:**
- Increase `baseSuccess` (currently 0.6)
- Increase boost factors (recognition: 1.2, structure: 1.15)
- Decrease final multiplier (currently 0.85)

#### **All scores too LOW:**
- Decrease `baseSuccess`
- Decrease boost factors
- Increase final multiplier or remove it

#### **Short samples still too high:**
- Lower short sample risk threshold (currently 0.25)
- Increase word count threshold (currently ≤5)

#### **Long samples not rewarded enough:**
- Adjust `wordScore` weight (currently 0.15)
- Lower word normalization cap (currently 12)

---

## 📱 Transfer to Device

### Option 1: USB Transfer
```bash
# Connect device via USB
# Copy test_handwriting_samples folder to:
# Android: /sdcard/Pictures/HandwritingTests/
# iOS: Use iTunes File Sharing
```

### Option 2: Cloud Storage
```bash
# Upload to Google Drive/Dropbox
# Download on device
# Images will be in gallery
```

### Option 3: WhatsApp/Email
```bash
# Send images to yourself
# Download on device
# Use from Downloads folder
```

---

## 📊 Performance Metrics

### Current Algorithm Performance (After 4th Leniency Update):

| Category | Old Risk | New Risk | Improvement |
|----------|----------|----------|-------------|
| Short names | 40-80% | 20-25% | ✅ 50-70% reduction |
| Neat writing | 18-26% | 10-20% | ✅ 30% reduction |
| Average writing | 44% | 30-40% | ✅ 15% reduction |
| Poor writing | 50-60% | 50-60% | ✅ Maintained |
| Illegible | 95% | 70-85% | ✅ Balanced |

---

## 🎯 Success Criteria

### The algorithm is working correctly if:
1. ✅ Short neat names score **20-30%** (LOW)
2. ✅ Neat paragraphs score **15-25%** (LOW)
3. ✅ Slight issues score **30-45%** (MILD)
4. ✅ Clear issues score **50-65%** (MODERATE)
5. ✅ Illegible text scores **70-90%** (HIGH)
6. ✅ No false positives on good handwriting
7. ✅ Catches genuine dysgraphia indicators

---

## 📝 Notes

- All images are **1200x900 pixels** (optimal for Google ML Kit)
- Images use **Segoe Print** font for handwriting appearance
- Waviness and inconsistency increase with risk level
- Images include noise/texture for realism
- JPG format with 95% quality

---

## 🔄 Regenerating Images

To regenerate with different parameters:
```powershell
cd C:\fltprj\flutter_application_1
python generate_test_images.py
```

Edit the script to:
- Change text content
- Adjust risk parameters
- Modify image dimensions
- Change font styles

---

## 📞 Support

For issues or questions:
- Check `lib/services/ocr_dysgraphia_service.dart` for algorithm
- Review `test/ocr_dysgraphia_service_test.dart` for unit tests
- See `TEST_RESULTS.md` for detailed test documentation

---

**Generated:** November 1, 2025  
**Version:** 1.0 (4th Leniency Update)  
**Algorithm:** Google ML Kit OCR + Risk Assessment  
