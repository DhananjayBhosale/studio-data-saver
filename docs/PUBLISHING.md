# Publishing Studio Data Saver

These steps are for the repository owner when publishing a new public GitHub repo or release.

## Repository

Name:

```text
studio-data-saver
```

Description:

```text
A macOS app that uses HandBrakeCLI to shrink large video folders, copy everything safely to another drive or NAS, and resume if the work stops.
```

Topics:

```text
macos swift swiftui handbrake ffmpeg video-compression nas archive apple-silicon
```

## First Publish

From the project folder:

```sh
brew install gh
gh auth login
gh repo create DhananjayBhosale/studio-data-saver --public --description "A macOS app that uses HandBrakeCLI to shrink large video folders, copy everything safely to another drive or NAS, and resume if the work stops." --source . --remote origin --push
gh repo edit DhananjayBhosale/studio-data-saver --add-topic macos --add-topic swift --add-topic swiftui --add-topic handbrake --add-topic ffmpeg --add-topic video-compression --add-topic nas --add-topic archive --add-topic apple-silicon
```

If the GitHub repository already exists:

```sh
git remote set-url origin https://github.com/DhananjayBhosale/studio-data-saver.git
git push -u origin main
```

## Release

Build the release zip:

```sh
./scripts/package_release.sh
```

Create the first release:

```sh
gh release create v$(cat VERSION) "dist/Studio Data Saver-$(cat VERSION).zip" "dist/Studio Data Saver-$(cat VERSION).zip.sha256" --title "Studio Data Saver $(cat VERSION)" --notes-file docs/RELEASE.md
```

## Credits

Studio Data Saver is MIT licensed. The app uses external command-line tools that users install separately:

- HandBrakeCLI from HandBrake
- ffprobe from FFmpeg
- Homebrew for simple tool installation
- Swift, SwiftUI, and Apple platform SDKs
- GitHub Actions for optional automated builds
- OpenAI Codex assistance during development

See `NOTICE.md` for details and affiliation notes.

Use `docs/RELEASE_CHECKLIST.md` for the maintainer checklist.
