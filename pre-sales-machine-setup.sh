#!/bin/bash

clear
echo "This script is designed to be run on a new Mac to set up the environment for business and development use."
echo "Each step is laid out below:"

SCRIPTS_PATH="${HOME}/.config"
SETUP_SCRIPT_URL="https://raw.githubusercontent.com/MichaelOC23/presales/main/pre-sales-machine-setup.sh"
ENV_SCRIPT="https://raw.githubusercontent.com/MichaelOC23/presales/main/env_variables.sh"
REQ_SCRIPT="https://raw.githubusercontent.com/MichaelOC23/presales/main/requirements.scripts.txt"
# Function to deinitialize a Git repository

show_menu() {
    echo -e "\nSelect an option from the menu:"
    echo -e "    1) Machine One-Time Setup: Homebrew, Python, Git, and Rosetta"
    echo -e "    2) Install Business Applications"
    echo -e "    3) Install Development Applications"
    
    echo -e "${PURPLE}    4) Recreate the python virtual environment  ${NC}"
    echo -e "${PURPLE}    5) Set Ollama Env Variables (one-time)  ${NC}"
    echo -e "${PURPLE}    6) Update Configuraiton (Env_Variables)  ${NC}"
    echo -e "${PURPLE}    7) Install/Upgrade Ollama / Open Web UI  ${NC}"
    
    
    echo -e "${MAGENTA}Press enter to exit.${NC}"
}

# Function to read the user's choice
read_choice() {
    local choice
    read -p "Enter your choice: " choice
    case $choice in
    1)
        option1
        update_env_variables
        ;;
    2)
        option2
        ;;
    3)
        option3
        ;;

    4) 
        dev_env_setup
        update_env_variables
        ;;
    5)
     source env_variables_ollama.sh
     update_env_variables
        exit 0
        ;;
    6)
    update_env_variables
    ;;
    

    7)
    # Fixed Variables
        HOST_OPTION="--add-host=host.docker.internal:host-gateway"
        LLM_DATA="${HOME}/data-llm"
        mkdir -p "${LLM_DATA}"
        
        install_or_upgrade_cask docker
        install_or_upgrade_cask ollama
        
        open -a Docker

        # Function to stop and remove the container if it exists
        stop_and_remove_container() {
            if docker ps -q -f name="$CONTAINER_NAME" >/dev/null; then
                echo "Stopping running container: $CONTAINER_NAME"
                docker stop "$CONTAINER_NAME"
            fi

            if docker ps -aq -f name="$CONTAINER_NAME" >/dev/null; then
                echo "Removing existing container: $CONTAINER_NAME"
                docker rm "$CONTAINER_NAME"
            fi
        }

        # Function to pull the latest Docker image
        pull_latest_image() {
            echo "Pulling the latest image: $IMAGE_NAME"
            docker pull "$IMAGE_NAME"
        }

        # Function to run the Docker container
        run_container_openwebui() {
            docker run -d 
                -p $OPENWEBUI_PORT_MAPPING \
                $HOST_OPTION \
                -v $OPENWEBUI_VOLUME_MAPPING \
                --env OLLAMA_BASE_URL="http://host.docker.internal:11434" \
                --name "$CONTAINER_NAME" \
                --restart always \
                "$IMAGE_NAME"
        }
        
        run_container_pipeline() {
            docker run -d -p 9099:9099 \
                $HOST_OPTION \
                -v ${OPENWEBUI_PIPELINE_DATA}:/app/pipelines \
                --name $CONTAINER_NAME \
                --restart always \
                ghcr.io/open-webui/pipelines:main
        }

        run_container_whisper() {
            docker run -d -p 9099:9099 \
                $HOST_OPTION \
                -v $WHISEPER_LLM_DATA/models:/app/models \
                -v $WHISEPER_LLM_DATA/testdata:/app/testdata \
                --env MODEL=/app/models/ggml-small.bin \
                --name "$CONTAINER_NAME" \
                --restart always \
                "$IMAGE_NAME" 

        }

        # # Process the main open-webui image
        CONTAINER_NAME="open-webui"
        IMAGE_NAME="ghcr.io/open-webui/open-webui:main"
        OPENWEBUI_PORT_MAPPING="3000:8080"
        OPENWEBUI_DATA="${LLM_DATA}/open-webui-data"
        mkdir -p "${OPENWEBUI_DATA}"
        OPENWEBUI_VOLUME_MAPPING="${OPENWEBUI_DATA}:/app/backend/data"
        echo -e "Stopping and removing any OPEN-WEBUI container..."
        stop_and_remove_container
        echo -e "Checking for image updates..."
        pull_latest_image
        echo -e "Starting a new container..."
        run_container_openwebui

        CONTAINER_NAME="pipelines"
        IMAGE_NAME="ghcr.io/open-webui/pipelines:main"
        OPENWEBUI_PIPELINE_DATA="${LLM_DATA}/open-webui-data/pipelines"
        mkdir -p "${OPENWEBUI_PIPELINE_DATA}"
        echo -e "Stopping and removing any existing PIPELINE container..."
        stop_and_remove_container
        echo -e "Checking for PIPELINE image updates..."
        pull_latest_image
        echo -e "Starting a new PIPELINE container..."
        run_container_pipeline

        # CONTAINER_NAME="whisper-docker"
        # WHISEPER_LLM_DATA="${HOME}/data-llm/whisper"
        # mkdir -p "${WHISEPER_LLM_DATA}"
        # IMAGE_NAME="ghcr.io/appleboy/go-whisper:latest"
        # echo -e "Stopping and removing any existing WHISPER container..."
        # stop_and_remove_container
        # echo -e "Checking for WHISPER image updates..."
        # pull_latest_image
        # echo -e "Starting a new WHISPER container..."
        # run_container_whisper


        echo "Container setup complete."
        exit 0
        
    ;;

    *)
        echo "Invalid option."
        echo "Exiting..."
        exit 0
        ;;

    esac
}

