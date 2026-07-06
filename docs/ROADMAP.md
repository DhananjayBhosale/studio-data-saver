# Studio Data Saver Product Plan

## Direction

Studio Data Saver should feel like a local, inspectable workspace app:
projects on the left, one focused run in the center, and logs/state that can be
opened by an AI assistant when something needs debugging.

The app should stay practical and dense. No marketing screen, no decorative
dashboard. First screen should be the working console.

## App Shape

- Projects: saved source/destination/work-folder groups.
- Runs: each execution is a resumable run inside a project.
- Queue: each queued folder stores its own source type, destination, status,
  and resume state.
- Inspector: selected run shows plan, active files, failures, output folder,
  and verification status.
- Logs: human-readable live log plus structured JSONL events.

## AI-Friendly Data

Store app data under:

`~/Library/Application Support/Studio Data Saver/`

Suggested layout:

```text
Studio Data Saver/
  projects.json
  projects/
    <project-id>/
      project.json
      runs/
        <run-id>/
          run.json
          events.jsonl
          failures.json
          plan.json
          report.txt
```

Each run should be debuggable by an AI assistant without opening the GUI:

- `project.json`: source/destination/work paths and user settings.
- `run.json`: status, timestamps, selected mode, parallel jobs.
- `plan.json`: expected direct files and videos.
- `events.jsonl`: append-only events for copy/compress/verify/failure.
- `failures.json`: file-level failures with retry/skip state.

## Visual Language

- Left sidebar: projects and recent runs.
- Main pane: selected project/run workflow.
- Bottom/side inspector: live output, failures, resume controls.
- Status chips: Queued, Running, Paused, Failed, Complete.
- Actions stay explicit: Scan, Test, Execute, Pause, Resume, Retry Failed.

## Build Path

1. Current `.app` wrapper for local use.
2. Move settings/state to Application Support.
3. Add projects and run history.
4. Add structured resume files.
5. Package with PyInstaller or Briefcase for a self-contained `.app`.
6. Create signed `.dmg` for sharing.
