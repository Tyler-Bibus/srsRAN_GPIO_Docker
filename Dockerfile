# Use Ubuntu 22.04 as the base image
FROM ubuntu:22.04

# Set environment variables to avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Update package lists and install basic utilities
RUN apt-get update && apt-get install -y \
    net-tools \
    iputils-ping \
    wget \
    curl \
    git \
    build-essential \
    cmake \
    libfftw3-dev \
    libmbedtls-dev \
    libboost-program-options-dev \
    libconfig++-dev \
    libsctp-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install UHD drivers
RUN sudo apt install -y autoconf automake build-essential ccache cmake cpufrequtils \
  doxygen ethtool g++ git inetutils-tools libboost-all-dev libncurses-dev \
  libusb-1.0-0 libusb-1.0-0-dev libusb-dev python3-dev python3-mako \
  python3-numpy python3-requests python3-scipy python3-setuptools \
  python3-ruamel.yaml \
    && git clone https://github.com/EttusResearch/uhd.git ~/uhd \
    && cd ~/uhd \
    && git checkout v4.7.0.0 \
    && cd host \
    && mkdir build \
    && cd build \
    && cmake ../ \
    && make -j $(nproc) \
    && sudo make install \
    && sudo ldconfig \
    && sudo uhd_images_downloader

# TODO maybe set up GCC? We might need version 11.4
# Uncomment these lines if needed...
# NOTE: if this is needed, we might need to modify the update alternatives correctly..

#RUN sudo add-apt-repository ppa:ubuntu-toolchain-r/test -y \
#    && sudo apt update \
#    && sudo update-alternatives --config g++

# Install srsRAN
RUN git clone https://github.com/Tyler-Bibus/srsRAN_Project_GPIO.git /srsRAN \
    && cd /srsRAN \
    && git checkout release23-10 \
    && mkdir build \
    && cd build \
    && cmake ../ \
    && make -j$(nproc) \
    && cp ~/srsRAN/gnb_b210_20MHz_oneplus_8t.yml apps/gnb
#    && make install \ OPTIONAL
#    && ldconfig OPTIONAL

# Set working directory
WORKDIR /workspace

# Default command (can be overridden when running the container)
CMD ["/bin/bash"]
