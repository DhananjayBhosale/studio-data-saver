# Run Studio Data Saver on macOS

Studio Data Saver is a native macOS app for archiving studio folders while saving disk space.

It copies normal project files directly to the destination, stages only active videos on the iMac, encodes those videos, and remembers progress so a stopped job can continue later.

## Download the app

For normal users, download the latest `Studio Data Saver.zip` from GitHub Releases, unzip it, and move `Studio Data Saver.app` to `/Applications`.

The app is currently ad-hoc signed for local sharing. If macOS blocks the first launch, right-click the app and choose **Open**.

## Install video tools

Studio Data Saver does not bundle HandBrake or FFmpeg. Install them separately:

```sh
brew install handbrake ffmpeg
```

The app uses:

- `HandBrakeCLI` to encode videos
- `ffprobe` to check existing video outputs and verify durations

## Build from source

```sh
./scripts/build_app.sh
open "dist/Studio Data Saver.app"
```

## Package a release zip

```sh
./scripts/package_release.sh
```

The release zip will be written to `dist/`.
