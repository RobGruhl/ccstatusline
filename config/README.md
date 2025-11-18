# Configuration Files

This directory contains the default configuration for ccstatusline.

## Files

- **settings.json** - Your ccstatusline configuration (widgets, powerline theme, etc.)
- **claude-settings-snippet.json** - Snippet to add to `~/.claude/settings.json`

## Setup on a New Machine

### 1. Install ccstatusline

```bash
# Clone your fork
git clone https://github.com/RobGruhl/ccstatusline.git
cd ccstatusline

# Install dependencies
bun install

# Build the project
bun run build
```

### 2. Copy ccstatusline Configuration

```bash
# Create config directory
mkdir -p ~/.config/ccstatusline

# Copy your settings
cp config/settings.json ~/.config/ccstatusline/settings.json
```

### 3. Configure Claude Code

Add this to your `~/.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "bunx ccstatusline"
  }
}
```

**Note:** If you prefer to use your local build instead of bunx, use:
```json
{
  "statusLine": {
    "type": "command",
    "command": "node /path/to/ccstatusline/dist/ccstatusline.js"
  }
}
```

### 4. Verify Setup

Start a new Claude Code session and you should see your custom status line!

## Customization

To customize your status line:

1. Run the TUI: `bun run statusline` or `bunx ccstatusline`
2. Make your changes in the interactive interface
3. Settings are automatically saved to `~/.config/ccstatusline/settings.json`
4. Copy updated settings back to this repo: `cp ~/.config/ccstatusline/settings.json config/settings.json`
5. Commit and push to keep your configuration in sync across machines

## Current Configuration

This configuration includes:

- **Widgets:**
  - Current working directory (fish-style)
  - Git branch
  - Git changes
  - Session clock
  - Context percentage (magenta background)
  - Wall clock

- **Powerline:**
  - Enabled with Nord Aurora theme
  - Auto-alignment for Ghostty terminal
  - Arrow separators ()

- **Display:**
  - Flex mode: full-minus-40 (leaves 40 chars for input)
  - Compact threshold: 60 chars
  - 256-color support (colorLevel: 3)
