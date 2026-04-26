import os
import chardet

def check_encoding(filepath):
    try:
        with open(filepath, 'rb') as f:
            raw = f.read()
            result = chardet.detect(raw)
            return result['encoding'], result['confidence']
    except Exception as e:
        return 'error', str(e)

for root, dirs, files in os.walk('.'):
    dirs[:] = [d for d in dirs if d not in ['build', '.git']]  # build와 .git 제외
    for file in files:
        filepath = os.path.join(root, file)
        encoding, confidence = check_encoding(filepath)
        if encoding and encoding.lower() == 'utf-8':
            print(f"{filepath}: UTF-8 (confidence: {confidence})")
        else:
            print(f"{filepath}: {encoding} (confidence: {confidence})")