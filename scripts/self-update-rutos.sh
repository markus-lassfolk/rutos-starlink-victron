#!/bin/sh
# self-update.sh: Checks for new version and updates scripts if needed
# Usage: ./scripts/self-update.sh

set -eu

# shellcheck disable=SC2034
REPO_URL="https://github.com/markus-lassfolk/rutos-starlink-failover"
# shellcheck disable=SC2034
RAW_URL="https://raw.githubusercontent.com/markus-lassfolk/rutos-starlink-failover/main"
# shellcheck disable=SC2034
INSTALL_DIR="/root/starlink-monitor"
# shellcheck disable=SC2034
VERSION_FILE="$INSTALL_DIR/VERSION"
# shellcheck disable=SC2034
TMP_VERSION="/tmp/starlink-latest-version.txt"

# Check if terminal supports colors (simplified for RUTOS compatibility)
if [ -t 1 ] && [ "${TERM:-}" != "dumb" ] && [ "${NO_COLOR:-}" != "1" ]; then
    # shellcheck disable=SC2034
    RED='\033[0;31m'
    # shellcheck disable=SC2034
    GREEN='\033[0;32m'
    # shellcheck disable=SC2034
    YELLOW='\033[1;33m'
    # shellcheck disable=SC2034
    BLUE='\033[1;35m'
    # shellcheck disable=SC2034
    CYAN='\033[0;36m'
    # shellcheck disable=SC2034
    NC='\033[0m'
else
    # Fallback to no colors if terminal doesn't support them
    # shellcheck disable=SC2034
    RED=""
    # shellcheck disable=SC2034
    GREEN=""
    # shellcheck disable=SC2034
    YELLOW=""
    # shellcheck disable=SC2034
    BLUE=""
    # shellcheck disable=SC2034
    CYAN=""
    # shellcheck disable=SC2034
    NC=""
fi

get_local_version() {
    [ -f "$VERSION_FILE" ] && cat "$VERSION_FILE" || echo "0.0.0"
}

get_remote_version() {
    curl -fsSL "$RAW_URL/VERSION" -o "$TMP_VERSION" && cat "$TMP_VERSION" || echo "0.0.0"
}

version_gt() {
    # Returns 0 if $1 > $2
    [ "$1" = "$2" ] && return 1
    [ "$(printf '%s\n%s' "$1" "$2" | sort -V | head -n1)" = "$2" ]
}

main() {
    echo "Checking for updates..."
    local_version=$(get_local_version)
    remote_version=$(get_remote_version)
    echo "Local version: $local_version"
    echo "Remote version: $remote_version"
    if version_gt "$remote_version" "$local_version"; then
        echo "${YELLOW}Update available!${NC}"
        echo "Run: $INSTALL_DIR/scripts/upgrade.sh to update."
        exit 2
    else
        echo "${GREEN}You are up to date.${NC}"
        exit 0
    fi
}

main "$@"
