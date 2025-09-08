#!/usr/bin/env bash
set -ex

ROOT="$(dirname "$(readlink -f "$0")")"

if [ "$FORCE_BUILD" == "on" ]; then
    echo "Forcing build of opencv-python ${OPENCV_VERSION}"
    exit 1
fi

if [ ! -z "$OPENCV_URL" ]; then
    echo "Installing opencv ${OPENCV_VERSION} from deb packages"
    $ROOT/install_deb.sh
else
    echo "Installing opencv ${OPENCV_VERSION} from pip"
    export OPENCV_DEB="OpenCV-${OPENCV_VERSION}.tar.gz"
    export OPENCV_URL=${TAR_INDEX_URL}/${OPENCV_DEB}

    # Install required system dependencies for Ubuntu 24.04
    apt-get update && apt-get install -y --no-install-recommends \
      libtbb12 libglib2.0-0 libsm6 libxext6 libgl1 libgtk-3-0 \
      ffmpeg gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-libav \
      tesseract-ocr libtesseract5 && \
      rm -rf /var/lib/apt/lists/*

    # pip + numpy
    python3 -m pip install --upgrade pip
    python3 -m pip install --no-cache-dir numpy

    # Install OpenCV contrib wheel
    python3 -m pip install --no-cache-dir \
      "opencv-contrib-python~=${OPENCV_VERSION}"
fi

python3 -c "import cv2; print('OpenCV version:', str(cv2.__version__)); print(cv2.getBuildInformation())"
echo "installed" > "$ROOT/.opencv"
