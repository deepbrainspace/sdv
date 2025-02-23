FROM nvidia/cuda:11.8.0-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y \
    git python3 python3-pip \
    libgl1-mesa-dev libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /ComfyUI

RUN git clone https://github.com/comfyanonymous/ComfyUI.git .
RUN pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
RUN pip3 install -r requirements.txt

EXPOSE 8188

CMD ["python3", "main.py", "--listen"] 