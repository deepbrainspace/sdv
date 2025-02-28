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
apt-get install -y curl
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
mkdir -p /workspace/storage/output-videos
mkdir -p /workspace/ComfyUI/models/{checkpoints,loras,embeddings,motion,controlnet,upscalers,text_encoders}

# list r2:deepbrain
rclone lsf r2:deepbrain
rclone copy r2:deepbrain/models /workspace/ComfyUI/ --progress
rclone copy r2:deepbrain/custom_nodes /workspace/ComfyUI/custom_nodes/ --progress

# Create extra_model_paths.yaml
echo "comfyui:
  base_path: /workspace/ComfyUI
  checkpoints: checkpoints/
  models: models/
  vae: vae/" > /app/extra_model_paths.yaml
chown comfyui:comfyui /app/extra_model_paths.yaml
chmod a+r /app/extra_model_paths.yaml


####################################################
# download models FOR cloudflare r2
####################################################
export DOWNLOAD_PATH="/mnt/r2-deepbrain"

# Check for HF_TOKEN and STORAGE_PATH
if [ -z "$HF_TOKEN" ] || [ -z "$DOWNLOAD_PATH" ]; then
    echo "Please set HF_TOKEN and MODELS_DOWNLOAD_PATH environment variables"
    exit 1
fi

# SD Video Models
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