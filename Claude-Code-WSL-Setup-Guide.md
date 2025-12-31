# Claude Code WSL Setup Guide for Fiction Writing & Development

A comprehensive guide for optimizing Claude Code in WSL2 on Windows 11, focused on fiction writing projects, text processing, and code analysis.

---

## Part 1: Essential WSL Utilities

### Core Text Processing Tools

```bash
# Update package lists
sudo apt update && sudo apt upgrade -y

# Essential text processing
sudo apt install -y \
    ripgrep \          # Fast grep replacement (Claude uses this internally)
    fd-find \          # Fast find replacement
    jq \               # JSON processing (essential for hooks)
    pandoc \           # Universal document converter (markdown, docx, epub, etc.)
    wdiff \            # Word-by-word diff (great for manuscript comparison)
    colordiff \        # Colorized diff output
    tree \             # Directory structure visualization
    bat \              # Better cat with syntax highlighting
    fzf                # Fuzzy finder

# Text statistics and analysis
sudo apt install -y \
    wc \               # Word/line/character counts (usually pre-installed)
    aspell \           # Spell checking
    hunspell \         # Alternative spell checker with better dictionaries
    hunspell-en-us \   # English dictionary
    wordnet \          # Lexical database for synonyms/definitions
    libreoffice-writer # For docx conversion (optional, large)
```

### Python Environment (for scripting)

```bash
# Python and pip
sudo apt install -y python3 python3-pip python3-venv

# Create a virtual environment for writing tools
python3 -m venv ~/.writing-tools
source ~/.writing-tools/bin/activate

# Text processing libraries
pip install \
    nltk \              # Natural language toolkit
    textstat \          # Readability statistics
    language-tool-python \  # Grammar checking
    ebooklib \          # EPUB creation/manipulation
    pypdf \             # PDF manipulation
    pdfplumber \        # PDF text extraction
    python-docx \       # Word document manipulation
    markdown \          # Markdown processing
    beautifulsoup4 \    # HTML parsing
    lxml \              # XML/HTML processing
    pyyaml \            # YAML processing
    chardet \           # Character encoding detection
    ftfy                # Fix text encoding issues
```

### Node.js Tools (for Claude Code compatibility)

```bash
# Install Node.js via nvm (recommended)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.bashrc
nvm install --lts
nvm use --lts

# Useful global packages
npm install -g \
    prettier \          # Code/markdown formatter
    markdownlint-cli \  # Markdown linting
    @mermaid-js/mermaid-cli  # Diagram generation from text
```

### Ebook Production Tools

```bash
# Calibre CLI tools (ebook conversion)
sudo apt install -y calibre

# Key Calibre commands:
# ebook-convert input.epub output.mobi
# ebook-convert input.docx output.epub
# calibredb add book.epub  # Add to library
# fetch-ebook-metadata -t "Book Title" -a "Author"

# Sigil dependencies (if building from source)
sudo apt install -y \
    cmake \
    qtbase5-dev \
    qttools5-dev \
    qttools5-dev-tools \
    libqt5svg5-dev \
    libhunspell-dev
```

### Git Configuration

```bash
# Essential git setup
sudo apt install -y git

# Configure git
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
git config --global core.autocrlf input  # Important for WSL
git config --global init.defaultBranch main

# Git LFS for large files (manuscript backups, images)
sudo apt install -y git-lfs
git lfs install
```

---

## Part 2: Claude Code Configuration

### Directory Structure

Create the Claude configuration directories:

```bash
# User-level configuration
mkdir -p ~/.claude/skills
mkdir -p ~/.claude/hooks
mkdir -p ~/.claude/rules

# Create the main settings file
touch ~/.claude/settings.json
touch ~/.claude/CLAUDE.md
```

### User Settings (~/.claude/settings.json)

This configuration minimizes permission prompts while maintaining safety:

