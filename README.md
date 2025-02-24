# AI Video Generation Stack

A complete Docker-based stack for generating AI videos with stable characters, animations, audio narration, and music. This setup integrates ComfyUI, Stable Diffusion, AnimateDiff, Deforum, Flux, and audio processing tools in a unified workflow.

## Architecture Overview

The stack consists of three main services:

1. **Main Generation Container** (ComfyUI + SD + Deforum + Flux)
   - Handles all video generation
   - Runs ComfyUI as the main interface
   - Integrates multiple video generation methods:
     - Basic SD image generation
     - AnimateDiff for simple animations
     - Deforum for complex animations and camera movement
     - Flux for improved animation coherence
   - Accessible via web UI at port 8188

2. **Audio Container**
   - Handles voice generation (Bark)
   - Creates background music
   - Accessible via API at port 8080

3. **Compositor Container**
   - Combines video and audio
   - Generates subtitles
   - Creates final output

## Setup Instructions

1. Clone this repository:
```bash
git clone 
cd 
```

2. Create required directories:
```bash
mkdir -p models/{checkpoints,loras,embeddings,motion,controlnet}
mkdir -p output workflows
```

3. Set up environment:
```bash
cp .env.example .env
# Edit .env with your HF_TOKEN
```

4. Download models:
```bash
chmod +x download_models.sh
./download_models.sh
```

5. Start the stack:
```bash
docker-compose up -d
```

## Video Generation Methods

You can use different approaches for video generation, all through the ComfyUI interface:

1. **AnimateDiff Method**
   - Best for: Simple character animations
   - Access: ComfyUI AnimateDiff nodes
   - Use when: You need basic movement with good coherence

2. **Deforum Method**
   - Best for: Complex animations with camera movement
   - Access: Deforum nodes in ComfyUI
   - Use when: You need camera control and keyframe animation
   - Features:
     - Camera movement
     - Multiple keyframes
     - Animation scheduling
     - Motion control

3. **Flux Method**
   - Best for: Improving animation coherence
   - Access: Flux nodes in ComfyUI
   - Use when: You need smoother transitions and better motion
   - Features:
     - Frame interpolation
     - Motion stability
     - Character consistency

## Workflow Examples

1. Basic Character Animation:
```python
# Access ComfyUI at http://localhost:8188
# Load workflows/basic_character.json
# Modify character prompt and run
```

2. Complex Animation with Deforum:
```python
# Load workflows/deforum_animation.json
# Set keyframes and camera movement
# Adjust animation parameters
```

3. Enhanced Animation with Flux:
```python
# Load workflows/flux_animation.json
# Configure motion settings
# Fine-tune parameters
```

## Adding Audio

1. Generate voice:
```bash
curl -X POST "http://localhost:8080/generate/voice" \
     -H "Content-Type: application/json" \
     -d '{"text": "Your narration here"}'
```

2. Generate music:
```bash
curl -X POST "http://localhost:8080/generate/music" \
     -H "Content-Type: application/json" \
     -d '{"prompt": "Upbeat background music"}'
```

## Final Composition

The compositor service automatically:
1. Detects new videos in output/
2. Adds generated audio
3. Creates subtitles
4. Produces final video

## Port Configuration

- 8188: ComfyUI interface
- 8080: Audio generation API
- 7860: Additional UI components

## Resource Requirements

For vast.ai or similar:
- GPU: NVIDIA with >12GB VRAM
- RAM: 32GB minimum
- Storage: 100GB recommended

## Common Workflows

1. Character Animation:
   - Use AnimateDiff for base animation
   - Enhance with Flux for stability
   - Add voice and music
   
2. Scene Animation:
   - Use Deforum for camera movement
   - Add character animation
   - Apply Flux for smoothing
   
3. Full Production:
   - Generate base video
   - Add voice narration
   - Add background music
   - Generate subtitles
   - Composite final video

## Troubleshooting

1. VRAM Issues:
   - Reduce resolution
   - Lower batch size
   - Use fewer animation frames

2. Animation Coherence:
   - Try different Flux settings
   - Adjust motion scale
   - Use ControlNet for stability

3. Audio Sync:
   - Check frame rate consistency
   - Verify audio duration
   - Adjust composition settings

## Updates and Maintenance

To update:
```bash
git pull
docker-compose build --pull
docker-compose up -d
```
## Storage Requirements and Configuration

### Disk Space Requirements
- Base Models: ~110GB
  - SDXL Base + Refiner: 13GB
  - SD 1.5: 4GB
  - Video Models: 45GB
  - ControlNet Models: 30GB
  - Upscalers: 10GB
  - Additional space for custom models: 50GB recommended
- Working Space: 50GB minimum
- Total Recommended: 250GB minimum

### Storage Configuration
The stack uses persistent storage mounted at `${STORAGE_PATH}` (default: /mnt/r2-deepbrain):
```
${STORAGE_PATH}/
├── models/
│   ├── checkpoints/    # SD models
│   ├── loras/         # Character LoRAs
│   ├── embeddings/    # Textual Inversions
│   ├── motion/        # Animation models
│   ├── controlnet/    # ControlNet models
│   └── upscalers/     # Upscaling models
├── output/           # Generated content
└── workflows/        # Saved workflows
```

### Long-term Storage
- Mount your S3/R2 bucket at `${STORAGE_PATH}`
- All persistent data is stored in this location
- Docker volumes reference this path
- Git repo can be safely reinitialized without data loss

### Security
- Sensitive information is encrypted using git-crypt
- Environment variables are stored in .env (encrypted)
- Secrets directory for additional sensitive files

## Contributing

Feel free to submit issues and pull requests for:
- New workflows
- Model configurations
- Bug fixes
- Feature enhancements

## License

[Your License Here]