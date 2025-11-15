import { execSync } from 'child_process';

/**
 * Detects macOS system appearance (Dark Mode or Light Mode)
 *
 * @returns 'dark' if Dark Mode is enabled, 'light' otherwise
 *
 * @example
 * const appearance = getMacOSAppearance();
 * if (appearance === 'dark') {
 *   // Use dark theme
 * } else {
 *   // Use light theme
 * }
 */
export function getMacOSAppearance(): 'dark' | 'light' {
    // Only works on macOS
    if (process.platform !== 'darwin') {
        return 'dark'; // Default to dark on non-macOS systems
    }

    try {
        // Read macOS appearance setting
        // Returns "Dark" if Dark Mode is enabled, otherwise command fails
        const result = execSync('defaults read -g AppleInterfaceStyle 2>/dev/null', {
            encoding: 'utf-8',
            stdio: ['pipe', 'pipe', 'pipe']
        }).trim();

        return result === 'Dark' ? 'dark' : 'light';
    } catch {
        // Command fails when Light Mode is active (setting doesn't exist)
        return 'light';
    }
}

/**
 * Resolves a theme name based on macOS appearance
 *
 * Automatically switches between 'gruvbox' and 'gruvbox-light' themes
 * based on system appearance. Other themes pass through unchanged.
 *
 * @param themeName - The configured theme name
 * @returns The resolved theme name based on system appearance
 *
 * @example
 * const theme = resolveThemeForAppearance('gruvbox');
 * // Returns 'gruvbox' in Dark Mode, 'gruvbox-light' in Light Mode
 *
 * const theme2 = resolveThemeForAppearance('nord');
 * // Returns 'nord' regardless of appearance (no auto-switching)
 */
export function resolveThemeForAppearance(themeName: string): string {
    // Only auto-switch for gruvbox themes
    if (themeName !== 'gruvbox' && themeName !== 'gruvbox-light') {
        return themeName;
    }

    const appearance = getMacOSAppearance();

    // Auto-select appropriate gruvbox variant
    if (appearance === 'dark') {
        return 'gruvbox';
    } else {
        return 'gruvbox-light';
    }
}