#!/bin/bash
# Claude Code Linux Mint Setup - Tool Installation Script
# Run with: bash install-claude-tools-mint.sh

set -e  # Exit on error

echo "=========================================="
echo "Claude Code Linux Mint Tool Installation"
echo "=========================================="

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[+]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# ==========================================
# PART 1: System Packages
# ==========================================
print_status "Updating package lists..."
sudo apt update

print_status "Upgrading existing packages..."
sudo apt upgrade -y

print_status "Installing core text processing tools..."
sudo apt install -y \
    ripgrep \
    fd-find \
    jq \
    pandoc \
    wdiff \
    colordiff \
    tree \
    bat \
    fzf

print_status "Installing spell checking tools..."
sudo apt install -y \
    aspell \
    hunspell \
    hunspell-en-us

print_status "Installing git and git-lfs..."
sudo apt install -y git git-lfs
git lfs install

print_status "Installing Python..."
sudo apt install -y \
    python3 \
    python3-pip \
    python3-venv

print_status "Installing Calibre (ebook tools)..."
sudo apt install -y calibre

print_status "Installing archive utilities..."
sudo apt install -y zip unzip

# ==========================================
# PART 2: Python Writing Tools
# ==========================================
print_status "Setting up Python virtual environment for writing tools..."

if [ -d "$HOME/.writing-tools" ]; then
    print_warning "Python venv already exists at ~/.writing-tools"
else
    python3 -m venv ~/.writing-tools
fi

print_status "Installing Python packages..."
source ~/.writing-tools/bin/activate

pip install --upgrade pip

pip install \
    nltk \
    textstat \
    ebooklib \
    pypdf \
    pdfplumber \
    python-docx \
    markdown \
    beautifulsoup4 \
    lxml \
    pyyaml \
    chardet \
    ftfy

deactivate

# ==========================================
# PART 3: Node.js via NVM
# ==========================================
print_status "Installing NVM (Node Version Manager)..."

if [ -d "$HOME/.nvm" ]; then
    print_warning "NVM already installed"
else
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
fi

# Load NVM for this script
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

print_status "Installing Node.js LTS..."
nvm install --lts
nvm use --lts

print_status "Installing global Node packages..."
npm install -g prettier markdownlint-cli

# ==========================================
# PART 4: Create utility scripts directory
# ==========================================
print_status "Setting up ~/.local/bin for utility scripts..."
mkdir -p ~/.local/bin

# Add to PATH if not already there
if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' ~/.bashrc; then
    echo '' >> ~/.bashrc
    echo '# Local bin directory' >> ~/.bashrc
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
fi

# ==========================================
# PART 5: Create utility scripts
# ==========================================
print_status "Creating word count tracker script..."
cat > ~/.local/bin/wc-tracker << 'EOF'
#!/bin/bash
# Track daily word counts for a project

PROJECT_DIR="${1:-.}"
LOG_FILE="$PROJECT_DIR/.wordcount-log.csv"
TODAY=$(date +%Y-%m-%d)

# Count words in all markdown files
TOTAL=$(find "$PROJECT_DIR" -name "*.md" -exec cat {} + 2>/dev/null | wc -w)

# Initialize log if needed
if [[ ! -f "$LOG_FILE" ]]; then
    echo "date,words,change" > "$LOG_FILE"
fi

# Get yesterday's count
YESTERDAY=$(tail -1 "$LOG_FILE" 2>/dev/null | cut -d',' -f2)
YESTERDAY=${YESTERDAY:-0}

# Calculate change
CHANGE=$((TOTAL - YESTERDAY))

# Log today's count
echo "$TODAY,$TOTAL,$CHANGE" >> "$LOG_FILE"

echo "Today: $TOTAL words (${CHANGE:+$CHANGE} from last entry)"
EOF
chmod +x ~/.local/bin/wc-tracker

print_status "Creating manuscript backup script..."
cat > ~/.local/bin/manuscript-backup << 'EOF'
#!/bin/bash
# Create timestamped backup of manuscript

SRC="${1:-.}"
BACKUP_DIR="${2:-$SRC/backups}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="manuscript_$TIMESTAMP.tar.gz"