```json
{
  "permissions": {
    "allow": [
      "Read",
      "Glob",
      "Grep",
      "WebFetch",
      "WebSearch",
      "Bash(python3:*)",
      "Bash(python:*)",
      "Bash(node:*)",
      "Bash(npm run:*)",
      "Bash(npx:*)",
      "Bash(git status:*)",
      "Bash(git diff:*)",
      "Bash(git log:*)",
      "Bash(git branch:*)",
      "Bash(git show:*)",
      "Bash(ls:*)",
      "Bash(cat:*)",
      "Bash(head:*)",
      "Bash(tail:*)",
      "Bash(wc:*)",
      "Bash(tree:*)",
      "Bash(find:*)",
      "Bash(grep:*)",
      "Bash(rg:*)",
      "Bash(fd:*)",
      "Bash(pandoc:*)",
      "Bash(ebook-convert:*)",
      "Bash(calibredb:*)",
      "Bash(aspell:*)",
      "Bash(hunspell:*)",
      "Bash(wordnet:*)",
      "Bash(wdiff:*)",
      "Bash(diff:*)",
      "Bash(mkdir:*)",
      "Bash(cp:*)",
      "Bash(mv:*)",
      "Bash(touch:*)",
      "Bash(chmod:*)",
      "Bash(date:*)",
      "Bash(echo:*)",
      "Bash(printf:*)",
      "Bash(sort:*)",
      "Bash(uniq:*)",
      "Bash(cut:*)",
      "Bash(awk:*)",
      "Bash(sed:*)",
      "Bash(tr:*)",
      "Bash(jq:*)",
      "Bash(curl:*)",
      "Bash(wget:*)",
      "Edit(~/.claude/**)",
      "Edit(/mnt/d/Obsidian_Shared/**)",
      "Edit(/tmp/**)"
    ],
    "ask": [
      "Bash(git add:*)",
      "Bash(git commit:*)",
      "Bash(git push:*)",
      "Bash(git checkout:*)",
      "Bash(git merge:*)",
      "Bash(git rebase:*)",
      "Bash(rm:*)",
      "Bash(sudo:*)"
    ],
    "deny": [
      "Read(/etc/shadow)",
      "Read(/etc/passwd)",
      "Read(~/.ssh/id_*)",
      "Read(~/.aws/**)",
      "Read(**/.env)",
      "Read(**/credentials*)",
      "Read(**/secrets/**)",
      "Bash(rm -rf /)",
      "Bash(dd:*)",
      "Bash(mkfs:*)",
      "Bash(:(){ :|:& };:)"
    ],
    "additionalDirectories": [
      "/mnt/d/Obsidian_Shared/Writing",
      "/mnt/d/Obsidian_Shared/Research",
      "/tmp"
    ],
    "defaultMode": "acceptEdits"
  },
  "model": "claude-sonnet-4-5-20250929",
  "env": {
    "WRITING_ROOT": "/mnt/d/Obsidian_Shared/Writing",
    "RESEARCH_ROOT": "/mnt/d/Obsidian_Shared/Research"
  },
  "cleanupPeriodDays": 30
}
```

### Project-Specific Settings

For your fiction writing project, create `.claude/settings.json` in the project root:

```bash
mkdir -p "/mnt/d/Obsidian_Shared/Writing/The-Craft-of-Fiction/.claude"
```

```json
{
  "permissions": {
    "allow": [
      "Read",
      "Edit(/mnt/d/Obsidian_Shared/Writing/The-Craft-of-Fiction/**)",
      "Bash(wc:*)",
      "Bash(pandoc:*)",
      "Bash(aspell:*)"
    ],
    "defaultMode": "acceptEdits"
  }
}
```

### User Memory File (~/.claude/CLAUDE.md)

```markdown
# Claude Code User Preferences

## Environment
- Running in WSL2 on Windows 11
- Primary work: Fiction writing, manuscript editing, ebook production
- Secondary work: Python/Node.js scripting, code analysis

## File Path Conventions
- Windows paths like `D:\folder` should be converted to `/mnt/d/folder`
- Always use forward slashes in paths
- My writing projects are in `/mnt/d/Obsidian_Shared/Writing/`
- Research materials are in `/mnt/d/Obsidian_Shared/Research/`

## Writing Preferences
- Use Oxford comma
- Prefer active voice explanations
- Keep technical explanations concise
- When analyzing manuscripts: focus on pacing, dialogue, and show-don't-tell

## Code Preferences
- Python: Use type hints, prefer pathlib over os.path
- JavaScript/TypeScript: Use modern ES6+ syntax
- Always include error handling in scripts
- Prefer readable code over clever one-liners

## Common Tasks
- Manuscript word counts: `wc -w filename.md`
- Convert to EPUB: `pandoc input.md -o output.epub --metadata title="Title"`
- Spell check: `aspell check filename.md`
- Find all markdown files: `fd -e md`
```

---

## Part 3: Skills Setup

### Personal Skills Directory

