#!/usr/bin/env python3
"""Generate Twitter avatar and header for WP-Migrate."""

from PIL import Image, ImageDraw, ImageFont
from pathlib import Path

# Colors from landing page
BG_COLOR = (10, 14, 20)  # #0a0e14
CYAN = (0, 217, 255)  # #00d9ff
WHITE = (226, 232, 240)  # #e2e8f0
DIM = (100, 116, 139)  # #64748b

# Font path
FONT_DIR = Path("/Users/richardatkinson/.claude/plugins/cache/anthropic-agent-skills/example-skills/00756142ab04/skills/canvas-design/canvas-fonts")
MONO_BOLD = FONT_DIR / "JetBrainsMono-Bold.ttf"
MONO_REG = FONT_DIR / "JetBrainsMono-Regular.ttf"

OUTPUT_DIR = Path("/Users/richardatkinson/projects/wp-migrate-releases/assets")


def create_avatar():
    """Create 400x400 Twitter avatar."""
    size = 400
    img = Image.new("RGB", (size, size), BG_COLOR)
    draw = ImageDraw.Draw(img)

    # Load font
    font_large = ImageFont.truetype(str(MONO_BOLD), 160)
    font_small = ImageFont.truetype(str(MONO_BOLD), 56)

    # Draw using anchor for true centering
    center = size // 2

    # Prompt ">" centered horizontally, slightly above center
    draw.text((center, center - 25), ">", font=font_large, fill=CYAN, anchor="mm")

    # "WP" below - closer together
    draw.text((center, center + 55), "WP", font=font_small, fill=WHITE, anchor="mm")

    # Save
    img.save(OUTPUT_DIR / "twitter-avatar.png", "PNG")
    print(f"Created: {OUTPUT_DIR / 'twitter-avatar.png'}")


def create_header():
    """Create 1500x500 Twitter header."""
    width, height = 1500, 500
    img = Image.new("RGB", (width, height), BG_COLOR)
    draw = ImageDraw.Draw(img)

    # Fonts
    font_logo = ImageFont.truetype(str(MONO_BOLD), 72)
    font_tagline = ImageFont.truetype(str(MONO_REG), 28)
    font_prompt = ImageFont.truetype(str(MONO_BOLD), 36)

    # Center point (accounting for profile photo overlap on left)
    # Profile photo takes ~150px on left side, so offset slightly right
    center_x = width // 2 + 50
    center_y = height // 2

    # Draw "WP-" in white, "Migrate" in cyan
    wp_text = "WP-"
    migrate_text = "Migrate"

    # Calculate total width
    bbox_wp = draw.textbbox((0, 0), wp_text, font=font_logo)
    bbox_mig = draw.textbbox((0, 0), migrate_text, font=font_logo)
    wp_width = bbox_wp[2] - bbox_wp[0]
    mig_width = bbox_mig[2] - bbox_mig[0]
    total_width = wp_width + mig_width

    # Starting position
    start_x = center_x - total_width // 2
    logo_y = center_y - 50

    # Draw logo parts
    draw.text((start_x, logo_y), wp_text, font=font_logo, fill=WHITE)
    draw.text((start_x + wp_width, logo_y), migrate_text, font=font_logo, fill=CYAN)

    # Tagline below
    tagline = "WordPress migration without SSH"
    bbox_tag = draw.textbbox((0, 0), tagline, font=font_tagline)
    tag_width = bbox_tag[2] - bbox_tag[0]

    draw.text((center_x - tag_width // 2, logo_y + 85), tagline, font=font_tagline, fill=DIM)

    # Add decorative terminal prompts on sides (subtle)
    prompt = ">"
    # Left side prompts (stacked, dim)
    for i, y_offset in enumerate([120, 180, 240, 300, 360]):
        alpha = 0.3 + (i * 0.1) if i < 3 else 0.5 - ((i - 2) * 0.1)
        color = tuple(int(c * alpha) for c in CYAN)
        draw.text((80 + i * 15, y_offset), prompt, font=font_prompt, fill=color)

    # Right side prompts (mirrored)
    for i, y_offset in enumerate([120, 180, 240, 300, 360]):
        alpha = 0.3 + (i * 0.1) if i < 3 else 0.5 - ((i - 2) * 0.1)
        color = tuple(int(c * alpha) for c in CYAN)
        draw.text((width - 120 - i * 15, y_offset), prompt, font=font_prompt, fill=color)

    # Save
    img.save(OUTPUT_DIR / "twitter-header.png", "PNG")
    print(f"Created: {OUTPUT_DIR / 'twitter-header.png'}")


if __name__ == "__main__":
    OUTPUT_DIR.mkdir(exist_ok=True)
    create_avatar()
    create_header()
    print("\nDone! Upload these to Twitter/X.")
