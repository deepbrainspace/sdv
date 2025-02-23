FROM nvidia/cuda:11.8.0-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y \
    git python3 python3-pip \
    libgl1-mesa-dev libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /stable-diffusion-webui

RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git .
RUN pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

RUN pip3 install -r requirements.txt
RUN pip3 install xformers

EXPOSE 7860

CMD ["python3", "launch.py", "--listen", "--xformers", "--enable-insecure-extension-access"] 