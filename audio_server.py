from fastapi import FastAPI, HTTPException
from bark import SAMPLE_RATE, generate_audio
from audiocraft.models import MusicGen
import torch
import torchaudio
import numpy as np
import os
from pydantic import BaseModel
from typing import Optional

app = FastAPI()

# Initialize MusicGen model
try:
    music_model = MusicGen.get_pretrained('facebook/musicgen-small')
    music_model.set_generation_params(duration=8)  # default duration in seconds
except Exception as e:
    print(f"Warning: Could not load MusicGen model: {e}")
    music_model = None

class VoiceRequest(BaseModel):
    text: str
    voice_preset: str = "v2/en_speaker_6"
    output_filename: Optional[str] = None

class MusicRequest(BaseModel):
    prompt: str
    duration: int = 30
    output_filename: Optional[str] = None

@app.post("/generate/voice")
async def generate_voice(request: VoiceRequest):
    try:
        audio_array = generate_audio(request.text, history_prompt=request.voice_preset)
        
        output_filename = request.output_filename or "generated_voice.wav"
        output_path = os.path.join("/output", output_filename)
        
        # Convert to torch tensor and save
        audio_tensor = torch.tensor(audio_array).unsqueeze(0)
        torchaudio.save(output_path, audio_tensor, SAMPLE_RATE)
        
        return {
            "status": "success",
            "file_path": output_path,
            "duration": len(audio_array) / SAMPLE_RATE
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Voice generation failed: {str(e)}")

@app.post("/generate/music")
async def generate_music(request: MusicRequest):
    if music_model is None:
        raise HTTPException(status_code=500, detail="MusicGen model not available")
    
    try:
        # Set duration for generation
        music_model.set_generation_params(duration=request.duration)
        
        # Generate music
        output = music_model.generate([request.prompt], progress=True)
        
        # Convert to audio array
        audio_array = output.cpu().numpy().squeeze()
        
        output_filename = request.output_filename or "generated_music.wav"
        output_path = os.path.join("/output", output_filename)
        
        # Save audio file
        torchaudio.save(
            output_path,
            torch.tensor(audio_array).unsqueeze(0),
            sample_rate=32000  # MusicGen's sample rate
        )
        
        return {
            "status": "success",
            "file_path": output_path,
            "duration": request.duration
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Music generation failed: {str(e)}")

@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "models": {
            "bark": "loaded",
            "musicgen": "loaded" if music_model is not None else "not_loaded"
        }
    }
