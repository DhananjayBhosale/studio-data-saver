# Release Checklist

1. Update `VERSION`.
2. Run:

   ```sh
   ./scripts/package_release.sh
   ```

3. Test the zip from `dist/` on a clean Mac.
4. Create or update the GitHub Release.
5. Attach:

   - `dist/Studio Data Saver-<version>.zip`
   - `dist/Studio Data Saver-<version>.zip.sha256`

6. Mention that users must install:

   ```sh
   brew install handbrake ffmpeg
   ```

## Signing

By default the build script uses ad-hoc signing:

```sh
CODESIGN_IDENTITY=-
```

For wider distribution, use a Developer ID certificate and notarization.
