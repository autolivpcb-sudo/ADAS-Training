#!/usr/bin/env bash
set -e

echo "==============================================="
echo "   AUTOWARE UNIVERSAL INSTALLER (Ubuntu 22.04) "
echo "==============================================="

# --- CHECK ROOT PRIVILEGES ---
if [ "$EUID" -eq 0 ]; then
  echo "❌ Please DO NOT run as root. Run as normal user."
  exit
fi

# --- UPDATE SYSTEM ---
echo "🔧 Updating system..."
sudo apt update && sudo apt upgrade -y

# --- INSTALL BASE TOOLS ---
echo "🔧 Installing base tools..."
sudo apt install -y \
    git curl wget \
    build-essential \
    cmake \
    python3-colcon-common-extensions \
    python3-rosdep \
    python3-vcstool \
    software-properties-common \
    terminator

# --- INSTALL ROS 2 HUMBLE ---
echo "🚀 Installing ROS 2 Humble..."
sudo apt install -y locales
sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

sudo apt install -y curl gnupg2 lsb-release
sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] \
https://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

sudo apt update
sudo apt install -y ros-humble-desktop

echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc
source ~/.bashrc

# --- INSTALL DOCKER ---
echo "🐳 Installing Docker..."
sudo apt install -y docker.io
sudo usermod -aG docker $USER

# --- INSTALL NVIDIA DOCKER (if GPU exists) ---
if command -v nvidia-smi &> /dev/null; then
    echo "🟩 NVIDIA GPU detected — installing nvidia-docker2..."
    distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
    curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
    curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list \
        | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
    sudo apt update
    sudo apt install -y nvidia-docker2
    sudo systemctl restart docker
else
    echo "🟨 No NVIDIA GPU detected — skipping nvidia-docker"
fi

# --- CREATE AUTOWARE WORKSPACE ---
echo "📁 Creating Autoware workspace..."
mkdir -p ~/autoware_ws/src
cd ~/autoware_ws/src

git clone https://github.com/autowarefoundation/autoware.universe.git

# --- INSTALL AUTOWARE DEPENDENCIES ---
echo "📦 Installing rosdep dependencies..."
cd ~/autoware_ws
rosdep update
rosdep install -y --from-paths src --ignore-src --rosdistro humble

# --- BUILD AUTOWARE ---
echo "🔨 Building Autoware (this may take 20–40 minutes)..."
colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release

echo "source ~/autoware_ws/install/setup.bash" >> ~/.bashrc
source ~/.bashrc

# --- INSTALL SAMPLE MAPS ---
echo "🗺 Downloading sample HD map..."
cd ~/autoware_ws
git clone https://github.com/autowarefoundation/autoware-map-sample.git maps

# --- OPTIONAL: SVL SIM CONNECTOR ---
echo "🔌 Installing SVL Simulator ROS 2 bridge..."
cd ~/autoware_ws/src
git clone https://github.com/lgsvl/AutowareBridge.git

cd ~/autoware_ws
colcon build --packages-select AutowareBridge

echo "==============================================="
echo "     ✅ AUTOWARE SETUP COMPLETED SUCCESSFULLY "
echo "==============================================="
echo "Log out & log back in to activate Docker group."
echo "Use this to launch Autoware:"
echo "    source ~/autoware_ws/install/setup.bash"
echo "    ros2 launch autoware_launch planning_simulator.launch.xml"
echo "==============================================="
