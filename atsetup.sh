#!/bin/bash

# ANSI color codes
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
MAGENTA='\033[1;35m'
WHITE='\033[1;37m'
L_RED='\033[1;91m'
L_GREEN='\033[1;92m'
L_YELLOW='\033[1;93m'
L_BLUE='\033[1;94m'
L_CYAN='\033[1;96m'
L_MAGENTA='\033[1;95m'
NC='\033[0m' # No Color

# Navigate to the script's directory
cd "$(dirname "$0")"

# Check if the current directory path contains a space
containsSpace=false
currentPath=$(pwd)
if echo "$currentPath" | grep -q ' '; then
    containsSpace=true
fi

if [ "$containsSpace" = true ]; then
    echo
    echo -e "    ${L_BLUE}ALLTALK LINUX SETUP UTILITY${NC}"
    echo
    echo
    echo -e "    You are trying to install AllTalk in a folder that has a space in the"
    echo -e "    folder path e.g."
    echo 
    echo -e "       /home/${L_RED}program files${NC}/alltalk_tts"
    echo 
    echo -e "    This causes errors with Conda and Python scripts. Please follow this"
    echo -e "    link for reference:"
    echo 
    echo -e "      ${L_CYAN}https://docs.anaconda.com/free/working-with-conda/reference/faq/#installing-anaconda${NC}"
    echo 
    echo -e "    Please use a folder path that has no spaces in it e.g." 
    echo 
    echo -e "       /home/myfiles/alltalk_tts/"
    echo 
    echo
    read -p "Press Enter to continue..." 
    exit 1
else
    # Continue with the main menu
    echo "Continue with the main menu."
fi

install_custom_standalone() {
    cd "$(dirname "${BASH_SOURCE[0]}")"

    if [[ "$(pwd)" =~ " " ]]; then
        echo "This script relies on Miniconda which can not be silently installed under a path with spaces."
        exit
    fi

    # Deactivate existing conda envs as needed to avoid conflicts
    { conda deactivate && conda deactivate && conda deactivate; } 2> /dev/null

    OS_ARCH=$(uname -m)
    case "${OS_ARCH}" in
        x86_64*)    OS_ARCH="x86_64" ;;
        arm64* | aarch64*) OS_ARCH="aarch64" ;;
        *)          echo "Unknown system architecture: $OS_ARCH! This script runs only on x86_64 or arm64" && exit ;;
    esac

    # Config
    INSTALL_DIR="$(pwd)/alltalk_environment"
    CONDA_ROOT_PREFIX="${INSTALL_DIR}/conda"
    INSTALL_ENV_DIR="${INSTALL_DIR}/env"
    MINICONDA_DOWNLOAD_URL="https://repo.anaconda.com/miniconda/Miniconda3-py311_24.4.0-0-Linux-${OS_ARCH}.sh"
    if [ ! -x "${CONDA_ROOT_PREFIX}/bin/conda" ]; then
        echo "Downloading Miniconda from $MINICONDA_DOWNLOAD_URL to ${INSTALL_DIR}/miniconda_installer.sh"
        mkdir -p "${INSTALL_DIR}"
        curl -L "${MINICONDA_DOWNLOAD_URL}" -o "${INSTALL_DIR}/miniconda_installer.sh"
        chmod +x "${INSTALL_DIR}/miniconda_installer.sh"
        bash "${INSTALL_DIR}/miniconda_installer.sh" -b -p "${CONDA_ROOT_PREFIX}"
        echo "Miniconda installed."
    fi

    if [ ! -d "${INSTALL_ENV_DIR}" ]; then
        "${CONDA_ROOT_PREFIX}/bin/conda" create -y --prefix "${INSTALL_ENV_DIR}" -c conda-forge python=3.11.9
        echo "Conda environment created at ${INSTALL_ENV_DIR}."
    fi

    # Activate the environment and install requirements
    source "${CONDA_ROOT_PREFIX}/etc/profile.d/conda.sh"
    conda activate "${INSTALL_ENV_DIR}"
    # pip install torch==2.2.1+cu121 torchaudio==2.2.1+cu121 --upgrade --force-reinstall --extra-index-url https://download.pytorch.org/whl/cu121 --no-cache-dir
    conda install -y pytorch=2.2.1 torchvision torchaudio pytorch-cuda=12.1 -c pytorch -c nvidia
    conda install -y nvidia/label/cuda-12.1.0::cuda-toolkit=12.1
    conda install -y pytorch::faiss-cpu
    conda install -y -c conda-forge "ffmpeg=*=*gpl*"
    conda install -y -c conda-forge "ffmpeg=*=h*_*" --no-deps
    echo
    echo
    echo
    echo "    Fix Nvidia's broken symlinks in the /env/lib folder"
    echo
    # Define the environment path
    env_path="${INSTALL_ENV_DIR}/lib"

    echo "    Installing additional requirements."
    echo
    pip install -r system/requirements/requirements_standalone.txt
    curl -LO https://github.com/erew123/alltalk_tts/releases/download/DeepSpeed-14.0/deepspeed-0.14.2+cu121torch2.2-cp311-cp311-manylinux_2_24_x86_64.whl
    pip install --upgrade gradio==4.44.1
    echo Installing DeepSpeed...
    pip install deepspeed-0.14.2+cu121torch2.2-cp311-cp311-manylinux_2_24_x86_64.whl
    rm deepspeed-0.14.2+cu121torch2.2-cp311-cp311-manylinux_2_24_x86_64.whl
    pip install -r system/requirements/requirements_parler.txt
    conda clean --all --force-pkgs-dirs -y
    # Create start_environment.sh to run AllTalk
    cat << EOF > start_environment.sh