Create reusable skills in `~/.claude/skills/`:

#### Word Count Analysis Skill

```bash
mkdir -p ~/.claude/skills/word-count
```

Create `~/.claude/skills/word-count/SKILL.md`:

```markdown
---
name: word-count
description: Analyze word counts in manuscripts and chapters. Use for tracking writing progress.
allowed-tools: Read, Bash(wc:*), Bash(find:*), Bash(awk:*)
---

# Word Count Analysis

## Quick Commands

### Single file word count
```bash
wc -w "filename.md"
```

### All markdown files in directory
```bash
find . -name "*.md" -exec wc -w {} + | sort -n
```

### Chapter-by-chapter breakdown
```bash
for f in *.md; do echo -n "$f: "; wc -w < "$f"; done | column -t
```

### Exclude front/back matter
```bash
find . -name "[0-9]*.md" -exec wc -w {} + | sort -n
```

## Output Format

Present results as a table:
| Chapter | Words | Running Total |
|---------|-------|---------------|

Include:
- Total word count
- Average chapter length
- Shortest/longest chapters
- Estimated page count (250 words/page)
```

#### Manuscript Format Conversion Skill

```bash
mkdir -p ~/.claude/skills/manuscript-convert
```

Create `~/.claude/skills/manuscript-convert/SKILL.md`:

```markdown
---
name: manuscript-convert
description: Convert manuscripts between formats (md, docx, epub, pdf). Use for ebook production.
allowed-tools: Read, Bash(pandoc:*), Bash(ebook-convert:*)
---

# Manuscript Format Conversion

## Pandoc Conversions

### Markdown to EPUB (with metadata)
```bash
pandoc input.md -o output.epub \
  --metadata title="Book Title" \
  --metadata author="Author Name" \
  --metadata lang="en-US" \
  --toc \
  --toc-depth=2 \
  --epub-chapter-level=1
```

### Markdown to DOCX (standard manuscript format)
```bash
pandoc input.md -o output.docx \
  --reference-doc=manuscript-template.docx
```

### Multiple files to single EPUB
```bash
pandoc 01-*.md 02-*.md 03-*.md -o book.epub \
  --metadata-file=metadata.yaml \
  --toc
```

## Calibre Conversions

### EPUB to MOBI (Kindle)
```bash
ebook-convert input.epub output.mobi
```

### EPUB to AZW3 (Kindle, better formatting)
```bash
ebook-convert input.epub output.azw3
```

## Metadata File Template (metadata.yaml)
```yaml
title: "Book Title"
author: "Author Name"
rights: "Copyright 2025 Author Name"
language: en-US
description: |
  Book description goes here.
```
```

#### Prose Analysis Skill

```bash
mkdir -p ~/.claude/skills/prose-analysis
```

Create `~/.claude/skills/prose-analysis/SKILL.md`:

```markdown
---
name: prose-analysis
description: Analyze prose for readability, style issues, and common problems. Use for manuscript editing.
allowed-tools: Read, Bash(python3:*)
---

# Prose Analysis

## What to Analyze

1. **Readability Metrics**
   - Flesch-Kincaid Grade Level
   - Flesch Reading Ease
   - Average sentence length
   - Average word length

2. **Style Issues**
   - Passive voice instances
   - Adverb overuse (-ly words)
   - Filter words (felt, saw, heard, noticed, realized)
   - Repeated sentence starters
   - Dialogue tag variety

3. **Pacing Indicators**
   - Paragraph length distribution
   - Dialogue-to-narrative ratio
   - Scene break frequency

## Python Analysis Script

```python
import re
from collections import Counter

def analyze_prose(text):
    sentences = re.split(r'[.!?]+', text)
    words = text.split()

    # Basic stats
    word_count = len(words)
    sentence_count = len([s for s in sentences if s.strip()])
    avg_sentence_len = word_count / sentence_count if sentence_count else 0

    # Find issues
    passive = len(re.findall(r'\b(was|were|been|being|is|are|am)\s+\w+ed\b', text, re.I))
    adverbs = len(re.findall(r'\b\w+ly\b', text))
    filter_words = len(re.findall(r'\b(felt|saw|heard|noticed|realized|wondered|thought|knew)\b', text, re.I))

    return {
        'word_count': word_count,
        'avg_sentence_length': round(avg_sentence_len, 1),
        'passive_voice': passive,
        'adverbs': adverbs,
        'filter_words': filter_words
    }
