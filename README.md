# Studio Data Saver

Studio Data Saver is a native macOS app for archiving large studio folders without first copying the whole source folder onto the iMac.

It is designed for workflows like:

```text
Windows PC or network drive -> iMac work folder -> Studio NAS
```

The app copies normal project files directly to the destination, stages only the active video jobs on the iMac, encodes those videos with HandBrakeCLI, moves the finished outputs to the destination, and remembers progress so interrupted work can continue.

## Quick Start

For most people:

1. Download `Studio Data Saver.zip` from the latest GitHub Release.
2. Unzip it.
3. Move `Studio Data Saver.app` to `/Applications`.
4. Install the video tools:

```sh
brew install handbrake ffmpeg
```

5. Open the app, choose your source, destination, and iMac work folder, then press **Start**.

## Features

- Native SwiftUI macOS app
- Apple Silicon build
- Project queue
- Resume after app stop or Mac restart
- Skip files that are already saved in the destination
- Copy non-video files while videos encode
- Stage only active videos on the iMac
- Plain-language run log
- Export controls for compression, resolution, and frame rate
- Optional cleanup controls for source files and iMac temp copies
- Codex-friendly app data in `~/Library/Application Support/Studio Data Saver/`

## Download the App

Download the latest `Studio Data Saver.zip` from GitHub Releases.

Unzip it, move `Studio Data Saver.app` to `/Applications`, then open it. If macOS blocks the first launch because the app is not notarized yet, right-click the app and choose **Open**.

## Requirements

- macOS 14 or newer
- Apple Silicon Mac
- HandBrakeCLI
- ffprobe from FFmpeg

Install video tools with Homebrew:

```sh
brew install handbrake ffmpeg
```

Studio Data Saver does not bundle HandBrakeCLI or FFmpeg. They stay separate system tools.

## Build From Source

```sh
git clone https://github.com/DhananjayBhosale/studio-data-saver.git
cd studio-data-saver
./scripts/build_app.sh
open "dist/Studio Data Saver.app"
```

## Package

```sh
./scripts/package_release.sh
```

This creates a zip file in `dist/` that can be attached to a GitHub Release.

## How It Works

1. Choose a source folder.
2. Choose a destination folder.
3. Choose an iMac work folder.
4. Pick how many videos should encode at the same time.
5. Press **Start**.

For network sources, the app copies only the active video jobs to the iMac work folder. It does not copy a full 1 TB source folder locally before starting.

## Data and Resume

App data is saved here:

```text
~/Library/Application Support/Studio Data Saver/
```

That folder contains project settings, recent runs, structured events, and per-file resume records.

## License

Studio Data Saver source code is released under the MIT License. See [LICENSE](LICENSE).

Third-party tools and credits are listed in [NOTICE.md](NOTICE.md).

Thanks to the teams and communities behind Swift, SwiftUI, HandBrake, FFmpeg, Homebrew, GitHub Actions, and OpenAI Codex. This project is not affiliated with HandBrake, FFmpeg, Apple, GitHub, or OpenAI.
