# Studio Data Saver 0.3.10

Studio Data Saver is a native macOS app that helps you shrink large video folders and copy the complete folder safely to another drive, backup disk, or NAS.

Video compression is powered by `HandBrakeCLI` from the open-source HandBrake project. Studio Data Saver adds the app workflow around it: queueing, copying, temporary work files, resume records, progress logs, and cleanup choices.

## What It Does

- Compresses videos using HandBrakeCLI from HandBrake
- Copies normal files like project files, photos, audio, documents, captions, and thumbnails without changing them
- Uses a temporary Mac work folder only for the active video jobs
- Avoids copying a huge source folder to the Mac all at once
- Can resume after the app stops or the Mac restarts
- Skips files that are already saved in the destination
- Shows a simple log with copying, encoding, moving, and saved-space progress

## Before Opening

Install the video tools first:

```sh
brew install handbrake ffmpeg
```

HandBrakeCLI and FFmpeg are not bundled in the app. They are installed separately so their own licenses stay clear.

Download the DMG, open it, then drag `Studio Data Saver.app` to Applications. If macOS blocks the first launch because the app is not notarized yet, right-click `Studio Data Saver.app` and choose **Open**.

## Credits

The video compression engine is HandBrakeCLI from HandBrake:

- https://handbrake.fr/
- https://github.com/HandBrake/HandBrake

Studio Data Saver also uses `ffprobe` from FFmpeg for video checks.

This project is not affiliated with HandBrake, FFmpeg, Apple, GitHub, or OpenAI.
