# Architecture

Studio Data Saver is intentionally simple:

- SwiftUI views in `StudioDataSaverSwift/Sources/Features`
- app state in `StudioDataSaverSwift/Sources/Store`
- project/run models in `StudioDataSaverSwift/Sources/Models`
- file scanning, resume records, copying, and encoding in `StudioDataSaverSwift/Sources/Services`
- shared visual constants in `StudioDataSaverSwift/Sources/DesignSystem`

## Runtime Flow

1. A project stores source, destination, work folder, export settings, cleanup settings, and parallel video count.
2. A run scans the source folder and builds a plan.
3. Normal files copy directly to the destination.
4. Videos are processed in a small worker queue.
5. Network videos are staged to the iMac work folder one active job at a time.
6. HandBrakeCLI encodes each video.
7. Finished outputs move to the destination.
8. The per-file ledger records what happened.

## Resume

Per-file resume records live in:

```text
~/Library/Application Support/Studio Data Saver/ledgers/
```

On a later run, the app checks both the ledger and the destination folder. Files already saved are skipped, and incomplete work is retried.

## External Tools

The app does not link to HandBrake or FFmpeg libraries. It launches their command-line tools when needed:

- `HandBrakeCLI`
- `ffprobe`
