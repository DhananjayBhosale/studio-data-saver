# Studio Data Saver

Studio Data Saver is a native macOS app that helps you shrink large video folders and copy the complete folder safely to another drive, backup disk, or NAS.

It keeps normal files like project files, photos, audio, documents, captions, and thumbnails as they are. Videos are compressed with `HandBrakeCLI`, the command-line tool from the open-source HandBrake project. Studio Data Saver adds a simple queue, a temporary work folder, resume tracking, and plain-language logs around that video engine.

## Powered by HandBrakeCLI

Video compression in Studio Data Saver is done by `HandBrakeCLI` from [HandBrake](https://handbrake.fr/).

Studio Data Saver is not a video encoder by itself. It is a folder-saving workflow app that uses HandBrakeCLI for the actual video conversion, then handles folder copying, queueing, progress tracking, resume records, and cleanup choices around it.

HandBrakeCLI is not bundled with this app. Users install it separately.

## Quick Start

For most people:

1. Download `Studio Data Saver.zip` from the latest GitHub Release.
2. Unzip it.
3. Move `Studio Data Saver.app` to `/Applications`.
4. Install the video tools:

```sh
brew install handbrake ffmpeg
```

5. Open the app, choose the folder you want to save, where to save it, and a temporary Mac work folder, then press **Start**.

## Features

- Native SwiftUI macOS app
- Apple Silicon build
- Video compression powered by HandBrakeCLI
- Copy all non-video files without changing them
- Project queue
- Resume after app stop or Mac restart
- Skip files that are already saved in the destination
- Copy non-video files while videos encode
- Stage only active videos on the Mac
- Plain-language run log
- Export controls for compression, resolution, and frame rate
- Optional cleanup controls for source files and Mac temp copies
- Codex-friendly app data in `~/Library/Application Support/Studio Data Saver/`

## Download the App

Download the latest `Studio Data Saver.zip` from GitHub Releases.

Unzip it, move `Studio Data Saver.app` to `/Applications`, then open it. If macOS blocks the first launch because the app is not notarized yet, right-click the app and choose **Open**.

## Requirements

- macOS 14 or newer
- Apple Silicon Mac
- HandBrakeCLI from HandBrake
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

Owner publishing steps are in [docs/PUBLISHING.md](docs/PUBLISHING.md).

## How It Works

1. Choose a source folder.
2. Choose a destination folder.
3. Choose a temporary Mac work folder.
4. Pick how many videos should encode at the same time.
5. Press **Start**.

If the source folder is huge, the app does not copy the whole folder to the Mac before starting. It stages only the active video jobs, compresses them with HandBrakeCLI, saves the finished files to the destination, and keeps moving through the queue.

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
