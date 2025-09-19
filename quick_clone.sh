#!/bin/bash

# Quick clone script for Community Poll Hub
# This script creates a new repository with realistic development history

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Community Poll Hub Repository Cloner${NC}"
echo -e "${BLUE}======================================${NC}"
echo

# Get current directory (source)
SOURCE_DIR="$(pwd)"
echo -e "${YELLOW}📁 Source directory: ${SOURCE_DIR}${NC}"

# Get target directory from user
if [ $# -eq 1 ]; then
    TARGET_DIR="$1"
else
    echo -e "${YELLOW}💭 Enter the path for the new repository:${NC}"
    read -p "Target path: " TARGET_DIR
fi

# Validate target directory
if [ -z "$TARGET_DIR" ]; then
    echo -e "${RED}❌ Error: Target directory cannot be empty${NC}"
    exit 1
fi

# Expand tilde to home directory if present
TARGET_DIR="${TARGET_DIR/#\~/$HOME}"

echo -e "${YELLOW}🎯 Target directory: ${TARGET_DIR}${NC}"
echo

# Confirm with user
echo -e "${YELLOW}⚠️  This will create a new git repository with realistic commit history.${NC}"
echo -e "${YELLOW}   The original repository will remain unchanged.${NC}"
echo
read -p "Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}🛑 Operation cancelled${NC}"
    exit 0
fi

echo -e "${GREEN}✅ Starting repository creation...${NC}"
echo

# Make the Ruby script executable
chmod +x "${SOURCE_DIR}/repo_recreator.rb"

# Run the Ruby script
if ruby "${SOURCE_DIR}/repo_recreator.rb" "$SOURCE_DIR" "$TARGET_DIR"; then
    echo
    echo -e "${GREEN}🎉 Success! Repository created with realistic development history${NC}"
    echo -e "${GREEN}📁 Location: ${TARGET_DIR}${NC}"
    echo
    echo -e "${BLUE}📊 Repository Statistics:${NC}"
    cd "$TARGET_DIR"
    echo -e "${BLUE}   Total commits: $(git rev-list --count HEAD)${NC}"
    echo -e "${BLUE}   First commit: $(git log --reverse --format="%ai" | head -1)${NC}"
    echo -e "${BLUE}   Last commit:  $(git log -1 --format="%ai")${NC}"
    echo
    echo -e "${BLUE}🔍 To view the commit history:${NC}"
    echo -e "${BLUE}   cd ${TARGET_DIR}${NC}"
    echo -e "${BLUE}   git log --oneline${NC}"
    echo
    echo -e "${GREEN}✨ Ready to push to your new remote repository!${NC}"
else
    echo -e "${RED}❌ Error: Repository creation failed${NC}"
    exit 1
fi
