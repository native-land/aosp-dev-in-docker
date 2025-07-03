FROM ubuntu:25.04

# Update package list and install required packages
RUN apt update && apt install -y \
    git-core \
    gnupg \
    flex \
    bison \
    build-essential \
    zip \
    curl \
    zlib1g-dev \
    libc6-dev-i386 \
    x11proto-core-dev \
    libx11-dev \
    lib32z1-dev \
    libgl1-mesa-dev \
    libxml2-utils \
    xsltproc \
    unzip \
    fontconfig \
    rsync \
    repo \
    && rm -rf /var/lib/apt/lists/*

# Copy scripts from host
COPY get-aosp.sh /usr/local/bin/get-aosp.sh
RUN chmod +x /usr/local/bin/get-aosp.sh
COPY build-aosp.sh /usr/local/bin/build-aosp.sh
RUN chmod +x /usr/local/bin/build-aosp.sh

# Configure sysctl settings
RUN sysctl -w kernel.apparmor_restrict_unprivileged_unconfined=0 && \
    sysctl -w kernel.apparmor_restrict_unprivileged_userns=0

# Set working directory
WORKDIR /aosp

# Default command
CMD ["/bin/bash"]
