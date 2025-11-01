# 🎯 Quick Test Guide

## 8 Test Images - Expected Results

```
┌─────────────────────────────────────────────────────────────┐
│  Image 1: 1_low_risk_short_name.jpg                         │
│  Text: "Hruthi K K"                                         │
│  Expected: 20-25% risk (LOW)                                │
│  ✅ Tests: Short sample handling                            │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  Image 2: 2_low_risk_paragraph.jpg                          │
│  Text: 4 lines neat paragraph                               │
│  Expected: 15-20% risk (LOW)                                │
│  ✅ Tests: Excellent handwriting baseline                   │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  Image 3: 3_mild_risk_inconsistent.jpg                      │
│  Text: 4 lines with slight issues                           │
│  Expected: 30-40% risk (MILD)                               │
│  ⚠️  Tests: Borderline quality detection                    │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  Image 4: 4_moderate_risk_poor.jpg                          │
│  Text: 4 lines poor quality                                 │
│  Expected: 50-60% risk (MODERATE)                           │
│  ⚠️  Tests: Clear handwriting problems                      │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  Image 5: 5_high_risk_illegible.jpg                         │
│  Text: Abbreviated/illegible                                │
│  Expected: 70-85% risk (HIGH)                               │
│  ❌ Tests: Severe dysgraphia detection                      │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  Image 6: 6_low_risk_child_name.jpg                         │
│  Text: "Sarah Johnson"                                      │
│  Expected: 20-25% risk (LOW)                                │
│  ✅ Tests: Consistency of short samples                     │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  Image 7: 7_mild_risk_sentence.jpg                          │
│  Text: 3 sentences with issues                              │
│  Expected: 35-45% risk (MILD)                               │
│  ⚠️  Tests: Mild quality concerns                           │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  Image 8: 8_low_risk_essay.jpg                              │
│  Text: 5 lines essay                                        │
│  Expected: 10-15% risk (LOW)                                │
│  ✅ Tests: Best case - long neat sample                     │
└─────────────────────────────────────────────────────────────┘
```

## 📱 Testing Steps

1. **Hot reload your Flutter app** (or rebuild)
   ```powershell
   flutter run
   # Or press 'r' in terminal
   ```

2. **Transfer images to device**
   - USB: Copy to Pictures folder
   - Cloud: Upload to Drive/Dropbox, download on device
   - Quick: Send via WhatsApp to yourself

3. **Test each image:**
   - Open app → Select child profile
   - Tap "Handwriting Assessment"
   - Choose image from gallery
   - Record risk percentage
   - Compare with expected range

4. **Fill in results:**
   ```
   Image 1: _____%  (Expected: 20-25%)
   Image 2: _____%  (Expected: 15-20%)
   Image 3: _____%  (Expected: 30-40%)
   Image 4: _____%  (Expected: 50-60%)
   Image 5: _____%  (Expected: 70-85%)
   Image 6: _____%  (Expected: 20-25%)
   Image 7: _____%  (Expected: 35-45%)
   Image 8: _____%  (Expected: 10-15%)
   ```

## ✅ Pass Criteria

- **All LOW samples:** < 30% risk
- **All MILD samples:** 30-50% risk
- **MODERATE sample:** 50-70% risk
- **HIGH sample:** > 70% risk
- **No false positives** on good handwriting

## 🔧 If Results Don't Match

### Scores too high?
Edit `lib/services/ocr_dysgraphia_service.dart`:
- Line 183: Increase `baseSuccess` (0.6 → 0.7)
- Line 190: Increase boost (1.2 → 1.3)
- Line 207: Decrease multiplier (0.85 → 0.75)

### Scores too low?
- Decrease `baseSuccess` (0.6 → 0.5)
- Decrease boosts
- Increase or remove multiplier

### Short names still high?
- Line 183: Lower threshold (0.25 → 0.20)
- Line 181: Increase word limit (5 → 7)

## 📍 File Locations

- **Images:** `test_handwriting_samples/`
- **Algorithm:** `lib/services/ocr_dysgraphia_service.dart`
- **Tests:** `test/ocr_dysgraphia_service_test.dart`
- **Docs:** `test_handwriting_samples/README.md`

## 🎯 Key Success Indicator

**"Hruthi K K" should show 20-25% risk, not 40-80%!**

This means the 4th leniency update is working correctly.
