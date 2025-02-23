# Stable Diffusion Video Generation Stack

This repository contains a Docker-based setup for running Stable Diffusion with video generation capabilities, including AUTOMATIC1111's WebUI, ComfyUI, and Deforum.

## Key Components

1. **Stable Diffusion WebUI (AUTOMATIC1111)**
   - User-friendly interface with extensive features
   - Good for single image generation
   - Supports many extensions
   - More guided, form-based approach

2. **ComfyUI**
   - Node-based interface (similar to Blender nodes)
   - More flexible and powerful for custom workflows
   - Better for advanced users who want to understand the pipeline
   - Great for experimenting with different generation approaches

3. **Deforum**
   - Specialized for video generation
   - Animation capabilities
   - Built as an extension for SD WebUI

4. **Stable Video Diffusion (Flux)**
   - Specialized in consistent video generation
   - Better motion preservation between frames
   - Ideal for music videos and character consistency
   - Works alongside Deforum for different video needs

## Storage Requirements

Minimum recommended space: 100GB
- Base images and code: ~10GB
- Basic models: ~30GB
- Generated outputs: Varies (reserve at least 20GB)
- Working space: ~40GB

For your 173GB vast.ai machine, this should be sufficient for starting out.

## Required Models

### Base Models (Required)
1. Stable Diffusion base model (choose one):
   - [SD 1.5](https://huggingface.co/runwayml/stable-diffusion-v1-5)
   - [SD XL](https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0)
   
### Optional but Recommended
2. VAE:
   - [SD VAE](https://huggingface.co/stabilityai/sd-vae-ft-mse)
3. ControlNet models:
   - [Canny](https://huggingface.co/lllyasviel/ControlNet-v1-1/blob/main/control_v11p_sd15_canny.pth)
   - [Openpose](https://huggingface.co/lllyasviel/ControlNet-v1-1/blob/main/control_v11p_sd15_openpose.pth)

## Model Placement

Directory structure:
```bash
├── models/                  # For SD WebUI
│   ├── Stable-diffusion/   # Base models (.safetensors or .ckpt)
│   ├── VAE/               # VAE models
│   └── ControlNet/        # ControlNet models
├── comfy-models/          # For ComfyUI (similar structure)
└── deforum-models/        # For Deforum (similar structure)
```

## Storage Strategy

There are two approaches:

1. **Local Storage (Recommended for vast.ai)**
   - Pros: Fastest performance
   - Cons: Uses more local storage
   - Current setup uses this approach

2. **S3 Storage**
   - Pros: Saves local storage
   - Cons: Slower loading times, more complex setup
   - Consider this if you need to save local space

## NVIDIA Requirements

The containers need NVIDIA drivers on the host because:
- Docker containers share the host's kernel
- NVIDIA drivers provide the kernel modules needed for GPU access
- The containers use NVIDIA's Container Toolkit to access the GPU

For vast.ai machines, this is already handled as they come with NVIDIA drivers pre-installed.

## Getting Started

1. Clone this repository
2. Download required models and place them in respective directories
3. Run the stack:
   ```bash
   docker compose up --build
   ```
4. Access the interfaces:
   - SD WebUI: http://localhost:7860
   - ComfyUI: http://localhost:8188
   - Deforum: http://localhost:7861
   - Flux: http://localhost:7862

## Common Issues

1. **Out of Memory**
   - Reduce model sizes
   - Use --medvram or --lowvram in the launch commands
   - Run one interface at a time

2. **Slow Generation**
   - Ensure xformers is properly installed
   - Check GPU utilization
   - Consider using smaller models

3. **Missing Models**
   - Double-check model placement in correct directories
   - Verify model format (.safetensors or .ckpt)

## Model Download Instructions

1. **For SD 1.5 or SDXL:**
   - Go to the Hugging Face link
   - Download the .safetensors file
   - Place in `models/Stable-diffusion/`

2. **For VAE:**
   - Download from Hugging Face link
   - Place in `models/VAE/`

3. **For ControlNet:**
   - Download the .pth files
   - Place in `models/ControlNet/`

Note: You'll need to repeat the model placement for each interface (WebUI, ComfyUI, Deforum) unless you want to set up symbolic links between them.

## Resource Management

For a 173GB vast.ai machine:
- Reserve ~100GB for models and system
- Leave ~50GB for outputs
- Keep ~20GB free for temporary files and processing

Monitor your storage usage regularly, especially when generating videos with Deforum.

## Model Management

### Using Hugging Face for Models
1. Create a private repository on Hugging Face
2. Upload your models using git-lfs
3. Use the provided `download-models.sh` script to fetch and distribute models
4. Models will be automatically symlinked to all interfaces

### Model Organization on Hugging Face
```
models-repo/
├── sd/              # Base models
├── vae/             # VAE models
└── controlnet/      # ControlNet models
```

## Video Generation Strategy

For best results with music videos:
1. Use Flux for:
   - Character consistency
   - Smooth transitions
   - Realistic motion

2. Use Deforum for:
   - Complex camera movements
   - Special effects
   - Artistic transitions

