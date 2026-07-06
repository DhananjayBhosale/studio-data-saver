# Notices and Credits

Studio Data Saver is released under the MIT License.

This file lists important external tools, platforms, and design credits. It is not legal advice.

## Runtime Tools

### HandBrakeCLI

Studio Data Saver calls `HandBrakeCLI` as an external command-line tool for video encoding.

- Project: https://handbrake.fr/
- Source: https://github.com/HandBrake/HandBrake
- License: GNU General Public License Version 2 (GPLv2)

HandBrakeCLI is not bundled in this repository or inside the app bundle. Users install it separately, for example with Homebrew.

### FFmpeg / ffprobe

Studio Data Saver calls `ffprobe` as an external command-line tool for video checks.

- Project: https://ffmpeg.org/
- Legal and license information: https://ffmpeg.org/legal.html
- License: FFmpeg builds may be LGPL or GPL depending on build configuration and enabled components.

FFmpeg and ffprobe are not bundled in this repository or inside the app bundle. Users install them separately, for example with Homebrew.

## Apple Platform Technologies

Studio Data Saver is built with Swift and SwiftUI for macOS.

- Swift: https://swift.org/
- Swift license: https://swift.org/legal/license.html

SwiftUI, AppKit, macOS SDKs, and SF Symbols are Apple platform technologies used through Xcode/macOS. No Apple framework source code or SF Symbols asset files are copied into this repository.

## Build and Distribution Tools

The repository includes optional GitHub Actions workflow files using GitHub-maintained actions:

- `actions/checkout`
- `actions/upload-artifact`

Homebrew install commands are documented for user convenience. Homebrew is not bundled with the app.

## Development and Design Credits

The app was developed with assistance from OpenAI Codex.

The interface is inspired by compact developer workspace tools, including OpenAI Codex-style panes and terminal-like logs. No OpenAI source code, trademarks, logos, or assets are included. This project is not affiliated with OpenAI.

## App Icon

The `StudioDataSaver.iconset` files are included for this project and may be used under the same MIT License as the app unless replaced by a downstream distributor.
