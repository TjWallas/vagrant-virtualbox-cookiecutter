#!/bin/bash
# Using env bash is considered harmful:
# https://unix.stackexchange.com/questions/206350/what-is-the-difference-if-i-start-bash-with-bin-bash-or-usr-bin-env-bash

# https://sipb.mit.edu/doc/safe-shell/
# GLOBBING IS NOT ALLOWED!!
set -euf -o pipefail

# http://redsymbol.net/articles/unofficial-bash-strict-mode/
IFS=$'\n\t'

# --- Helper scripts begin ---
# https://dev.to/thiht/shell-scripts-matter

#/ Usage:
#/ Description:
#/ Examples:
#/ Options:
#/   --help: Display this help message
usage() { grep '^#/' "$0" | cut -c4- ; exit 0 ; }
expr "$*" : ".*--help" > /dev/null && usage

readonly LOG_FILE="/tmp/$(basename "$0").log"
readonly DATE_FORMAT="%Y-%m-%d %H:%M:%S.%N"
info()    { echo "[`date +$DATE_FORMAT`] [INFO]    $*" | tee -a "$LOG_FILE" >&2 ; }
warning() { echo "[`date +$DATE_FORMAT`] [WARNING] $*" | tee -a "$LOG_FILE" >&2 ; }
error()   { echo "[`date +$DATE_FORMAT`] [ERROR]   $*" | tee -a "$LOG_FILE" >&2 ; }
fatal()   { echo "[`date +$DATE_FORMAT`] [FATAL]   $*" | tee -a "$LOG_FILE" >&2 ; exit 1 ; }

cleanup() {
    # Remove temporary files
    # Restart services
    # ...
    info "Cleaning up before exit..."
}

assert_running_as_root() {
  if [[ ${EUID} -ne 0 ]]; then
      fatal "This script must be run as root!"
  fi
}

assert_command_is_available() {
  local cmd=${1}
  type ${cmd} >/dev/null 2>&1 || fatal "Cancelling because required command '${cmd}' is not available."
}

_get_abs_script_path() {
    SOURCE="${BASH_SOURCE[0]}"
    while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
      DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
      SOURCE="$(readlink "$SOURCE")"
      [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
    done
    DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
    FILENAME=$(basename "$0") # This does not consider if the script was a symlink
    ABS_SCRIPT_PATH="$DIR/$FILENAME"
}


# --- Helper scripts end ---

# https://stackoverflow.com/questions/2853803/in-a-shell-script-echo-shell-commands-as-they-are-executed
# set -x

# Code begins here...

update_apt_sources() {

    # Apt keys
    info "Adding apt keys..."
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 93C4A3FD7BB9C367

    # Apt repos
    info "Adding apt repos..."
    echo "deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main" > /etc/apt/sources.list.d/ansible.list

    # Update apt
    info "Updating apt..."
    apt-get install -y apt-transport-https ca-certificates wget software-properties-common
    apt-get update
}

install_ansible() {
    apt-get -y install ansible
}

main() {

    # Script goes here
    # Important global vars:
    #  $ABS_SCRIPT_PATH
    #  $DIR : Script full dir path
    #  $FILENAME: Script filename
    # ...
    assert_running_as_root
    export DEBIAN_FRONTEND=noninteractive
    update_apt_sources
    install_ansible
    return
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
    trap cleanup EXIT
    _get_abs_script_path
    main
fi

