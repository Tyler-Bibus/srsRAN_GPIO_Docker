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
    make \
    gcc \
    g++ \
    pkg-config \
    libyaml-cpp-dev \
    libgtest-dev \
    libfftw3-dev \
    libmbedtls-dev \
    libboost-program-options-dev \
    libconfig++-dev \
    libsctp-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install UHD dependencies and build from source
RUN apt-get update && apt-get install -y \
    autoconf \
    automake \
    build-essential \
    ccache \
    cmake \
    cpufrequtils \
    doxygen \
    ethtool \
    g++ \
    git \
    inetutils-tools \
    libboost-all-dev \
    libncurses-dev \
    libusb-1.0-0 \
    libusb-1.0-0-dev \
    libusb-dev \
    python3-dev \
    python3-mako \
    python3-numpy \
    python3-requests \
    python3-scipy \
    python3-setuptools \
    python3-ruamel.yaml \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && git clone https://github.com/EttusResearch/uhd.git /uhd \
    && cd /uhd \
    && git checkout v4.7.0.0 \
    && cd host \
    && mkdir build \
    && cd build \
    && cmake ../ \
    && make -j$(nproc) \
    && make install \
    && ldconfig \
    && /usr/local/bin/uhd_images_downloader

# Install srsRAN from custom repository
RUN git clone https://github.com/Tyler-Bibus/srsRAN_Project_GPIO.git /srsRAN \
    && cd /srsRAN \
    && git checkout release23-10 \
    && mkdir build \
    && cd build \
    && cmake ../ \
    && make -j$(nproc) \
    && cp /srsRAN/gnb_b210_20MHz_oneplus_8t.yml /srsRAN/apps/gnb/ \
    && make install \
    && ldconfig

# Download and apply srsRAN patch
RUN wget -O /srsRAN/srsran.patch https://gitlab.flux.utah.edu/dmaas/srs-outdoor-ota/-/raw/master/etc/srsran/srsran.patch

# Set working directory
WORKDIR ~/

# Default command
CMD ["/bin/bash"]
