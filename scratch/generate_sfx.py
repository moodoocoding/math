import wave
import math
import struct
import os

def generate_tone(file_path, frequencies, durations, volume=0.5, wave_type='sine'):
    sample_rate = 44100.0
    
    with wave.open(file_path, 'w') as wav_file:
        wav_file.setnchannels(1) # mono
        wav_file.setsampwidth(2) # 2 bytes per sample
        wav_file.setframerate(sample_rate)
        
        for freq, duration in zip(frequencies, durations):
            num_samples = int(duration * sample_rate)
            for i in range(num_samples):
                t = float(i) / sample_rate
                
                # Decay envelope
                envelope = math.exp(-3.0 * t / duration)
                
                if wave_type == 'sine':
                    value = math.sin(2.0 * math.pi * freq * t)
                elif wave_type == 'square':
                    value = 1.0 if math.sin(2.0 * math.pi * freq * t) > 0 else -1.0
                elif wave_type == 'triangle':
                    value = 2.0 * abs(2.0 * (t * freq - math.floor(t * freq + 0.5))) - 1.0
                else:
                    value = 0.0
                    
                # Apply volume and envelope
                sample = int(value * envelope * volume * 32767.0)
                
                # Clip to 16-bit
                sample = max(-32768, min(32767, sample))
                wav_file.writeframesraw(struct.pack('<h', sample))

# Create audio directory if it doesn't exist
audio_dir = r'c:\Users\panth\Documents\vibecoding\260420_math\flutter_application_1\assets\audio'
os.makedirs(audio_dir, exist_ok=True)

# 1. Click Sound (Short pop)
generate_tone(os.path.join(audio_dir, 'click.wav'), [800], [0.05], volume=0.3, wave_type='sine')

# 2. Correct Sound (Happy chime: C5 - E5 - G5 - C6)
generate_tone(os.path.join(audio_dir, 'correct.wav'), 
              [523.25, 659.25, 783.99, 1046.50], 
              [0.1, 0.1, 0.1, 0.4], 
              volume=0.4, wave_type='sine')

# 3. Wrong Sound (Dull bloop: F4 - C4)
generate_tone(os.path.join(audio_dir, 'wrong.wav'), 
              [349.23, 261.63], 
              [0.2, 0.3], 
              volume=0.4, wave_type='triangle')

print("Generated SFX files successfully.")