option1() {
    echo "You chose Option 1:"
    echo "This will install: Homebrew (a package manager), Python (a package), and Git (version control)"

    # Check if Homebrew is installed, if not, install it
    if ! check_homebrew_installed; then
        install_homebrew
        if ! check_homebrew_installed; then
            echo "Failed to install Homebrew. Cannot proceed with Git installation."
            exit 1
        fi
    fi

    # Check if Git is installed, if not, install it
    if ! check_git_installed; then
        install_git
        # Confirm the installation
        if check_git_installed; then
            echo "Git installation was successful."
        else
            echo "Git installation failed."
            exit 1
        fi
    fi

    # Install Python 3
    install_or_upgrade python3

    eval "$(/opt/homebrew/bin/brew shellenv)"
    source "${SCRIPTS_PATH}/env_variables.sh"
    curl -o "$HOME/.config/env_variables.sh" "${ENV_SCRIPT}"
    grep -qxF "source ${SCRIPT_FOLDER}/env_variables.sh" ~/.zprofile || echo "source ${SCRIPT_FOLDER}/env_variables.sh" >> ~/.zprofile
    
    # Install Rosetta
    echo "Installing Rosetta... this could take a while... please be patient."
    softwareupdate --install-rosetta
}

option2() {
    echo "You chose Option 5:"
    echo "This will install Business Applications"

    # Business Apps
    install_or_upgrade_cask microsoft-office
    install_or_upgrade_cask microsoft-teams
    install_or_upgrade_cask dropbox
    install_or_upgrade_cask chatgpt

    # Browsers
    install_or_upgrade_cask microsoft-edge
    install_or_upgrade_cask google-chrome
    install_or_upgrade_cask firefox
    install_or_upgrade_cask arc
    

    # Design
    install_or_upgrade_cask figma
    install_or_upgrade_cask adobe-creative-cloud

    # Communication Apps
    install_or_upgrade_cask zoom
    
    # Others Michael likes
    # brew install dashlane/tap/dashlane-cli
    # install_or_upgrade_cask vivaldi
    # install_or_upgrade_cask orion
    # install_or_upgrade_cask private-internet-access
    # install_or_upgrade_cask spotify
    

    # Recommended Installs from the Mac App Store: (print text out in CYAN)
    echo -e "${CYAN}Recommended Installs from the Mac App Store:${NC}"
    echo -e "${CYAN}---> Jump Desktop\n---> Daisy Disk\n---> Goodnotes\n---> Enchanted LLM\n{NC}"
    echo -e "${CYAN}---> Parallels\n---> HTML Editor\n---> Actions\n{NC}"
    echo -e "${CYAN}---> Power JSON Editor\n---> Microsoft To Do\n{NC}"
}

