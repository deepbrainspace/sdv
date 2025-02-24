#!/bin/bash
# Ensure directories exist
mkdir -p /workspace/storage/output-videos
mkdir -p /workspace/ComfyUI/models/checkpoints
mkdir -p /workspace/ComfyUI/models/loras

# Install Hugging Face CLI if not present
if ! command -v huggingface-cli &> /dev/null; then
    pip install huggingface_hub
fi

# Set Hugging Face API token (via environment variable)
export HF_TOKEN=${HF_TOKEN:-"your_huggingface_api_token"}  # Use env var or default for testing

# Download Stable Diffusion checkpoint from Hugging Face
huggingface-cli download --token ${HF_TOKEN} runwayml/stable-diffusion-v1-5 v1-5-pruned.ckpt --local-dir /workspace/ComfyUI/models/checkpoints

# Download dance LoRA from Hugging Face (replace with your LoRA repo)
huggingface-cli download --token ${HF_TOKEN} your-username/dance-lora dance_lora.safetensors --local-dir /workspace/ComfyUI/models/loras

# Ensure Rclone is installed (likely pre-installed in ai-dock/comfyui)
if ! command -v rclone &> /dev/null; then
    curl https://rclone.org/install.sh | sudo bash
fi

# Sync outputs from R2 on startup (optional, can be run later)
rclone copy r2bucket:output-videos /workspace/storage/output-videos --create-empty-src-dirs

# Start background sync loop for outputs to R2
nohup bash -c "while true; do rclone sync /workspace/storage/output-videos r2bucket:output-videos; sleep 3600; done" &

# Launch ComfyUI
python /workspace/ComfyUI/main.py