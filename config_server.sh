#!/bin/bash


####################################################
## CONFIGURATION SCRIPT FOR GPU SERVER
####################################################


####################################################
# vast.ai setup tunnel
####################################################
# first restart comfyUI so it listens to all interfaces
kill 1286 # or whatever the output of the ps aux | grep ComfyUI is
cd /workspace/ComfyUI
python main.py --listen 0.0.0.0 --port 18188 --disable-auto-launch --enable-cors-header &


# then setup a ssh tunnel
ssh -L 8888:127.0.0.1:18188 root@77.33.143.182 -p 10389

# then browse to localhost:8888


####################################################
# rclone + cloudflare r2
####################################################
apt-get update
apt-get install -y curl unzip
curl -O https://rclone.org/install.sh
sudo bash install.sh
rclone version

# for running on the server, so just run the contents of the .env file on the server instead of the below!
source .env  


# Configure rclone

cat <<EOF >> ~/.config/rclone/rclone.conf
[r2]
type = s3
provider = Cloudflare
region = auto
access_key_id = ${R2_ACCESS_KEY_ID}
secret_access_key = ${R2_SECRET_ACCESS_KEY}
endpoint = https://${R2_ACCOUNT_ID}.r2.cloudflarestorage.com
acl = private
EOF

# Create directories
mkdir -p /workspace/ComfyUI/storage/output-videos
mkdir -p /workspace/ComfyUI/models/{checkpoints,loras,embeddings,motion,controlnet,upscalers,text_encoders}

# list r2:deepbrain
rclone lsf r2:deepbrain


rclone copy r2:deepbrain/models/wan /workspace/ComfyUI/models/ --progress
rclone copy r2:deepbrain/models/flux /workspace/ComfyUI/models/ --progress

rclone copy r2:deepbrain/models/checkpoints /workspace/ComfyUI/models/checkpoints/ --progress
rclone copy r2:deepbrain/custom_nodes /workspace/ComfyUI/custom_nodes/ --progress
rclone copy r2:deepbrain/models/vae /workspace/ComfyUI/models/vae/ --progress

 

# Create extra_model_paths.yaml
echo "comfyui:
  base_path: /workspace/ComfyUI
  checkpoints: checkpoints/
  models: models/
  vae: vae/" > /app/extra_model_paths.yaml
chown comfyui:comfyui /app/extra_model_paths.yaml
chmod a+r /app/extra_model_paths.yaml

####################################################
# remove tmux (vast.ai)
####################################################
touch ~/.no_auto_tmux

git config --global --add safe.directory /workspace/ComfyUI
git fetch
 git config --global --add safe.directory /workspace/ComfyUI/custom_nodes/ComfyUI-Manager

####################################################
# install comfyui
####################################################

mkdir -p /workspace
cd /workspace
git clone https://github.com/Comfy-Org/ComfyUI.git
git clone git@github.com:comfyanonymous/ComfyUI.git
cd ComfyUI

cd custom_nodes
git clone https://github.com/ltdrdata/ComfyUI-Manager comfyui-manager
git clone git@github.com:Comfy-Org/ComfyUI-Manager.git

cd comfyui-manager
uv pip install -r custom_nodes/comfyui-manager/requirements.txt
# restart comfyUI

####################################################
# upgrade comfyui
####################################################
git config --global --add safe.directory /workspace/ComfyUI
git fetch
git checkout <version>
pip install --upgrade pip
pip install -r requirements.txt
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu126

ps aux | grep python
kill -9 <pid>
python main.py --listen 0.0.0.0 --port 18188 --disable-auto-launch --enable-cors-header &
# then setup a ssh tunnel
ssh -L 8888:127.0.0.1:18188 root@77.33.143.182 -p 10389


systemctl stop supervisor
systemctl disable supervisor
apt remove -y supervisor
apt remove -y tmux
apt autoremove -y
apt clean

####################################################
# runpod
####################################################
cd /workspace/ComfyUI
uv venv
source .venv/bin/activate
pip install uv
uv pip install -r requirements.txt
uv pip install torch torchvision --index-url https://download.pytorch.org/whl/cu118
nohup uv run python main.py --listen 0.0.0.0 --port 8188 &


