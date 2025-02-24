# Provision.sh
used for provisioning an existing comfyUI container with huggingface models and cloudflare r2 storage.

A AI Video Generation Stack

A comprehensive Docker-based solution for AI video generation, combining state-of-the-art models and tools. This stack integrates:
- Multiple Stable Diffusion models (SD 3.5, SDXL, specialized models)
- Advanced video generation (AnimateDiff, SVD, Deforum)
- Audio generation and synchronization
- Professional-grade enhancements (ControlNet, Frame Interpolation)

All accessible through a unified ComfyUI interface, designed for both beginners and advanced users.

Key Features:
- One-click setup with all required models
- Multiple video generation methods
- Integrated audio processing
- Optimized for different hardware configurations
- Pre-configured workflows for common use cases

## Setup Instructions

### 1. Prerequisites
- Docker and Docker Compose installed
- NVIDIA GPU with appropriate drivers
- Sufficient storage space (see Storage Requirements below)

### 2. Environment Setup
1. Clone the repository:
   ```bash
   git clone https://github.com/your-repo/sdv.git
   cd sdv
   ```

2. Create and configure your .env file:
   ```bash
   cp .env.example .env
   ```

3. Get your Hugging Face token:
   - Go to https://huggingface.co/settings/tokens
   - Click "New token"
   - Select "read" access
   - Copy the token (starts with "hf_")

4. Edit your .env file:
   ```env
   HF_TOKEN=your_huggingface_token_here
   STORAGE_PATH=/path/to/your/storage
   AUDIO_MODEL=facebook/musicgen-small
   ```

### 3. Storage Setup
Create the required storage directories:
```bash
mkdir -p ${STORAGE_PATH}/{models,output,workflows}
mkdir -p ${STORAGE_PATH}/models/{checkpoints,loras,embeddings,motion,controlnet,upscalers}
```

### 4. Running the Stack
1. Download the models:
   ```bash
   ./download-models.sh
   ```

2. Start the services:
   ```bash
   docker-compose up -d
   ```

3. Access the interface:
   - ComfyUI: http://localhost:8188
   - Model Manager: http://localhost:8189

### 5. Troubleshooting
- If model downloads fail, check your HF_TOKEN
- For CUDA errors, ensure NVIDIA drivers are properly installed
- Check storage permissions if getting write errors

## System Requirements

### Hardware Requirements
1. **GPU**
   - Minimum: NVIDIA GPU with 16GB VRAM
   - Recommended: NVIDIA GPU with 24GB VRAM
   - Optimal: NVIDIA GPU with 32GB+ VRAM
   
   VRAM Usage Breakdown:
   - Base Models:
     - SD 3.5 Base: ~8GB
     - SD 3.5 Large: ~12-16GB
     - SDXL: ~12GB
   - Video Generation:
     - AnimateDiff: +4-6GB
     - ControlNet: +2-4GB per model
     - Frame Interpolation: +2GB
     - SVD: ~8GB

2. **Storage**
   Total Required: ~200GB
   - Models (~175GB):
     - Base SD Models: 50GB
       • SD 3.5 Base/Large: 12GB
       • SDXL Base/Refiner: 13GB
     - Alternative Models: 25GB
       • Runway v2: 5.5GB
       • Hailuo v11: 4GB
       • Luma v1: 4GB
     - Video Models: 45GB
       • AnimateDiff: 5GB
       • SVD-XT: 18GB
     - ControlNet: 30GB
     - Text Encoders: 15GB
     - Upscalers: 10GB
   - Working Space: 25GB minimum
   - Generated Content: 50GB recommended

3. **RAM**
   - Minimum: 16GB
   - Recommended: 32GB
   - Optimal: 64GB

### Installed Components

1. **Core Models**
   - SD 3.5 Base & Large
   - SDXL Base & Refiner
   - Specialized Models:
     - Runway v2 (Photorealism)
     - Hailuo v11 (Anime/Illustration)
     - Luma v1 (3D/XR)

2. **Video Generation**
   - AnimateDiff (Character Animation)
   - SVD-XT (Video-to-Video)
   - Frame Interpolation
   - Motion Tracking

3. **Enhancement Tools**
   - ControlNet Suite
   - IP-Adapter Plus
   - Advanced Upscalers
   - Video Matting

4. **ComfyUI Extensions**
   - Workflow Management
   - Advanced Controls
   - Audio Synchronization
   - Video Processing

## Usage Configurations

### VRAM Optimization Presets

1. **High Quality Mode** (24GB+ VRAM)
   ```json
   {
     "vram_optimization_level": 0,
     "disable_cuda_malloc": false,
     "preview_method": "auto"
   }
   ```

2. **Balanced Mode** (16GB VRAM)
   ```json
   {
     "vram_optimization_level": 2,
     "disable_cuda_malloc": true,
     "cuda_malloc_split": 512,
     "preview_method": "taesd"
   }
   ```

3. **Low Memory Mode** (12GB VRAM)
   ```json
   {
     "vram_optimization_level": 3,
     "disable_cuda_malloc": true,
     "cuda_malloc_split": 256,
     "preview_method": "none"
   }
   ```

### Pre-installed Workflows

Located in `/workflows`:
1. Character Animation
   - Basic movement
   - Lip sync
   - Full body animation

2. Scene Generation
   - Background creation
   - Environment animation
   - Lighting effects

3. Video Enhancement
   - Frame interpolation
   - Super resolution
   - Style transfer

4. Audio Integration
   - Voice generation
   - Music sync
   - Sound effects

## Model Selection Guide

### Base Models
1. **SD 3.5 Base**
   - General purpose
   - Best for: Quick iterations, testing
   - VRAM: 8GB

2. **SD 3.5 Large**
   - Highest quality
   - Best for: Final renders
   - VRAM: 12-16GB

3. **SDXL**
   - High resolution
   - Best for: Detailed scenes
   - VRAM: 12GB

### Specialized Models
1. **Runway v2**
   - Photorealistic results
   - Good for: Real-world scenes

2. **Hailuo v11**
   - Anime/illustration
   - Good for: Character animation

3. **Luma v1**
   - 3D-aware generation
   - Good for: VR/AR content

## Performance Tips

1. **Memory Management**
   - Use SD 3.5 Base for setup/testing
   - Switch to Large for final renders
   - Enable VAE tiling for large images
   - Use appropriate VRAM optimization level

2. **Video Generation**
   - Start with small batch sizes
   - Use motion vectors for consistency
   - Enable frame interpolation last
   - Cache intermediate results

3. **Quality Optimization**
   - Use ControlNet for stability
   - Enable IP-Adapter for consistency
   - Apply frame interpolation for smoothness
   - Use video matting for clean edges

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