# KeyBender

KeyBender is a macOS menu bar app that bends what you type into hex, binary, octal, decimal, Morse, and other encoded text in real time.

## What It Does

KeyBender runs in the menu bar and intercepts typed characters. When a mode is enabled, it replaces each character you type with an encoded version.

Current modes:

- Hex
- Binary
- Octal
- Decimal
- Morse
- Off

Examples:

- `A` -> `\x41` in Hex mode
- `A` -> `01000001` in Binary mode
- `A` -> `65` in Decimal mode
- `A` -> `·− ` in Morse mode

## Requirements

- macOS 13+
- Swift 5.9+
- Accessibility permission enabled for the app

## Install (binary via curl)

Download and install the latest release binary:

```bash
curl -fsSL https://raw.githubusercontent.com/steveswinsburg/keybender/main/install.sh | bash
```

warning: this executes remote code immediately. Use the safer flow below if you prefer to inspect first.

Safer alternative (download, inspect, then run):

```bash
curl -fsSL https://raw.githubusercontent.com/steveswinsburg/keybender/main/install.sh -o install.sh
less install.sh
bash install.sh
```

This installs `KeyBender` to `~/.local/bin/KeyBender` by default.
The installer verifies the downloaded zip using the release SHA-256 checksum.

To install elsewhere:

```bash
curl -fsSL https://raw.githubusercontent.com/steveswinsburg/keybender/main/install.sh | INSTALL_DIR=/usr/local/bin bash
```

`/usr/local/bin` may require elevated privileges.
Example:

```bash
curl -fsSL https://raw.githubusercontent.com/steveswinsburg/keybender/main/install.sh | sudo INSTALL_DIR=/usr/local/bin bash
```

## Run It

```bash
swift run
```

Or build it first:

```bash
swift build
```

Then launch it from the built product or with `swift run`.

## Accessibility Permission

KeyBender needs Accessibility access to intercept and replace keystrokes system-wide.

If macOS blocks it:

1. Open System Settings
2. Go to Privacy & Security
3. Open Accessibility
4. Add and enable the app
5. Relaunch it

## How To Use

1. Launch the app
2. Click the menu bar icon
3. Choose a mode
4. Start typing in any app

Keyboard shortcuts:

- Command-Shift-1: Hex
- Command-Shift-2: Binary
- Command-Shift-3: Octal
- Command-Shift-4: Decimal
- Command-Shift-5: Morse
- Command-Shift-0: Off