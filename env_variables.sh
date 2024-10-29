# #!/bin/bash
# # ENV_VARIABLES.sh


mkdir -p "${HOME}/.config/"
mkdir -p "${HOME}/code/"
mkdir -p "${HOME}/code/scripts"

touch "${HOME}/.config/secrets.sh"
source "${HOME}/.config/secrets.sh"

eval "$(/opt/homebrew/bin/brew shellenv)"

export CONFIG_PATH="${HOME}/.config"
export SCRIPTS_PATH=${CONFIG_PATH}
SCRIPTS_PATH="${HOME}/.config"
SETUP_SCRIPT_URL="https://raw.githubusercontent.com/MichaelOC23/presales/main/pre-sales-machine-setup.sh"
ENV_SCRIPT="https://raw.githubusercontent.com/MichaelOC23/presales/main/env_variables.sh"
REQ_SCRIPT="https://raw.githubusercontent.com/MichaelOC23/presales/main/requirements.scripts.txt"

# PATH export (Standard mac path)
export PATH="/System/Cryptexes/App/usr/bin:/usr/bin:/bin" # Standard Path
export PATH="${PATH}:/usr/sbin:/sbin:/usr/local/bin"      # Standard Path

# Add additional locations to the PATH
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH" # Homebrew (prioritizing it over the system python)
export PATH="${PATH}:${HOME}/code/scripts"               # personal scripts
export PATH="${PATH}:/Applications/geckodriver*"
export PATH="${PATH}:${SCRIPTS_LIVE_PATH}:${SCRIPTS_PATH}:${CONFIG_PATH}"

alias add_spacer="defaults write com.apple.dock persistent-apps -array-add '{\"tile-type\"=\"small-spacer-tile\";}' && killall Dock"
alias source_env="(source ${HOME}/.config/env_variables.sh)"
alias source_scripts="source /Users/michasmi/code/scripts/scripts_venv/bin/activate "
alias cd_scripts="cd ${SCRIPTS_PATH}"
alias python='python3'
alias pip='pip3'


PRESALES_SH="curl -fsSL \"${ENV_SCRIPT}\""
alias presales="/bin/bash -c \"\$( ${PRESALES_SH} )\""


#! # DARK MODE
# export STREAMLIT_THEME_BASE="Custom-Dark"						# Uset this to set a dark or light standard theme
# export STREAMLIT_THEME_FONT="sans serif"                  # Font
# export STREAMLIT_THEME_PRIMARYCOLOR="#98CCD0"             # Accent
# export STREAMLIT_THEME_BACKGROUNDCOLOR="#003366"          # Main Body Background
# export STREAMLIT_THEME_SECONDARYBACKGROUNDCOLOR="#404040" # Sidebar / form background
# export STREAMLIT_THEME_TEXTCOLOR="#CBD9DF"                # Text Color (should contrast well with both Background Color and Secondary Background Color
# export STREAMLIT_LOGO_URL="https://firebasestorage.googleapis.com/v0/b/toolsexplorationfirebase.appspot.com/o/assets%2Flogo-white-gray.svg?alt=media&token=acaa8687-e6ff-42a7-a693-34b34cceefd6"
# export STREAMLIT_ICON_URL="https://firebasestorage.googleapis.com/v0/b/toolsexplorationfirebase.appspot.com/o/assets%2Ficon-white-gray.svg?alt=media&token=5550bb55-23c1-4151-9f35-642a3083f1d0"
# export STREAMLIT_PAGE_ICON="https://firebasestorage.googleapis.com/v0/b/toolsexplorationfirebase.appspot.com/o/assets%2Fpage-icon.svg?alt=media&token=5ecd156a-0371-442f-938e-2f3a3510b344"

#! LIGHT MODE (COMMUNIFY_ISH)
export STREAMLIT_THEME_BASE="light"                # Uset this to set a dark or light standard theme
export STREAMLIT_THEME_FONT="sans serif"                  # Font
export STREAMLIT_THEME_PRIMARYCOLOR="#FFFFFF"             # Accent
export STREAMLIT_THEME_BACKGROUNDCOLOR="#003366"          # Main Body Background
export STREAMLIT_THEME_SECONDARYBACKGROUNDCOLOR="#F3F8FF" # Sidebar / form background
export STREAMLIT_THEME_TEXTCOLOR="#1E1E1E"                # Text Color (should contrast well with both Background Color and Secondary Background Color
export STREAMLIT_LOGO_URL="https://firebasestorage.googleapis.com/v0/b/toolsexplorationfirebase.appspot.com/o/assets%2Flogo-black-gray.svg?alt=media&token=85e3cbba-ef8d-4d8b-9943-88f6b179e1c0"
export STREAMLIT_ICON_URL="https://firebasestorage.googleapis.com/v0/b/toolsexplorationfirebase.appspot.com/o/assets%2Ficon-black-gray.svg?alt=media&token=7ebaedc9-1c3f-45cb-b54f-28741b7067e3"
export STREAMLIT_PAGE_ICON="https://firebasestorage.googleapis.com/v0/b/toolsexplorationfirebase.appspot.com/o/assets%2Fpage-icon.svg?alt=media&token=5ecd156a-0371-442f-938e-2f3a3510b344"


# Set the default editor to Visual Studio Code
export EDITOR="code"

#!/bin/bash

# Function to kill the running Ollama process
kill_ollama() {
    if pgrep -x "ollama" >/dev/null; then
        echo -e "\033[1;33mRestart parameter detected. Killing existing Ollama process...\033[0m"
        pkill -x "ollama"
        sleep 2 # Give it time to shut down
    fi
}

# Check if the 'restart' parameter is passed
if [[ "$1" == "restart" ]]; then
    kill_ollama
fi

# Check if Ollama is already running
if pgrep -x "ollama" >/dev/null; then
    echo -e "\033[1;32mOllama is running.\033[0m"
else
    echo -e "\033[1;34mOllama is not running. Starting ollama serve...\033[0m"

    # Safely create data-llm folder
    LLM_DATA="${HOME}/data-llm"
    mkdir -p "${LLM_DATA}"

    # Safely create temp folder
    OLLAMA_TEMP="${LLM_DATA}/temp"
    mkdir -p "${OLLAMA_TEMP}"

    # Safely create ollama-data folder
    OLLAMA_DATA="${LLM_DATA}/ollama-data"
    mkdir -p "${OLLAMA_DATA}"

    # Export paths as env variables for ollama to utilize
    export OLLAMA_TMPDIR="${OLLAMA_TEMP}"
    export OLLAMA_HOME="${OLLAMA_DATA}"
    export OLLAMA_MODELS="${OLLAMA_DATA}/models"
    export OLLAMA_CACHE_DIR="${OLLAMA_DATA}/cache"

    # Start ollama and redirect output to a log file
    ollama serve >"${LLM_DATA}/ollama.log" 2>&1 &

    # Wait for start to complete
    sleep 2

    if [ $? -eq 0 ]; then
        echo -e "\033[1;32mOllama started successfully. Logs can be found at ${LLM_DATA}/ollama.log\033[0m"
    else
        echo -e "\033[1;31mFailed to start Ollama.\033[0m"
    fi
fi

