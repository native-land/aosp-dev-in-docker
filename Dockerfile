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
    && rm -rf /var/lib/apt/lists/*

# Install repo from Tsinghua mirror
RUN curl -o /usr/local/bin/repo https://mirrors.tuna.tsinghua.edu.cn/git/git-repo \
    && chmod +x /usr/local/bin/repo

# Add repo to PATH environment variable
ENV PATH="/usr/local/bin:${PATH}"

# Copy scripts from host
COPY get-aosp.sh /usr/local/bin/get-aosp.sh
RUN chmod +x /usr/local/bin/get-aosp.sh
COPY build-aosp.sh /usr/local/bin/build-aosp.sh
RUN chmod +x /usr/local/bin/build-aosp.sh

# Set working directory
WORKDIR /aosp

# Default command
CMD ["/bin/bash"]
