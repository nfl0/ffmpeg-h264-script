#!/bin/bash

set -e

# Function to handle errors
handle_error() {
    echo "Error occurred in script at line: $1"
    exit 1
}

# Trap errors and call handle_error function
trap 'handle_error $LINENO' ERR

echo "Updating and upgrading the system..."
sudo apt update
sudo apt upgrade -y

echo "Installing dependencies..."
sudo apt install -y \
  autoconf \
  automake \
  build-essential \
  cmake \
  git \
  libass-dev \
  libfreetype6-dev \
  libgnutls28-dev \
  libsdl2-dev \
  libtool \
  libva-dev \
  libvdpau-dev \
  libvorbis-dev \
  libxcb1-dev \
  libxcb-shm0-dev \
  libxcb-xfixes0-dev \
  pkg-config \
  texinfo \
  wget \
  zlib1g-dev \
  yasm \
  libx264-dev

echo "Creating directories for sources and binaries..."
mkdir -pv ~/ffmpeg_sources ~/bin

echo "Installing libx264..."
cd ~/ffmpeg_sources
git clone --depth 1 https://git.ffmpeg.org/ffmpeg.git
cd x264
./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" --enable-static
make
make install
make distclean

echo "Compiling and installing FFmpeg..."
cd ~/ffmpeg_sources
git clone https://github.com/FFmpeg/FFmpeg.git
cd FFmpeg
./configure --prefix="$HOME/ffmpeg_build" --pkg-config-flags="--static" --extra-cflags="-I$HOME/ffmpeg_build/include" --extra-ldflags="-L$HOME/ffmpeg_build/lib" --extra-libs="-lpthread -lm" --bindir="$HOME/bin" --enable-gpl --enable-libass --enable-libfreetype --enable-libvorbis --enable-libvpx --enable-libx264 --enable-nonfree
make
make install
make distclean
hash -r

echo "Copying binaries to /usr/local/bin for system-wide use..."
sudo cp ~/bin/ffmpeg /usr/local/bin/
sudo cp ~/bin/ffplay /usr/local/bin/
sudo cp ~/bin/ffprobe /usr/local/bin/

echo "Verifying the installation..."
if ffmpeg -codecs | grep -q h264; then
    echo "FFmpeg with H.264 support has been successfully installed."
else
    echo "FFmpeg installation failed or H.264 support is not enabled."
    exit 1
fi
