#!/bin/bash

# Check for HF_TOKEN and STORAGE_PATH
if [ -z "$HF_TOKEN" ] || [ -z "$STORAGE_PATH" ]; then
    echo "Please set HF_TOKEN and STORAGE_PATH environment variables"
    exit 1
fi

# Create directories
mkdir -p ${STORAGE_PATH}/{models,output,workflows}
mkdir -p ${STORAGE_PATH}/models/{checkpoints,loras,embeddings,motion,controlnet,upscalers,text_encoders}

echo "Downloading models..."

# Base Stable Diffusion Models (approximately 50GB)
echo "1. Downloading base models..."
# SD 3.5
wget -O ${STORAGE_PATH}/models/checkpoints/sd_3.5_base.safetensors \
    "https://huggingface.co/stabilityai/stable-diffusion-3.5-base/resolve/main/sd3_base.safetensors"  # 4GB
wget -O ${STORAGE_PATH}/models/checkpoints/sd_3.5_large.safetensors \
    "https://huggingface.co/stabilityai/stable-diffusion-3.5-large/resolve/main/sd3_large.safetensors"  # 8GB

# SDXL Models
wget -O ${STORAGE_PATH}/models/checkpoints/sd_xl_base_1.0.safetensors \
    https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors  # 6.5GB
wget -O ${STORAGE_PATH}/models/checkpoints/sd_xl_refiner_1.0.safetensors \
    https://huggingface.co/stabilityai/stable-diffusion-xl-refiner-1.0/resolve/main/sd_xl_refiner_1.0.safetensors  # 6.5GB

# Alternative Models (approximately 25GB)
echo "2. Downloading alternative models..."
# Runway
wget -O ${STORAGE_PATH}/models/checkpoints/runway_v2.safetensors \
    "https://huggingface.co/runwayml/stable-diffusion-v2-1/resolve/main/v2-1_768-ema-pruned.safetensors"  # 5.5GB
# Hailuo
wget -O ${STORAGE_PATH}/models/checkpoints/hailuo_v11.safetensors \
    "https://huggingface.co/hailuoAI/hailuo-diffusion-v11/resolve/main/hailuo_v11.safetensors"  # 4GB
# Luma
wget -O ${STORAGE_PATH}/models/checkpoints/luma_v1.safetensors \
    "https://huggingface.co/luminalxr/luma-v1/resolve/main/luma-v1.safetensors"  # 4GB

# Video Models (approximately 45GB)
echo "3. Downloading video models..."
wget -O ${STORAGE_PATH}/models/motion/mm_sd_v15_v2.ckpt \
    https://huggingface.co/guoyww/animatediff/resolve/main/mm_sd_v15_v2.ckpt  # 5GB
wget -O ${STORAGE_PATH}/models/checkpoints/svd_xt.safetensors \
    https://huggingface.co/stabilityai/stable-video-diffusion-xt/resolve/main/svd_xt.safetensors  # 18GB

# ControlNet Models (approximately 30GB)
echo "4. Downloading ControlNet models..."
wget -O ${STORAGE_PATH}/models/controlnet/control_v11p_sd15_openpose.pth \
    https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11p_sd15_openpose.pth  # 1.5GB
wget -O ${STORAGE_PATH}/models/controlnet/control_v11p_sd15_canny.pth \
    https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11p_sd15_canny.pth  # 1.5GB
wget -O ${STORAGE_PATH}/models/controlnet/control_v11p_sd15_depth.pth \
    https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11p_sd15_depth.pth  # 1.5GB

# Text Encoders (approximately 15GB)
echo "5. Downloading text encoders..."
wget -O ${STORAGE_PATH}/models/text_encoders/clip_g.safetensors \
    "https://huggingface.co/stabilityai/stable-diffusion-3.5-large/resolve/main/text_encoders/clip_g.safetensors"
wget -O ${STORAGE_PATH}/models/text_encoders/clip_l.safetensors \
    "https://huggingface.co/stabilityai/stable-diffusion-3.5-large/resolve/main/text_encoders/clip_l.safetensors"
wget -O ${STORAGE_PATH}/models/text_encoders/t5xxl_fp16.safetensors \
    "https://huggingface.co/stabilityai/stable-diffusion-3.5-large/resolve/main/text_encoders/t5xxl_fp16.safetensors"

# Upscalers (approximately 10GB)
echo "6. Downloading upscalers..."
wget -O ${STORAGE_PATH}/models/upscalers/4x-UltraSharp.pth \
    https://huggingface.co/uwg/upscaler/resolve/main/4x-UltraSharp.pth  # 5GB

echo "All models downloaded successfully!"

echo "
Model Details and Usage:

1. Base Models:
  • SD 3.5 Base: Best for general use, good balance of quality and VRAM (~8GB)
  • SD 3.5 Large: Best quality, higher VRAM usage (~12GB)
  • SDXL: Best for high-resolution images, specialized workflows

2. Alternative Models (Specialized):
  • Runway v2: Good for realistic images and photos
  • Hailuo: Specialized for anime/illustration
  • Luma: Optimized for XR/3D content

3. Video Models:
  • AnimateDiff: For character animation and movement
  • SVD-XT: For video-to-video and longer sequences

4. Additional Recommended Models (not included):
  • Deliberate v2: https://huggingface.co/XpucT/Deliberate
  • RealisticVision: https://huggingface.co/SG161222/Realistic_Vision_V4.0
  • Juggernaut: https://huggingface.co/KBlueLeaf/Juggernaut-XL

ComfyUI Configuration:
1. Models will appear automatically in the node browser
2. For SD 3.5 Large, use with these settings:
    • Enable VAE Tiling
    • Use --medvram or --lowvram flag
    • Consider batch size of 1 for animations
3. For best video results:
    • Use AnimateDiff with ControlNet
    • Enable frame interpolation for smoother results
    • Use motion vectors for consistency
"

# Storage space information
echo "
Storage Requirements Breakdown:
- Base SD Models: ~50GB
  • SD 3.5 Base: 4GB
  • SD 3.5 Large: 8GB
  • SDXL Base: 6.5GB
  • SDXL Refiner: 6.5GB
- Alternative Models: ~25GB
  • Runway v2: 5.5GB
  • Hailuo v11: 4GB
  • Luma v1: 4GB
- Video Models: ~45GB
  • AnimateDiff: 5GB
  • SVD-XT: 18GB
- ControlNet: ~30GB
- Text Encoders: ~15GB
- Upscalers: ~10GB
Total Storage Required: ~175GB

Current storage usage:"
df -h ${STORAGE_PATH}