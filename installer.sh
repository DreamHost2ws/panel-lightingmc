#!/usr/bin/env bash
set -e

VERSION="1.3.0"
INSTALL_DIR="/var/www/panel"

DOWNLOAD_URL="https://filesapi.lovable.app/api/public/files/9bf1f6b1-8a92-4bd7-b138-e2a2ec3e5a55"

GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
NC="\033[0m"

echo -e "${BLUE}"
echo "========================================"
echo "        Panel Installer v${VERSION}"
echo "========================================"
echo -e "${NC}"

if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Run as root.${NC}"
    exit 1
fi

echo -e "${YELLOW}Updating packages...${NC}"
apt update

echo -e "${YELLOW}Installing dependencies...${NC}"
apt install -y \
curl \
wget \
unzip \
ca-certificates \
software-properties-common

if ! command -v git >/dev/null 2>&1; then
    echo -e "${YELLOW}Installing git...${NC}"
    apt install -y git
fi

if ! command -v node >/dev/null 2>&1; then
    echo -e "${YELLOW}Installing Node.js 22...${NC}"
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
    apt install -y nodejs
fi

echo -e "${YELLOW}Installing JDK 25...${NC}"
if ! java -version >/dev/null 2>&1 || ! javac -version >/dev/null 2>&1; then
    apt install -y wget gpg apt-transport-https
    wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor -o /etc/apt/trusted.gpg.d/adoptium.gpg
    echo "deb https://packages.adoptium.net/artifactory/deb bookworm main" | tee /etc/apt/sources.list.d/adoptium.list
    apt update
    apt install -y temurin-25-jdk
fi

mkdir -p "$INSTALL_DIR"

echo -e "${YELLOW}Downloading Panel v${VERSION}...${NC}"

curl -L "$DOWNLOAD_URL" -o /tmp/panel.zip

echo -e "${YELLOW}Extracting files...${NC}"
rm -rf "${INSTALL_DIR:?}"/*
unzip -o /tmp/panel.zip -d "$INSTALL_DIR"

cd "$INSTALL_DIR"

if [ -f package.json ]; then
    echo -e "${YELLOW}Installing npm packages...${NC}"
    npm install

    if npm run | grep -q build; then
        echo -e "${YELLOW}Building panel...${NC}"
        npm run build
    fi
fi

echo -e "${YELLOW}Installing PM2...${NC}"
npm install pm2@latest -g

echo -e "${YELLOW}Starting panel with PM2...${NC}"
pm2 start app.js --name panel
pm2 startup
pm2 save

echo
echo -e "${GREEN}========================================"
echo "Minecraft Panel v${VERSION} installed successfully!"
echo "Location: $INSTALL_DIR"
echo "Service : panel"
echo "Panel will auto-start on system boot"
echo ""
echo "Minecraft Panel running on http://localhost:3000"
echo ""
echo If You want Addons Of Panel dm @devaru007
echo "========================================${NC}"