mkdir -p "$BACKUP_DIR"
tar -czf "$BACKUP_DIR/$BACKUP_NAME" \
    --exclude="backups" \
    --exclude=".git" \
    --exclude="node_modules" \
    -C "$(dirname "$SRC")" "$(basename "$SRC")"

echo "Backup created: $BACKUP_DIR/$BACKUP_NAME"

# Keep only last 10 backups
ls -t "$BACKUP_DIR"/manuscript_*.tar.gz 2>/dev/null | tail -n +11 | xargs rm -f 2>/dev/null
EOF
chmod +x ~/.local/bin/manuscript-backup

print_status "Creating prose analysis script..."
cat > ~/.local/bin/prose-analyze << 'EOF'
#!/usr/bin/env python3
"""Quick prose analysis for manuscripts."""

import re
import sys
from collections import Counter

def analyze(text):
    words = text.split()
    sentences = [s.strip() for s in re.split(r'[.!?]+', text) if s.strip()]
    paragraphs = [p.strip() for p in text.split('\n\n') if p.strip()]

    word_count = len(words)
    sentence_count = len(sentences)
    avg_sentence = word_count / sentence_count if sentence_count else 0

    # Issues
    passive = re.findall(r'\b(was|were|been|being|is|are|am)\s+\w+ed\b', text, re.I)
    adverbs = re.findall(r'\b\w+ly\b', text)
    filter_words = re.findall(r'\b(felt|saw|heard|noticed|realized|wondered|thought|knew|watched|looked|seemed)\b', text, re.I)

    # Repeated sentence starters
    starters = [s.split()[0].lower() if s.split() else '' for s in sentences]
    repeated_starters = [word for word, count in Counter(starters).items() if count > 2 and word]

    print(f"Words: {word_count:,}")
    print(f"Sentences: {sentence_count:,}")
    print(f"Paragraphs: {len(paragraphs):,}")
    print(f"Avg sentence length: {avg_sentence:.1f} words")
    print(f"Est. pages (250w/p): {word_count / 250:.1f}")
    print()
    print(f"Passive voice: {len(passive)}")
    print(f"Adverbs (-ly): {len(adverbs)}")
    print(f"Filter words: {len(filter_words)}")
    if repeated_starters:
        print(f"Repeated starters: {', '.join(repeated_starters)}")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        with open(sys.argv[1], 'r') as f:
            analyze(f.read())
    else:
        analyze(sys.stdin.read())
EOF
chmod +x ~/.local/bin/prose-analyze

# ==========================================
# PART 6: Aliases for convenience
# ==========================================
print_status "Adding helpful aliases to .bashrc..."

if ! grep -q '# Claude Code aliases' ~/.bashrc; then
    cat >> ~/.bashrc << 'EOF'

# Claude Code aliases
alias docs='cd ~/Documents'
alias writing='cd ~/Documents/Writing'

# fd is installed as fdfind on Debian/Ubuntu/Mint
alias fd='fdfind'

# bat is installed as batcat on Debian/Ubuntu/Mint
alias bat='batcat'

# Activate writing tools Python env
alias pywrite='source ~/.writing-tools/bin/activate'
EOF
fi

# ==========================================
# DONE
# ==========================================
echo ""
echo "=========================================="
print_status "Installation complete!"
echo "=========================================="
echo ""
echo "To apply changes, run:"
echo "  source ~/.bashrc"
echo ""
echo "New commands available:"
echo "  wc-tracker [dir]     - Track word counts over time"
echo "  manuscript-backup    - Create timestamped backups"
echo "  prose-analyze [file] - Analyze prose for issues"
echo ""
echo "Aliases added:"
echo "  docs      - cd to Documents folder"
echo "  writing   - cd to Writing folder"
echo "  pywrite   - activate Python writing tools"
echo "  fd        - alias for fdfind"
echo "  bat       - alias for batcat"
echo ""
echo "Python writing tools are in: ~/.writing-tools"
echo "Activate with: source ~/.writing-tools/bin/activate"
echo ""
