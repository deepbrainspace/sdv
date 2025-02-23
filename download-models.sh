#!/bin/bash
source .env

# Install git-lfs
apt-get update && apt-get install -y git-lfs

# Configure git-lfs
git lfs install

# Clone models from HuggingFace
git clone https://huggingface.co/$MODEL_REPO models-repo

# Distribute models to appropriate directories
mkdir -p models/Stable-diffusion
mkdir -p models/VAE
mkdir -p models/ControlNet
mkdir -p comfy-models
mkdir -p deforum-models
mkdir -p flux-models

# Copy models to their respective locations
cp models-repo/sd/* models/Stable-diffusion/
cp models-repo/vae/* models/VAE/
cp models-repo/controlnet/* models/ControlNet/

# Create symbolic links for other interfaces
ln -s $(pwd)/models/* comfy-models/
ln -s $(pwd)/models/* deforum-models/
ln -s $(pwd)/models/* flux-models/

echo "Models downloaded and distributed successfully!" 