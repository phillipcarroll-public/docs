#!/bin/bash

# Create xpu-ipex container working folders
mkdir -p ~/XPU/jupyter && \

# Build Dockerfile
echo 'FROM intel/intel-extension-for-pytorch:2.8.10-xpu-pip-jupyter' > ~/XPU/Dockerfile && \
echo 'RUN pip install --no-cache-dir scikit-learn ipywidgets IProgress transformers matplotlib sentencepiece openai-whisper accelerate' >> ~/XPU/Dockerfile && \
echo 'RUN apt update -y && apt install ffmpeg -y' >> ~/XPU/Dockerfile && \
echo 'WORKDIR /jupyter' >> ~/XPU/Dockerfile && \
echo 'CMD ["jupyter", "lab", "--ip=0.0.0.0", "--no-browser", "--allow-root", "--NotebookApp.notebook_dir=/jupyter"]' >> ~/XPU/Dockerfile && \

# Build custom docker image based on intel torch and tensorflow containers
sudo docker build -t mrchanche-xpu-torch-jupyter:2.8.10 -f ~/XPU/Dockerfile . && \

# Create xpu-ipex-torch-docker.sh in ~/XPU/
echo '#!/bin/bash' > ~/XPU/xpu-ipex-torch-docker.sh && \
echo 'sudo docker run -it --rm \' >> ~/XPU/xpu-ipex-torch-docker.sh && \
echo '    -p 8888:8888 \' >> ~/XPU/xpu-ipex-torch-docker.sh && \
echo '    --device /dev/dri \' >> ~/XPU/xpu-ipex-torch-docker.sh && \
echo '    -v /dev/dri/by-path:/dev/dri/by-path \' >> ~/XPU/xpu-ipex-torch-docker.sh && \
# This line maps your host dir to the working dir
echo '    -v ~/XPU/jupyter:/jupyter \' >> ~/XPU/xpu-ipex-torch-docker.sh && \
echo '    -w /jupyter \' >> ~/XPU/xpu-ipex-torch-docker.sh && \
echo '    mrchanche-xpu-torch-jupyter:2.8.10' >> ~/XPU/xpu-ipex-torch-docker.sh && \
chmod +x ~/XPU/xpu-ipex-torch-docker.sh && \

# Wrap up
echo "Finished, start your container with: bash ~/XPU/xpu-ipex-torch-docker.sh"