#!/bin/bash

# Check for HF_TOKEN and STORAGE_PATH
if [ -z "$HF_TOKEN" ] || [ -z "$STORAGE_PATH" ]; then
    echo "Please set HF_TOKEN and STORAGE_PATH environment variables"
    exit 1
fi

# Create directories
mkdir -p ${STORAGE_PATH}/{models,output,workflows}
mkdir -p ${STORAGE_PATH}/models/{checkpoints,loras,embeddings,motion,controlnet,upscalers}

# Essential models (around 110GB total)
echo "Downloading essential models..."

# Base models (approximately 25GB)
wget -O ${STORAGE_PATH}/models/checkpoints/sd_xl_base_1.0.safetensors \
    https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors  # 6.5GB

wget -O ${STORAGE_PATH}/models/checkpoints/sd_xl_refiner_1.0.safetensors \
    https://huggingface.co/stabilityai/stable-diffusion-xl-refiner-1.0/resolve/main/sd_xl_refiner_1.0.safetensors  # 6.5GB

wget -O ${STORAGE_PATH}/models/checkpoints/sd_v1.5.safetensors \
    https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned.ckpt  # 4GB

# Video models (approximately 45GB)
wget -O ${STORAGE_PATH}/models/motion/mm_sd_v15_v2.ckpt \
    https://huggingface.co/guoyww/animatediff/resolve/main/mm_sd_v15_v2.ckpt  # 5GB

wget -O ${STORAGE_PATH}/models/checkpoints/svd_xt.safetensors \
    https://huggingface.co/stabilityai/stable-video-diffusion-xt/resolve/main/svd_xt.safetensors  # 18GB

# ControlNet models (approximately 30GB)
wget -O ${STORAGE_PATH}/models/controlnet/control_v11p_sd15_openpose.pth \
    https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11p_sd15_openpose.pth  # 1.5GB

wget -O ${STORAGE_PATH}/models/controlnet/control_v11p_sd15_canny.pth \
    https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11p_sd15_canny.pth  # 1.5GB

wget -O ${STORAGE_PATH}/models/controlnet/control_v11p_sd15_depth.pth \
    https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11p_sd15_depth.pth  # 1.5GB

# Upscalers (approximately 10GB)
wget -O ${STORAGE_PATH}/models/upscalers/4x-UltraSharp.pth \
    https://huggingface.co/uwg/upscaler/resolve/main/4x-UltraSharp.pth  # 5GB

echo "All base models downloaded. Please download any additional character LoRAs you need."

# Storage space information
echo "
Storage Requirements:
- Essential models: ~110GB
- Working space for outputs: 50GB minimum
- Space for custom models/LoRAs: 50GB recommended
- Total recommended space: 250GB minimum

Current storage usage:"
df -h ${STORAGE_PATH}