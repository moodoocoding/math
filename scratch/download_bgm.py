import urllib.request
import os

audio_dir = r'c:\Users\panth\Documents\vibecoding\260420_math\flutter_application_1\assets\audio'

# Target filenames matching existing system
targets = {
    'bgm_main.mp3': 'https://upload.wikimedia.org/wikipedia/commons/e/eb/Kevin_MacLeod_-_Carefree.mp3',
    'bgm_bg.mp3': 'https://upload.wikimedia.org/wikipedia/commons/e/e0/Kevin_MacLeod_-_Monkeys_Spinning_Monkeys.mp3',
    'bgm_problem.mp3': 'https://upload.wikimedia.org/wikipedia/commons/7/70/Kevin_MacLeod_-_Cipher.mp3'
}

def download_file(url, filename):
    path = os.path.join(audio_dir, filename)
    print(f"Downloading {url} to {path}...")
    try:
        # Using a User-Agent header to avoid 403 Forbidden from some servers
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req) as response, open(path, 'wb') as out_file:
            data = response.read()
            out_file.write(data)
        print(f"Successfully downloaded {filename}")
    except Exception as e:
        print(f"Error downloading {filename}: {e}")

for filename, url in targets.items():
    download_file(url, filename)
