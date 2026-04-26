import os
import re

assets_dir = r'c:\Users\panth\Documents\vibecoding\260420_math\flutter_application_1\assets\images'
lib_dir = r'c:\Users\panth\Documents\vibecoding\260420_math\flutter_application_1\lib'

chr_images = [f for f in os.listdir(assets_dir) if f.startswith('chr_')]

dart_files = {}
for root, dirs, files in os.walk(lib_dir):
    for file in files:
        if file.endswith('.dart'):
            with open(os.path.join(root, file), 'r', encoding='utf-8') as f:
                dart_files[file] = f.read()

used = {}
unused = []

for img in chr_images:
    locations = []
    for file, content in dart_files.items():
        if img in content:
            # count occurrences
            count = content.count(img)
            locations.append(f"{file} ({count}회)")
    
    if locations:
        used[img] = locations
    else:
        unused.append(img)

with open(r'c:\Users\panth\Documents\vibecoding\260420_math\flutter_application_1\scratch\usage_table.md', 'w', encoding='utf-8') as f:
    f.write("## 사용 현황 (USED)\n\n")
    f.write("|번호|이미지 에셋|사용 위치|\n")
    f.write("|---:|---|---|\n")
    idx = 1
    for img, locs in sorted(used.items(), key=lambda x: len(x[1]), reverse=True):
        f.write(f"|{idx}|assets/images/{img}|{', '.join(locs)}|\n")
        idx += 1
    
    f.write("\n## 미사용 에셋 (UNUSED)\n\n")
    for img in sorted(unused):
        f.write(f"- `{img}`\n")
