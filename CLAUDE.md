# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ccstatusline is a customizable status line formatter for Claude Code CLI that displays model info, git branch, token usage, and other metrics. It functions as both:
1. A piped command processor for Claude Code status lines
2. An interactive TUI configuration tool when run without input

## Development Commands

```bash
# Install dependencies
bun install

# Run in interactive TUI mode
bun run start

# Test with piped input (use [1m] suffix for 1M context models)
echo '{"model":{"id":"claude-sonnet-4-5-20250929[1m]"},"transcript_path":"test.jsonl"}' | bun run src/ccstatusline.ts

# Or use example payload
bun run example

# Build for npm distribution
bun run build   # Creates dist/ccstatusline.js with Node.js 14+ compatibility

# Run tests
bun test

# Run tests in watch mode
bun test --watch

# Lint and type check
bun run lint   # Runs TypeScript type checking and ESLint with auto-fix
```

## Architecture

The project has dual runtime compatibility - works with both Bun and Node.js:

### Core Structure
- **src/ccstatusline.ts**: Main entry point that detects piped vs interactive mode
  - Piped mode: Parses JSON from stdin and renders formatted status line
  - Interactive mode: Launches React/Ink TUI for configuration

### TUI Components (src/tui/)
- **index.tsx**: Main TUI entry point that handles React/Ink initialization
- **App.tsx**: Root component managing navigation and state
- **components/**: Modular UI components for different configuration screens
  - MainMenu, LineSelector, ItemsEditor, ColorMenu, GlobalOverridesMenu
  - PowerlineSetup, TerminalOptionsMenu, StatusLinePreview

### Utilities (src/utils/)
- **config.ts**: Settings management
  - Loads from `~/.config/ccstatusline/settings.json`
  - Handles migration from old settings format
  - Default configuration if no settings exist
- **renderer.ts**: Core rendering logic for status lines
  - Handles terminal width detection and truncation
  - Applies colors, padding, and separators
  - Manages flex separator expansion
- **powerline.ts**: Powerline font detection and installation
- **claude-settings.ts**: Integration with Claude Code settings.json
  - Respects `CLAUDE_CONFIG_DIR` environment variable with fallback to `~/.claude`
  - Provides installation command constants (NPM, BUNX, self-managed)
  - Detects installation status and manages settings.json updates
  - Validates config directory paths with proper error handling
- **colors.ts**: Color definitions and ANSI code mapping
- **model-context.ts**: Model-to-context-window mapping
  - Maps model IDs to their context window sizes based on [1m] suffix
  - Sonnet 4.5 WITH [1m] suffix: 1M tokens (800k usable at 80%) - requires long context beta access
  - Sonnet 4.5 WITHOUT [1m] suffix: 200k tokens (160k usable at 80%)
  - Legacy models: 200k tokens (160k usable at 80%)

### Widgets (src/widgets/)
Custom widgets implementing the Widget interface defined in src/types/Widget.ts:

**Widget Interface:**
All widgets must implement:
- `getDefaultColor()`: Default color for the widget
- `getDescription()`: Description shown in TUI
- `getDisplayName()`: Display name shown in TUI
- `getEditorDisplay()`: How the widget appears in the editor
- `render()`: Core rendering logic that produces the widget output
- `supportsRawValue()`: Whether widget supports raw value mode
- `supportsColors()`: Whether widget supports color customization
- Optional: `renderEditor()`, `getCustomKeybinds()`, `handleEditorAction()`

**Widget Registry Pattern:**
- Located in src/utils/widgets.ts
- Uses a Map-based registry (`widgetRegistry`) that maps widget type strings to widget instances
- `getWidget(type)`: Retrieves widget instance by type
- `getAllWidgetTypes()`: Returns all available widget types
- `isKnownWidgetType()`: Validates if a type is registered

**Available Widgets:**
- Model, Version, OutputStyle - Claude Code metadata display
- GitBranch, GitChanges, GitWorktree - Git repository status
- TokensInput, TokensOutput, TokensCached, TokensTotal - Token usage metrics
- ContextLength, ContextPercentage, ContextPercentageUsable - Context window metrics (uses dynamic model-based context windows: 1M for Sonnet 4.5 with [1m] suffix, 200k for all other models)
- BlockTimer, SessionClock, SessionCost - Time and cost tracking
- CurrentWorkingDir, TerminalWidth - Environment info
- CustomText, CustomCommand - User-defined widgets

## Key Implementation Details

- **Cross-platform stdin reading**: Detects Bun vs Node.js environment and uses appropriate stdin API
- **Token metrics**: Parses Claude Code transcript files (JSONL format) to calculate token usage
- **Git integration**: Uses child_process.execSync to get current branch and changes
- **Terminal width management**: Three modes for handling width (full, full-minus-40, full-until-compact)
- **Flex separators**: Special separator type that expands to fill available space
- **Powerline mode**: Optional Powerline-style rendering with arrow separators
- **Custom commands**: Execute shell commands and display output in status line
- **Mergeable items**: Items can be merged together with or without padding

## Ghostty Terminal Integration

ccstatusline has special integration with [Ghostty terminal](https://ghostty.org/) for color alignment and automatic theme switching:

### Gruvbox Theme Alignment

The `gruvbox` and `gruvbox-light` powerline themes use **exact color values** from Ghostty's official Gruvbox Dark and Gruvbox Light themes:

**Gruvbox Dark Colors** (from ghostty's iTerm2-Color-Schemes):
- Background: `#282828`, Foreground: `#EBDBB2`
- Palette: Red `#CC241D`, Green `#98971A`, Yellow `#D79921`, Blue `#458588`, Magenta `#B16286`, Cyan `#689D6A`
- Bright colors: Yellow `#FABD2F`, Gray `#A89984`, etc.

**Gruvbox Light Colors**:
- Background: `#FBF1C7`, Foreground: `#3C3836`
- Palette: Uses inverted Gruvbox colors optimized for light backgrounds

### Automatic Light/Dark Mode Switching

**Location**: `src/utils/appearance-detector.ts`

When using `gruvbox` or `gruvbox-light` powerline themes, ccstatusline automatically detects macOS system appearance and switches themes:

- **Dark Mode** → Uses `gruvbox` theme
- **Light Mode** → Uses `gruvbox-light` theme

This matches Ghostty's dual-theme behavior: `theme = dark:Gruvbox Dark,light:Gruvbox Light`

**How it works**:
1. Reads macOS appearance setting via `defaults read -g AppleInterfaceStyle`
2. Resolves theme at render time (no config changes needed)
3. Only applies to Gruvbox themes (other themes unchanged)
4. Falls back to dark mode on non-macOS systems

### Color Extraction Methodology

Ghostty themes are sourced from the [mbadolato/iTerm2-Color-Schemes](https://github.com/mbadolato/iTerm2-Color-Schemes) repository, which provides standardized color definitions for 500+ terminal themes. ccstatusline's Gruvbox themes use these exact palette values to ensure pixel-perfect color matching with Ghostty.

### Related Documentation

For more about Ghostty configuration and terminal features, see the [ghostty-config repository](https://github.com/yourusername/ghostty-config) documentation, specifically:
- `docs/config-reference.md` - Complete Ghostty configuration options
- `docs/integration-ccstatusline.md` - Detailed integration guide

## Bun Usage Preferences

Default to using Bun instead of Node.js:
- Use `bun <file>` instead of `node <file>` or `ts-node <file>`
- Use `bun install` instead of `npm install`
- Use `bun run <script>` instead of `npm run <script>`
- Use `bun build` with appropriate options for building
- Bun automatically loads .env, so don't use dotenv

## Important Notes

- **ink@6.2.0 patch**: The project uses a patch for ink@6.2.0 to fix backspace key handling on macOS
  - Issue: ink treats `\x7f` (backspace on macOS) as delete key instead of backspace
  - Fix: Patches `build/parse-keypress.js` to correctly map `\x7f` to backspace
  - Applied automatically during `bun install` via `patchedDependencies` in package.json
  - Patch file: `patches/ink@6.2.0.patch`
- **Build process**: Two-step build using `bun run build`
  1. `bun build`: Bundles src/ccstatusline.ts into dist/ccstatusline.js targeting Node.js 14+
  2. `postbuild`: Runs scripts/replace-version.ts to replace `__PACKAGE_VERSION__` placeholder with actual version from package.json
- **ESLint configuration**: Uses flat config format (eslint.config.js) with TypeScript and React plugins
- **Dependencies**: All runtime dependencies are bundled using `--packages=external` for npm package
- **Type checking and linting**: Only run via `bun run lint` command, never using `npx eslint` or `eslint` directly. Never run `tsx`, `bun tsc` or any other variation
- **Lint rules**: Never disable a lint rule via a comment, no matter how benign the lint warning or error may seem
- **Testing**: Uses Vitest (via Bun) with 6 test files and ~40 test cases covering:
  - Model context detection and token calculation (src/utils/__tests__/model-context.test.ts)
  - Context percentage calculations (src/utils/__tests__/context-percentage.test.ts)
  - JSONL transcript parsing (src/utils/__tests__/jsonl.test.ts)
  - Widget rendering (src/widgets/__tests__/*.test.ts)
  - Run tests with `bun test` or `bun test --watch` for watch mode
  - Test configuration: vitest.config.ts
  - Manual testing also available via piped input and TUI interaction