option3() {
    # Xcode Command Line Tools
    xcode-select --install

    # Install or upgrade packages and casks
    install_or_upgrade_cask docker
    install_or_upgrade_cask ollama
    # install_or_upgrade github

    # Install node and verify
    install_or_upgrade node
    node -v
    npm -v

    install_or_upgrade_cask visual-studio-code
    
    install_or_upgrade jq
    install_or_upgrade poppler
    
    install_or_upgrade_cask lm-studio
    install_or_upgrade openai-whisper

    install_or_upgrade_cask chromedriver
    install_or_upgrade_cask zed
    install_or_upgrade tesseract
    install_or_upgrade portaudio
    install_or_upgrade ffmpeg
    install_or_upgrade gnu-sed
    install_or_upgrade wget

    # Language Processing
    pip install --upgrade spacy
    pip install --upgrade spacy-lookups-data
    python -m spacy download en_core_web_sm

    # install_or_upgrade_cask dbeaver-community
    # install_or_upgrade_cask sublime-text
    # install_or_upgrade_cask postman
    # install_or_upgrade_cask pgadmin4
    # install_or_upgrade_cask blackhole-2ch
    # install_or_upgrade supabase/tap/supabase
    # install_or_upgrade_cask utm
    # install_or_upgrade_cask google-cloud-sdk    
    # gcloud auth login
    # gcloud config set project toolsexplorationfirebase

    # # Postgres
    # install_or_upgrade postgresql
    # brew services start postgresql
    # brew services stop postgresql
}

clear

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to check if Homebrew is installed
check_homebrew_installed() {
    if brew --version &>/dev/null; then
        echo "Homebrew is already installed."
        return 0
    else
        echo "Homebrew is not installed."
        return 1
    fi
}

# Function to install Homebrew
install_homebrew() {
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to your PATH in /Users/yourname/.zprofile:
    eval "$(/opt/homebrew/bin/brew shellenv)"
}

# Function to check if Git is installed
check_git_installed() {
    if git --version &>/dev/null; then
        echo "Git is already installed."
        return 0
    else
        echo "Git is not installed."
        return 1
    fi
}

# Function to install Git
install_git() {
    echo "Installing Git..."
    brew install git
    # echo "Installing GitHub CLI..."
    # brew install gh
}

# Function to install or upgrade Homebrew packages
install_or_upgrade() {
    if brew list --formula | grep -q "^$1\$"; then
        echo "Upgrading $1..."
        brew upgrade $1
    else
        echo "Installing $1..."
        brew install $1
    fi
}

# Function to install or upgrade Homebrew casks
install_or_upgrade_cask() {
    if brew list --cask | grep -q "^$1\$"; then
        echo "Upgrading $1..."
        brew upgrade --cask $1
    else
        echo "Installing $1..."
        brew install --cask $1
    fi
}

update_env_variables() {
    mkdir -p "${HOME}/.conifg"
    cd "${HOME}/.conifg"
    grep -qxF "source ${SCRIPT_FOLDER}/env_variables.sh" ~/.zprofile || echo "source ${SCRIPT_FOLDER}/env_variables.sh" >> ~/.zprofile
    curl -o "$HOME/.config/env_variables.sh" curl -o "$HOME/.config/env_variables.sh" "${ENV_SCRIPT}"
}

