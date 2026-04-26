import os

assets_dir = r'c:\Users\panth\Documents\vibecoding\260420_math\flutter_application_1\assets\images'
lib_dir = r'c:\Users\panth\Documents\vibecoding\260420_math\flutter_application_1\lib'

# Get all chr_ images
chr_images = [f for f in os.listdir(assets_dir) if f.startswith('chr_')]

# Read all dart files
dart_files = []
for root, dirs, files in os.walk(lib_dir):
    for file in files:
        if file.endswith('.dart'):
            with open(os.path.join(root, file), 'r', encoding='utf-8') as f:
                dart_files.append(f.read())

used = {}
unused = []

for img in chr_images:
    count = 0
    for content in dart_files:
        count += content.count(img)
    
    if count > 0:
        used[img] = count
    else:
        unused.append(img)

print("--- USED ---")
for img, count in sorted(used.items(), key=lambda x: x[1], reverse=True):
    print(f"{img}: {count}")

print("\n--- UNUSED ---")
for img in sorted(unused):
    print(img)