```

## Report Format

Present findings with:
- Summary statistics table
- Top issues to address
- Specific line examples of problems
- Comparison to genre benchmarks
```

---

## Part 4: Useful Hooks

### Auto-Format Markdown After Edits

Add to `~/.claude/settings.json`:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "bash -c 'file=$(cat | jq -r \".tool_input.file_path\"); if [[ \"$file\" == *.md ]]; then npx prettier --write \"$file\" 2>/dev/null || true; fi'"
          }
        ]
      }
    ]
  }
}
```

### Log All File Changes

Create `~/.claude/hooks/log-changes.sh`:

```bash
#!/bin/bash
input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')
tool=$(echo "$input" | jq -r '.tool // empty')

if [[ -n "$file_path" ]]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') | $tool | $file_path" >> ~/.claude/edit-log.txt
fi
```

```bash
chmod +x ~/.claude/hooks/log-changes.sh
```

Add to settings:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/log-changes.sh"
          }
        ]
      }
    ]
  }
}
```

---

## Part 5: MCP Servers (Optional Integrations)

### Useful MCP Servers for Writing

```bash
# GitHub integration (for version control)
claude mcp add --scope user --transport http github https://api.githubcopilot.com/mcp/

# File system access (if needed beyond defaults)
claude mcp add --scope user --transport stdio filesystem -- npx -y @anthropic/mcp-server-filesystem
```

### View Available MCP Servers

```bash
claude mcp list
```

---

## Part 6: Utility Scripts

### Word Count Tracker Script

Create `~/.local/bin/wc-tracker`:

```bash
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
```

```bash
chmod +x ~/.local/bin/wc-tracker
```

### Manuscript Backup Script

Create `~/.local/bin/manuscript-backup`:

```bash
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
```

```bash
chmod +x ~/.local/bin/manuscript-backup
```

---

## Part 7: Quick Reference

### Starting Claude Code

```bash
# Navigate to project and start
cd /mnt/d/Obsidian_Shared/Writing/The-Craft-of-Fiction
claude

# Or start with additional directory access
claude --add-dir /mnt/d/Obsidian_Shared/Research
```

### Useful Slash Commands

| Command | Description |
|---------|-------------|
| `/help` | Show available commands |
| `/config` | Open configuration |
| `/mcp` | Manage MCP server connections |
| `/add-dir <path>` | Add directory access for session |
| `/clear` | Clear conversation history |
| `/compact` | Summarize conversation to save context |

### Common Claude Code Tasks

```
# Word count analysis
"Give me word counts for all chapters in this directory"

# Format conversion
"Convert all markdown files to a single EPUB"

# Prose analysis
"Analyze chapter 5 for passive voice and filter words"

# Research
"Search my Research folder for notes about dialogue"

# Script creation
"Write a Python script to find repeated phrases in my manuscript"
```

---

## Part 8: Troubleshooting

### Permission Issues

If Claude keeps asking for permissions you've already allowed:

1. Check settings file syntax: `cat ~/.claude/settings.json | jq .`
2. Ensure paths use correct format (`/mnt/d/` not `D:\`)
3. Restart Claude Code after changing settings

### WSL Path Issues

```bash
# Convert Windows path to WSL
wslpath -u "D:\Obsidian_Shared\Writing"
# Output: /mnt/d/Obsidian_Shared/Writing

# Convert WSL path to Windows
wslpath -w /mnt/d/Obsidian_Shared/Writing
# Output: D:\Obsidian_Shared\Writing
```

### Performance

If Claude Code is slow:

1. Ensure WSL2 (not WSL1): `wsl --list --verbose`
2. Store working files in WSL filesystem for better I/O
3. Use `.gitignore` to exclude large/binary files from searches

---

## Installation Checklist

- [ ] WSL2 installed and updated
- [ ] Core text tools installed (ripgrep, pandoc, jq, etc.)
- [ ] Python environment set up with writing libraries
- [ ] Node.js installed via nvm
- [ ] Calibre CLI tools installed
- [ ] `~/.claude/settings.json` configured
- [ ] `~/.claude/CLAUDE.md` created with preferences
- [ ] Skills created in `~/.claude/skills/`
- [ ] Utility scripts added to `~/.local/bin/`
- [ ] `~/.local/bin` added to PATH in `~/.bashrc`

Add to `~/.bashrc`:
```bash
export PATH="$HOME/.local/bin:$PATH"
```