dev_env_setup() {

    update_env_variables
    

    DNAME="scripts"

    # Color Variables for text
    GREEN='\033[0;32m'
    PURPLE='\033[1;34m'
    PINK='\033[0;35m'
    LIGHTBLUE_BOLD='\033[1;36m'
    CYAN='\033[1;96m'
    MAGENTA='\033[1;95m'
    BOLD='\033[1m'
    UNDERLINE='\033[4m'
    BLINK='\033[5m'
    NC='\033[0m' # No Color

    DNAME_LOWER=$(echo "$DNAME" | tr '[:upper:]' '[:lower:]')
    echo "Building Dev Environment for VS Code"
    #Clear the terminal
    clear

    # Get the directory where the script is located
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" # get the directory where the script is located ... full path

    # Get the name of the folder where the script is located
    CURRENT_DIR=$(basename "$SCRIPT_DIR")

    # Print the directory and current folder name
    echo "SCRIPT_DIR: $SCRIPT_DIR"
    echo "CURRENT_DIR: $CURRENT_DIR"

    # Change to that directory
    cd "${SCRIPT_DIR}" || exit 1

    # Name of the virtual environment
    VENV_NAME="${CURRENT_DIR}_venv"

    # Form the name of the virtual environment directory
    VENV_DIR="${SCRIPT_DIR}/${VENV_NAME}"
    echo -e "Virtual environment directory: ${VENV_DIR}\033[0m"

    # Full path to the virtual environment directory
    FULL_VENV_PATH="${SCRIPT_DIR}/${VENV_NAME}"
    echo -e "Full path to virtual environment directory: ${FULL_VENV_PATH}\033[0m"

    # Delete the directory
    rm -rf "${FULL_VENV_PATH}"

    # Create a new virtual environment
    python3 -m venv "/${FULL_VENV_PATH}" || {
        echo -e "\033[1;31mCreating virtual environment at ${FULL_VENV_PATH} failed\033[0m"
        exit 1
    }
    echo -e "\033[1;32mVirtual environment created successfully\033[0m"

    # Change directory
    cd ${FULL_VENV_PATH} || {
        echo -e "\033[1;31mChanging directory failed\033[0m"
        exit 1
    }
    echo -e "\033[1;32mChanged directory successfully\033[0m"

    # Activate the virtual environment
    source "${FULL_VENV_PATH}/bin/activate" || {
        echo -e "\033[1;31mActivating virtual environment failed\033[0m"
        exit 1
    }
    echo -e "\033[1;32mActivated virtual environment successfully\033[0m"

    # Get the path of the requirements file
    REQUIREMENTS_FILE="${REQ_FILE}"
    echo "Requirements file: $REQUIREMENTS_FILE"

    # Upgrade pip
    pip install --upgrade pip || {
        echo -e "\033[1;31mPip upgrade failed\033[0m"
        exit 1
    }
    echo -e "\033[1;32mPip upgrade successful\033[0m"

    # Install requirements
    echo -e "\n\n\033[4;32mProceeding with the installation of all libraries ...\033[0m"
    pip install -r ${REQUIREMENTS_FILE} || {
        echo -e "\033[1;31mRequirements installation failed\033[0m"
        exit 1
    }
    #pip install -r https://example.com/path/to/requirements.txt
    echo -e "\033[1;32mRequirements installation successful\033[0m"

    # ### Change to that directory
    cd "${SCRIPT_DIR}" || exit 1
    # ### Backup current requirements
    mkdir -p .req_backup
    cp ${REQUIREMENTS_FILE} ".req_backup/requirements_raw_$(date +%Y%m%d_%H%M%S).txt" || {
        echo -e "\033[1;31mRequirements backup failed\033[0m"
        exit 1
    }
    echo -e "\033[1;32mRequirements backup successful\033[0m"

    # ### Freeze the current state of packages
    pip freeze >".req_backup/requirements_freeze_$(date +%Y%m%d_%H%M%S).txt" || {
        echo -e "\033[1;31mFreezing requirements failed\033[0m"
        exit 1
    }
    echo -e "\033[1;32mFreezing requirements successful\033[0m"

    echo -e "\033[5;32mInstallation complete\033[0m"

}


        

# Main logic loop
while true; do
    show_menu
    read_choice
done
