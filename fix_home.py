import re
import sys

filepath = '/Users/izaanjs/.gemini/antigravity/scratch/TajwidCoach/lib/screens/home_screen.dart'

with open(filepath, 'r', encoding='utf-8') as f:
    lines = f.readlines()

# Find and remove line 763 (0-indexed: 762) which contains the broken text
# Also remove the extra '],\n' on line 764 (0-indexed: 763)
new_lines = []
skip_next = False
for i, line in enumerate(lines):
    # Line 763 (1-indexed) = index 762
    if i == 762:
        # This is the broken line with literal \n chars — skip it
        continue
    if i == 763:
        # This is the extra '],\n' — skip it 
        continue
    new_lines.append(line)

with open(filepath, 'w', encoding='utf-8') as f:
    f.writelines(new_lines)

print(f"Fixed! Removed 2 broken lines. Total lines: {len(lines)} -> {len(new_lines)}")
