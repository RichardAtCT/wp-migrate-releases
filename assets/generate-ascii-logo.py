#!/usr/bin/env python3
"""Generate ASCII art logo as PNG image."""

from PIL import Image, ImageDraw, ImageFont
import os

# ASCII art text
ASCII_ART = """  __        ______        __  __ _                 _
  \\ \\      / /  _ \\      |  \\/  (_) __ _ _ __ __ _| |_ ___
   \\ \\ /\\ / /| |_) |_____| |\\/| | |/ _` | '__/ _` | __/ _ \\
    \\ V  V / |  __/______| |  | | | (_| | | | (_| | ||  __/
     \\_/\\_/  |_|         |_|  |_|_|\\__, |_|  \\__,_|\\__\\___|
                                   |___/                   """

def generate_logo():
    # Try to use JetBrains Mono, fall back to system monospace
    font_paths = [
        "/System/Library/Fonts/Monaco.dfont",
        "/System/Library/Fonts/Menlo.ttc",
        "/System/Library/Fonts/Courier.dfont",
        "/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf",
    ]

    font = None
    font_size = 24

    for path in font_paths:
        if os.path.exists(path):
            try:
                font = ImageFont.truetype(path, font_size)
                print(f"Using font: {path}")
                break
            except:
                continue

    if font is None:
        font = ImageFont.load_default()
        print("Using default font")

    # Calculate image size
    lines = ASCII_ART.split('\n')
    max_width = max(len(line) for line in lines)

    # Create image with padding
    char_width = font_size * 0.6  # Approximate monospace width
    char_height = font_size * 1.2

    img_width = int(max_width * char_width) + 40
    img_height = int(len(lines) * char_height) + 40

    # Create transparent image
    img = Image.new('RGBA', (img_width, img_height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Draw text in cyan color
    cyan = (0, 255, 159, 255)  # #00ff9f

    y = 20
    for line in lines:
        draw.text((20, y), line, font=font, fill=cyan)
        y += int(char_height)

    # Save
    output_path = os.path.join(os.path.dirname(__file__), 'ascii-logo.png')
    img.save(output_path, 'PNG')
    print(f"Saved to: {output_path}")

    # Also create a 2x version for retina
    img_2x = img.resize((img_width * 2, img_height * 2), Image.LANCZOS)
    output_path_2x = os.path.join(os.path.dirname(__file__), 'ascii-logo@2x.png')
    img_2x.save(output_path_2x, 'PNG')
    print(f"Saved 2x to: {output_path_2x}")

if __name__ == '__main__':
    generate_logo()
