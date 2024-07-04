FROM carlasim/carla:0.9.15

USER root

# Set the locale to UTF-8 to avoid UnicodeEncodeError
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

RUN apt-get update && apt-get install -y \
    curl \
    xdg-user-dirs \
    python3-pip \
    libjpeg8-dev \
    libtiff5-dev \
    libsdl2-dev \
    libsdl2-image-dev \
    libsdl2-mixer-dev \
    libsdl2-ttf-dev \
    libfreetype6-dev \
    pkg-config \
    libasound2-dev \
    libx11-dev \
    x11-apps \
    vulkan-utils \
    mesa-vulkan-drivers \
    libvulkan1 \
    nvidia-driver-470

RUN LC_ALL=C.UTF-8 xdg-user-dirs-update --force

# Installing the NVIDIA Container Toolkit
RUN curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
&& curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
  sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
  tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

# Update the packages list from the repository
# Install the NVIDIA Container Toolkit packages
RUN apt-get update && apt-get install -y nvidia-container-toolkit

# Configure the container runtime by using the nvidia-ctk command
RUN nvidia-ctk runtime configure --runtime=docker

# Install the CARLA Python package and pygame
RUN pip3 install carla pygame numpy

USER carla

# Set XDG_RUNTIME_DIR environment variable
ENV XDG_RUNTIME_DIR=/tmp/runtime-carla
# Use dummy audio driver for pygame
ENV SDL_AUDIODRIVER=dummy  

RUN mkdir -p /tmp/runtime-carla

# Ensure CarlaUE4.sh is executable
RUN chmod +x /home/carla/CarlaUE4.sh

# Set the entrypoint to run CarlaUE4.sh with the necessary options
ENTRYPOINT ["/bin/bash", "/home/carla/CarlaUE4.sh"]