#!/bin/bash
cd "$(dirname "${BASH_SOURCE[0]}")"
if [[ "$(pwd)" =~ " " ]]; then echo This script relies on Miniconda which can not be silently installed under a path with spaces. && exit; fi
# deactivate existing conda envs as needed to avoid conflicts
{ conda deactivate && conda deactivate && conda deactivate; } 2> /dev/null
# config
CONDA_ROOT_PREFIX="$(pwd)/alltalk_environment/conda"
INSTALL_ENV_DIR="$(pwd)/alltalk_environment/env"
# environment isolation
export PYTHONNOUSERSITE=1
unset PYTHONPATH
unset PYTHONHOME
export CUDA_PATH="$INSTALL_ENV_DIR"
export CUDA_HOME="$CUDA_PATH"
# activate env
bash --init-file <(echo "source \"${CONDA_ROOT_PREFIX}/etc/profile.d/conda.sh\" && conda activate $INSTALL_ENV_DIR")
EOF
    cat << EOF > start_alltalk.sh
#!/bin/bash

source ${CONDA_ROOT_PREFIX}/etc/profile.d/conda.sh
conda activate ${INSTALL_ENV_DIR}

python $(pwd)/script.py
EOF
    cat << EOF > start_finetune.sh
#!/bin/bash

export TRAINER_TELEMETRY=0

source ${CONDA_ROOT_PREFIX}/etc/profile.d/conda.sh
conda activate ${INSTALL_ENV_DIR}

python $(pwd)/finetune.py
EOF
    cat << EOF > start_diagnostics.sh
#!/bin/bash

source ${CONDA_ROOT_PREFIX}/etc/profile.d/conda.sh
conda activate ${INSTALL_ENV_DIR}

python $(pwd)/diagnostics.py
EOF
    cat << EOF > start_server.sh
#!/bin/bash

source ${CONDA_ROOT_PREFIX}/etc/profile.d/conda.sh
conda activate ${INSTALL_ENV_DIR}

python $(pwd)/tts_server.py
EOF

    cat << EOF > tts-server.service
[Unit]
Description=TTS Server Service
After=network-online.target
StartLimitIntervalSec=0

[Service]
Type=simple
Restart=always
RestartSec=3
User=$(whoami)
ExecStart=/usr/bin/bash $(pwd)/start_server.sh

[Install]
WantedBy=multi-user.target
EOF
    chmod +x start_alltalk.sh
    chmod +x start_environment.sh
    chmod +x start_finetune.sh
    chmod +x start_diagnostics.sh
    chmod +x start_server.sh

    echo -e "\n${L_GREEN}SETUP COMPLETE${NC}\n"
    echo -e "    Run ${L_YELLOW}./start_alltalk.sh${NC} to start AllTalk."
    echo -e "    Run ${L_YELLOW}./start_diagnostics.sh${NC} to start Diagnostics."
    echo -e "    Run ${L_YELLOW}./start_finetune.sh${NC} to start Finetuning."
    echo -e "    Run ${L_YELLOW}./start_environment.sh${NC} to start the AllTalk Python environment."
    echo -e "    Run ${L_YELLOW}./start_server.sh${NC} to start the AllTalk Server."
}

install_ffmpeg() {
    echo "Installing ffmpeg"

    source $(pwd)/alltalk_environment/conda/etc/profile.d/conda.sh
    
    conda activate $(pwd)/alltalk_environment/env
    conda install -y -c conda-forge ffmpeg
    conda deactivate
}

install_service() {
    echo "TTS System Service"

    echo "Adding TTS Server Service ..."
    echo -e "${L_YELLOW}Enter admin password if requested${NC}"
    sudo mv $(pwd)/tts-server.service /etc/systemd/system/tts-server.service

    echo "Reloading System Service List ..."
    sudo systemctl daemon-reload

    echo "Starting TTS Server ..."
    sudo systemctl start tts-server

    echo "Enabling TTS Server on Boot ..."
    sudo systemctl enable tts-server
}

# Run Installers
install_custom_standalone
install_ffmpeg
install_service