####################################################
# download models FOR cloudflare r2
####################################################
export DOWNLOAD_PATH="/mnt/r2-deepbrain"

# Check for HF_TOKEN and STORAGE_PATH
if [ -z "$HF_TOKEN" ] || [ -z "$DOWNLOAD_PATH" ]; then
    echo "Please set HF_TOKEN and MODELS_DOWNLOAD_PATH environment variables"
    exit 1
fi
#######################################
# Wan 2.1 ComfyUI Repackaged
#######################################
# https://comfyanonymous.github.io/ComfyUI_examples/wan/
huggingface-cli download Comfy-Org/Wan_2.1_ComfyUI_repackaged --include split_files/text_encoders/*.safetensors --local-dir /mnt/deepbrain/models/wan/text_encoders
# vae
wget https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors
# diffusion models i2v 32.5GB
wget https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/diffusion_models/wan2.1_i2v_480p_14B_bf16.safetensors
# diffusion models i2v 480p 14B fp8 16.4GB
wget https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/diffusion_models/wan2.1_i2v_480p_14B_fp8_e4m3fn.safetensors
# diffusion models i2v 720p 14B 32.5GB
wget https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/diffusion_models/wan2.1_i2v_720p_14B_bf16.safetensors
# diffusion models i2v 720p 14B fp8 16.4GB
wget https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/diffusion_models/wan2.1_i2v_720p_14B_fp8_e4m3fn.safetensors

# diffusion models t2v 2.84GB
wget https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/diffusion_models/wan2.1_t2v_1.3B_bf16.safetensors
# diffusion models t2v 1.3B fp16 2.84GB
wget https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/diffusion_models/wan2.1_t2v_1.3B_fp16.safetensors
# diffusion models t2v 14B 28.6gb
wget https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/diffusion_models/wan2.1_t2v_14B_bf16.safetensors
# diffusion models t2v 14B fp8 14.3GB
wget https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/diffusion_models/wan2.1_t2v_14B_fp8_e4m3fn.safetensors

# clip_vision
wget https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/clip_vision/clip_vision_h.safetensors


#######################################
# flux1
#######################################
# vae
wget https://huggingface.co/black-forest-labs/FLUX.1-dev/resolve/main/flux1-dev.safetensors
# checkpoint 23.8GB
huggingface-cli download black-forest-labs/FLUX.1-dev flux1-dev.safetensors --local-dir /mnt/deepbrain/models/flux/checkpoints/
# checkpoint 23.8GB
huggingface-cli download black-forest-labs/FLUX.1-schnell flux1-schnell.safetensors --local-dir /mnt/deepbrain/models/flux/checkpoints/
# checkpoint 17.2GB
wget https://huggingface.co/Comfy-Org/flux1-dev/resolve/main/flux1-dev-fp8.safetensors
huggingface-cli download Comfy-Org/flux1-dev flux1-dev-fp8.safetensors --local-dir /mnt/deepbrain/models/flux/checkpoints/
# checkpoint 17.2GB
wget https://huggingface.co/Comfy-Org/flux1-schnell/resolve/main/flux1-schnell-fp8.safetensors
huggingface-cli download Comfy-Org/flux1-schnell flux1-schnell-fp8.safetensors --local-dir /mnt/deepbrain/models/flux/checkpoints/
# clip_vision
wget https://huggingface.co/Comfy-Org/sigclip_vision_384/resolve/main/sigclip_vision_patch14_384.safetensors
#style model
huggingface-cli download black-forest-labs/FLUX.1-Redux-dev flux1-redux-dev.safetensors --local-dir /mnt/deepbrain/models/flux/checkpoints/
# canny dev, depth dev 23.8GB
huggingface-cli download black-forest-labs/FLUX.1-Canny-dev flux1-canny-dev.safetensors --local-dir /mnt/deepbrain/models/flux/checkpoints/
huggingface-cli download black-forest-labs/FLUX.1-Canny-dev flux1-depth-dev.safetensors --local-dir /mnt/deepbrain/models/flux/checkpoints/

# lora 1.24GB
huggingface-cli download black-forest-labs/FLUX.1-Canny-dev-lora flux1-canny-dev-lora.safetensors --local-dir /mnt/deepbrain/models/flux/checkpoints/
huggingface-cli download black-forest-labs/FLUX.1-Depth-dev-lora flux1-depth-dev-lora.safetensors --local-dir /mnt/deepbrain/models/flux/checkpoints/

# controlnet 3.58GB
wget https://huggingface.co/InstantX/FLUX.1-dev-Controlnet-Canny/resolve/main/diffusion_pytorch_model.safetensors
# depth controlnet 3.14GB
wget https://huggingface.co/Shakker-Labs/FLUX.1-dev-ControlNet-Depth/resolve/main/diffusion_pytorch_model.safetensors
# union controlnet 6.60GB
wget https://huggingface.co/Shakker-Labs/FLUX.1-dev-ControlNet-Union-Pro/resolve/main/diffusion_pytorch_model.safetensors

# controlnet collection 1.49 x 8
huggingface-cli download XLabs-AI/flux-controlnet-collections --include "controlnet_collection/*safetensors" --local-dir /mnt/deepbrain/models/flux/controlnet_collection

#######################################
# SD Video Models
#######################################
huggingface-cli download stabilityai/sv4d sv4d.safetensors --local-dir ${DOWNLOAD_PATH}/models/checkpoints/stablediffusion --token ${HF_TOKEN}
huggingface-cli download stabilityai/stable-video-diffusion-img2vid-xt-1-1 svd_xt_1_1.safetensors --local-dir ${DOWNLOAD_PATH}/models/checkpoints/stablediffusion --token ${HF_TOKEN}
huggingface-cli download stabilityai/stable-diffusion-3.5-large-turbo sd3.5_large_turbo.safetensors --local-dir ${DOWNLOAD_PATH}/models/checkpoints/stablediffusion --token ${HF_TOKEN}

# SD VAE Models
huggingface-cli download stabilityai/sd-vae-ft-mse-original vae-ft-mse-840000-ema-pruned.safetensors --local-dir ${DOWNLOAD_PATH}/models/vae --token ${HF_TOKEN}

# SkyReels I2V 25GB
huggingface-cli download \
    Skywork/SkyReels-V1-Hunyuan-I2V \
    diffusion_pytorch_model-00001-of-00006.safetensors \
    --local-dir ${DOWNLOAD_PATH}/models/checkpoints/skyreels \
    --token ${HF_TOKEN}
huggingface-cli download \
    Skywork/SkyReels-V1-Hunyuan-I2V \
    diffusion_pytorch_model-00002-of-00006.safetensors \
    --local-dir ${DOWNLOAD_PATH}/models/checkpoints/skyreels \
    --token ${HF_TOKEN}
huggingface-cli download \
    Skywork/SkyReels-V1-Hunyuan-I2V \
    diffusion_pytorch_model-00003-of-00006.safetensors \
    --local-dir ${DOWNLOAD_PATH}/models/checkpoints/skyreels \
    --token ${HF_TOKEN}
huggingface-cli download \
    Skywork/SkyReels-V1-Hunyuan-I2V \
    diffusion_pytorch_model-00004-of-00006.safetensors \
    --local-dir ${DOWNLOAD_PATH}/models/checkpoints/skyreels \
    --token ${HF_TOKEN}
huggingface-cli download \
    Skywork/SkyReels-V1-Hunyuan-I2V \
    diffusion_pytorch_model-00005-of-00006.safetensors \
    --local-dir ${DOWNLOAD_PATH}/models/checkpoints/skyreels \
    --token ${HF_TOKEN}
huggingface-cli download \
    Skywork/SkyReels-V1-Hunyuan-I2V \
    diffusion_pytorch_model-00006-of-00006.safetensors \
    --local-dir ${DOWNLOAD_PATH}/models/checkpoints/skyreels \
    --token ${HF_TOKEN}
cat ${DOWNLOAD_PATH}/models/checkpoints/skyreels/diffusion_pytorch_model-00001-of-00006.safetensors \
${DOWNLOAD_PATH}/models/checkpoints/skyreels/diffusion_pytorch_model-00002-of-00006.safetensors \
${DOWNLOAD_PATH}/models/checkpoints/skyreels/diffusion_pytorch_model-00003-of-00006.safetensors \
${DOWNLOAD_PATH}/models/checkpoints/skyreels/diffusion_pytorch_model-00004-of-00006.safetensors \
${DOWNLOAD_PATH}/models/checkpoints/skyreels/diffusion_pytorch_model-00005-of-00006.safetensors \
${DOWNLOAD_PATH}/models/checkpoints/skyreels/diffusion_pytorch_model-00006-of-00006.safetensors > ${DOWNLOAD_PATH}/models/checkpoints/skyreels/skyreels_v1_hunyuan_i2v.safetensors

# SkyReels T2V 25GB
huggingface-cli download \
    Skywork/SkyReels-V1-Hunyuan-T2V \
    diffusion_pytorch_model-00001-of-00006.safetensors \
    --local-dir ${DOWNLOAD_PATH}/models/checkpoints/skyreels \
    --token ${HF_TOKEN}
huggingface-cli download \
    Skywork/SkyReels-V1-Hunyuan-T2V \
    diffusion_pytorch_model-00002-of-00006.safetensors \
    --local-dir ${DOWNLOAD_PATH}/models/checkpoints/skyreels \
    --token ${HF_TOKEN}
huggingface-cli download \
    Skywork/SkyReels-V1-Hunyuan-T2V \
    diffusion_pytorch_model-00003-of-00006.safetensors \
    --local-dir ${DOWNLOAD_PATH}/models/checkpoints/skyreels \
    --token ${HF_TOKEN}
huggingface-cli download \
    Skywork/SkyReels-V1-Hunyuan-T2V \
    diffusion_pytorch_model-00004-of-00006.safetensors \
    --local-dir ${DOWNLOAD_PATH}/models/checkpoints/skyreels \
    --token ${HF_TOKEN}
huggingface-cli download \
    Skywork/SkyReels-V1-Hunyuan-T2V \
    diffusion_pytorch_model-00005-of-00006.safetensors \
    --local-dir ${DOWNLOAD_PATH}/models/checkpoints/skyreels \
    --token ${HF_TOKEN}
huggingface-cli download \
    Skywork/SkyReels-V1-Hunyuan-T2V \
    diffusion_pytorch_model-00006-of-00006.safetensors \
    --local-dir ${DOWNLOAD_PATH}/models/checkpoints/skyreels \
    --token ${HF_TOKEN}
cat ${DOWNLOAD_PATH}/models/checkpoints/skyreels/diffusion_pytorch_model-00001-of-00006.safetensors \
${DOWNLOAD_PATH}/models/checkpoints/skyreels/diffusion_pytorch_model-00002-of-00006.safetensors \
${DOWNLOAD_PATH}/models/checkpoints/skyreels/diffusion_pytorch_model-00003-of-00006.safetensors \
${DOWNLOAD_PATH}/models/checkpoints/skyreels/diffusion_pytorch_model-00004-of-00006.safetensors \
${DOWNLOAD_PATH}/models/checkpoints/skyreels/diffusion_pytorch_model-00005-of-00006.safetensors \
${DOWNLOAD_PATH}/models/checkpoints/skyreels/diffusion_pytorch_model-00006-of-00006.safetensors > ${DOWNLOAD_PATH}/models/checkpoints/skyreels/skyreels_v1_hunyuan_t2v.safetensors

# Kijai SkyReels V1 Hunyuan I2V Q8 14
huggingface-cli download \
    Kijai/SkyReels-V1-Hunyuan_comfy \
    skyreels-hunyuan-I2V-Q8_0.gguf \
    --local-dir ${DOWNLOAD_PATH}/models/checkpoints/skyreels \
    --token ${HF_TOKEN}