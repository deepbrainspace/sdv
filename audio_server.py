
from fastapi import FastAPI, File, UploadFile
from bark import SAMPLE_RATE, generate_audio
import torch
import torchaudio
from fastapi.responses import FileResponse
import os

app = FastAPI()

@app.post("/generate/voice")
async def generate_voice(text: str, voice_preset: str = "v2/en_speaker_6"):
    audio_array = generate_audio(text, history_prompt=voice_preset)
    output_path = "/output/generated_voice.wav"
    torchaudio.save(output_path, torch.tensor(audio_array).unsqueeze(0), SAMPLE_RATE)
    return {"file_path": output_path}

@app.post("/generate/music")
async def generate_music(prompt: str, duration: int = 30):
    # Use MusicGen to generate background music
    # Implementation details here
    pass
