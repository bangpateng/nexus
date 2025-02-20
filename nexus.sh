#!/bin/bash

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to show logo
show_logo() {
   echo "Downloading and displaying logo..."
   curl -s https://raw.githubusercontent.com/bangpateng/logo/main/logo.sh | bash
}

# Show logo at start
show_logo

# Function to print status
print_status() {
   echo -e "${BLUE}=== $1 ===${NC}"
}

# Function to check command status
check_status() {
   if [ $? -eq 0 ]; then
       echo -e "${GREEN}✓ $1 berhasil${NC}"
   else
       echo -e "${RED}✗ $1 gagal${NC}"
       exit 1
   fi
}

# Installation function
install_nexus() {
   print_status "Updating System"
   sudo apt update && sudo apt upgrade -y
   check_status "System update"

   print_status "Installing Screen"
   sudo apt install screen -y
   check_status "Screen installation"

   print_status "Installing Build Essential"
   sudo apt install build-essential pkg-config libssl-dev git-all -y
   check_status "Build Essential installation"

   print_status "Installing Protobuf Compiler"
   sudo apt install -y protobuf-compiler
   check_status "Protobuf compiler installation"

   print_status "Installing Rust"
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
   check_status "Rust installation"

   print_status "Setting up Rust environment"
   source $HOME/.cargo/env
   check_status "Cargo environment setup"

   print_status "Adding riscv32i target"
   rustup target add riscv32i-unknown-none-elf
   check_status "RISCV target installation"

   print_status "Installing Unzip"
   apt install unzip -y
   check_status "Unzip installation"

   print_status "Installing Protoc v21.3"
   wget https://github.com/protocolbuffers/protobuf/releases/download/v21.3/protoc-21.3-linux-x86_64.zip
   check_status "Protoc download"

   unzip protoc-21.3-linux-x86_64.zip -d /usr/local
   check_status "Protoc extraction"

   print_status "Setting up 16GB swap"
   sudo swapoff -a
   sudo fallocate -l 16G /swapfile
   sudo chmod 600 /swapfile
   sudo mkswap /swapfile
   sudo swapon /swapfile
   check_status "Swap setup"

   print_status "Configuring overcommit memory"
   sudo sysctl -w vm.overcommit_memory=1
   echo 'vm.overcommit_memory=1' | sudo tee -a /etc/sysctl.conf
   check_status "Overcommit memory configuration"

   print_status "Starting screen session"
   screen -dmS nexus bash -c 'curl https://cli.nexus.xyz/ | sh'
   check_status "Screen session started"

   print_status "Installation Complete"
   echo -e "${GREEN}To attach to the nexus screen session, use: screen -r nexus${NC}"
}

# Uninstall function
uninstall_nexus() {
   print_status "Uninstalling Nexus"
   
   # Remove screen session if exists
   screen -X -S nexus quit 2>/dev/null
   
   # Remove swap file
   sudo swapoff /swapfile
   sudo rm /swapfile
   
   # Remove Rust and cargo
   rustup self uninstall -y
   
   # Remove protoc
   sudo rm -rf /usr/local/bin/protoc
   sudo rm -rf /usr/local/include/google
   
   # Remove nexus directory
   rm -rf ~/.nexus
   
   # Remove downloaded files
   rm -f protoc-21.3-linux-x86_64.zip
   
   check_status "Uninstallation"
   echo -e "${GREEN}Nexus has been uninstalled successfully${NC}"
}

# Main menu
while true; do
   echo -e "\n${YELLOW}Select an option:${NC}"
   echo "1) Install Nexus"
   echo "2) Uninstall Nexus"
   echo "3) Exit"
   read -p "Enter your choice (1-3): " choice

   case $choice in
       1)
           install_nexus
           break
           ;;
       2)
           uninstall_nexus
           break
           ;;
       3)
           echo -e "${GREEN}Exiting...${NC}"
           exit 0
           ;;
       *)
           echo -e "${RED}Invalid option. Please try again.${NC}"
           ;;
   esac
done
