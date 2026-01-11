# SimpleVenom

<<<<<<< HEAD
**Contact:**
[Discord](https://discord.gg/6zEu3hC9uR)
=======
SimpleVenom is a robust wrapper for generating Metasploit payloads, offering three different user interfaces: GUI (Zenity), TUI (Dialog), and a standard CLI Shell. It automatically detects your installed tools to provide the best possible experience.
>>>>>>> patch-1

## Features

<<<<<<< HEAD
## Download & Usage

### Fast build, it's used for development.
```sh
git clone https://github.com/ByCh4n/SimpleVenom && cd SimpleVenom
cargo run
```

## Thanks To

Nickname | GitHub Link
--- | --- 
**ByCh4n**  | [*ByCh4n*](https://github.com/ByCh4n/)
**lazypwny** | [*lazypwny751*](https://github.com/lazypwny751)

## Screenshots of the Tool
=======
- **Multi-Interface Support**:
  - **GUI Mode**: Full graphical interface using `zenity`.
  - **TUI Mode**: Terminal-based menu interface using `dialog`.
  - **Shell Mode**: Interactive command-line wizard.
- **Smart Auto-Detection**: Automatically selects the best available interface.
- **Dependency Management**: Checks for required tools at startup.
- **Payload Support**: Easily generate payloads for Windows, Android, and Linux.

## Requirements

This script relies on `msfvenom` (part of the Metasploit Framework) for payload generation.

### Essential
- `metasploit-framework`

### Optional (For Interface Modes)
- `zenity` (for GUI mode)
- `dialog` (for TUI mode)

## Installation

```bash
git clone https://github.com/ByCh4n/SimpleVenom
cd SimpleVenom
chmod +x simplevenom.sh
./simplevenom.sh
```

## Usage

You can run the script without arguments to let it auto-detect the best mode, or force a specific mode using flags:

```bash
./simplevenom.sh [OPTIONS]
```
>>>>>>> patch-1

### Options

| Flag | Description |
|------|-------------|
| `-g`, `--gui` | Force GUI Mode (Zenity) |
| `-t`, `--tui` | Force TUI Mode (Dialog) |
| `-s`, `--shell` | Force Shell Mode (CLI) |
| `-h`, `--help` | Show help message |
| `-v`, `--version` | Show version information |

## Examples

**Run in GUI mode explicitly:**
```bash
./simplevenom.sh --gui
```

**Get help:**
```bash
./simplevenom.sh --help
```

## Developers

- **ByCh4n**
- **lazypwny**

## License
<<<<<<< HEAD
[MIT](https://choosealicense.com/licenses/mit/)
=======

This project is licensed under the [GPL-3.0 License](https://choosealicense.com/licenses/gpl-3.0/).
>>>>>>> patch-1
