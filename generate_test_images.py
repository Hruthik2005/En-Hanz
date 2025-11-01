"""
Generate test handwriting images for dysgraphia detection testing
Creates samples for different risk levels: LOW, MILD, MODERATE, HIGH
"""

from PIL import Image, ImageDraw, ImageFont
import os
import random

# Create output directory
output_dir = "test_handwriting_samples"
os.makedirs(output_dir, exist_ok=True)

def add_noise(draw, width, height, intensity=5):
    """Add slight paper texture/noise"""
    for _ in range(intensity * 100):
        x = random.randint(0, width)
        y = random.randint(0, height)
        color = random.randint(200, 240)
        draw.point((x, y), fill=(color, color, color))

def draw_wavy_line(draw, start_x, start_y, text, font, color, waviness=0):
    """Draw text with variable waviness for inconsistency"""
    x = start_x
    for char in text:
        y_offset = random.randint(-waviness, waviness) if waviness > 0 else 0
        draw.text((x, start_y + y_offset), char, fill=color, font=font)
        # Variable spacing
        spacing = font.getbbox(char)[2] + random.randint(-2, 2) if waviness > 0 else font.getbbox(char)[2]
        x += spacing

def create_handwriting_sample(filename, text, risk_level):
    """
    Create a handwriting sample image
    risk_level: 'low', 'mild', 'moderate', 'high'
    """
    # Image settings
    width, height = 1200, 900
    img = Image.new('RGB', (width, height), color='white')
    draw = ImageDraw.Draw(img)
    
    # Add slight paper texture
    add_noise(draw, width, height, intensity=3)
    
    # Risk level parameters
    params = {
        'low': {
            'font_size': 40,
            'line_spacing': 60,
            'waviness': 0,
            'color': (20, 20, 20),
            'rotation': 0,
            'char_variation': 0
        },
        'mild': {
            'font_size': 38,
            'line_spacing': 65,
            'waviness': 3,
            'color': (30, 30, 30),
            'rotation': 0,
            'char_variation': 2
        },
        'moderate': {
            'font_size': 36,
            'line_spacing': 70,
            'waviness': 8,
            'color': (40, 40, 40),
            'rotation': 0,
            'char_variation': 5
        },
        'high': {
            'font_size': 34,
            'line_spacing': 80,
            'waviness': 15,
            'color': (60, 60, 60),
            'rotation': 0,
            'char_variation': 10
        }
    }
    
    settings = params[risk_level]
    
    # Try to use a handwriting-like font, fallback to default
    try:
        # Try different handwriting fonts
        font_options = [
            "C:\\Windows\\Fonts\\segoepr.ttf",  # Segoe Print
            "C:\\Windows\\Fonts\\KUNSTLER.TTF",  # Kunstler Script
            "C:\\Windows\\Fonts\\ITCBLKAD.TTF",  # Blackadder
            "arial.ttf"  # Fallback
        ]
        font = None
        for font_path in font_options:
            try:
                font = ImageFont.truetype(font_path, settings['font_size'])
                break
            except:
                continue
        if not font:
            font = ImageFont.load_default()
    except:
        font = ImageFont.load_default()
    
    # Split text into lines
    lines = text.split('\n')
    y_position = 100
    
    for line in lines:
        if line.strip():
            # Add waviness based on risk level
            x_start = 100 + random.randint(-settings['char_variation'], settings['char_variation'])
            
            if settings['waviness'] > 0:
                draw_wavy_line(draw, x_start, y_position, line, font, settings['color'], settings['waviness'])
            else:
                draw.text((x_start, y_position), line, fill=settings['color'], font=font)
            
            y_position += settings['line_spacing']
    
    # Add label at bottom
    label_font_size = 20
    try:
        label_font = ImageFont.truetype("arial.ttf", label_font_size)
    except:
        label_font = ImageFont.load_default()
    
    label = f"Sample: {risk_level.upper()} RISK"
    draw.text((50, height - 50), label, fill=(150, 150, 150), font=label_font)
    
    # Save image
    filepath = os.path.join(output_dir, filename)
    img.save(filepath, quality=95)
    print(f"✅ Created: {filepath}")
    return filepath

# Test Case 1: LOW RISK - Short neat name (should be ~20-25% risk)
create_handwriting_sample(
    "1_low_risk_short_name.jpg",
    "Hruthi K K",
    "low"
)

# Test Case 2: LOW RISK - Neat paragraph (should be ~15-20% risk)
create_handwriting_sample(
    "2_low_risk_paragraph.jpg",
    """The quick brown fox jumps over the lazy dog.
This is an example of neat handwriting.
Letters are consistent and well-formed.
Spacing is regular and readable.""",
    "low"
)

# Test Case 3: MILD RISK - Slightly inconsistent (should be ~30-40% risk)
create_handwriting_sample(
    "3_mild_risk_inconsistent.jpg",
    """My handwriting is okay but not perfect.
Sometimes the letters vary in size.
The spacing can be uneven at times.
Overall it's readable though.""",
    "mild"
)

# Test Case 4: MODERATE RISK - Poor consistency (should be ~50-60% risk)
create_handwriting_sample(
    "4_moderate_risk_poor.jpg",
    """This handwriting shows clear issues.
Letters are inconsistent in size.
Spacing is irregular and hard to read.
Lines are wavy and uneven.""",
    "moderate"
)

# Test Case 5: HIGH RISK - Very poor/illegible (should be ~70-85% risk)
create_handwriting_sample(
    "5_high_risk_illegible.jpg",
    """vry poor writng
hrd to red
ltrs overlap
incnsistnt""",
    "high"
)

# Test Case 6: LOW RISK - Child's name (good quality)
create_handwriting_sample(
    "6_low_risk_child_name.jpg",
    "Sarah Johnson",
    "low"
)

# Test Case 7: MILD RISK - Sentence with slight issues
create_handwriting_sample(
    "7_mild_risk_sentence.jpg",
    """I like to play in the park.
My favorite color is blue.
I have a pet dog named Max.""",
    "mild"
)

# Test Case 8: LOW RISK - Good longer sample
create_handwriting_sample(
    "8_low_risk_essay.jpg",
    """Yesterday I went to the zoo with my family.
We saw many animals including elephants, lions,
and monkeys. My favorite was the penguin exhibit.
The penguins were swimming and playing.
It was a wonderful day and I had so much fun.""",
    "low"
)

print("\n" + "="*60)
print("✅ ALL TEST IMAGES GENERATED SUCCESSFULLY!")
print(f"📁 Location: {os.path.abspath(output_dir)}")
print("="*60)
print("\n📊 Expected Results:")
print("-" * 60)
print("1. Short name (LOW):          ~20-25% risk")
print("2. Neat paragraph (LOW):      ~15-20% risk")
print("3. Inconsistent (MILD):       ~30-40% risk")
print("4. Poor quality (MODERATE):   ~50-60% risk")
print("5. Illegible (HIGH):          ~70-85% risk")
print("6. Child name (LOW):          ~20-25% risk")
print("7. Sentence (MILD):           ~35-45% risk")
print("8. Good essay (LOW):          ~10-15% risk")
print("-" * 60)
print("\n🎯 Usage:")
print("1. Copy images from 'test_handwriting_samples' folder")
print("2. Use camera/gallery in app to select these images")
print("3. Compare actual risk scores with expected ranges")
print("4. Adjust algorithm if results don't match expectations")
