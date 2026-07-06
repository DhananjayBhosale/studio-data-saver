import SwiftUI

extension RunEvent {
    var typeLabel: String {
        switch type {
        case "error", "copy_fail", "video_fail", "source_delete_fail":
            "ERROR"
        case "copy", "stage":
            "COPIED"
        case "encode_start":
            "ENCODE"
        case "video":
            "MOVED"
        case "copy_skip", "video_skip", "destination_keep":
            "SKIPPED"
        case "copy_skip_space", "video_skip_space", "stage_skip_space":
            "SPACE"
        case "complete":
            "DONE"
        case "source_delete":
            "DELETED"
        default:
            "INFO"
        }
    }

    var consoleMessage: String {
        switch type {
        case "plan":
            "Checking source folder"
        case "plan_ready":
            "Found \(detail)"
        case "resume_ready":
            "Resume check ready"
        case "copy":
            "Copied files: \(detail)"
        case "copy_skip":
            "\(fileName) is already saved"
        case "copy_skip_space":
            "Not enough destination space for \(fileName)"
        case "copy_fail":
            "Could not copy \(fileName): \(detail)"
        case "stage":
            "Copied \(fileName) to iMac"
        case "encode_start":
            "Encoding \(fileName)"
        case "video":
            "Moved \(fileName) to destination"
        case "video_start":
            detail
        case "video_done":
            "Finished \(detail)"
        case "video_skip":
            "\(fileName) is already encoded"
        case "video_skip_space":
            "Not enough destination space for \(fileName)"
        case "stage_skip_space":
            "Not enough iMac space for \(fileName)"
        case "video_fail":
            "Could not encode \(fileName): \(detail)"
        case "destination_keep":
            "Kept existing destination file for \(fileName)"
        case "cleanup":
            "Cleaned up unfinished work"
        case "work_keep":
            "Kept iMac temp copies"
        case "source_delete":
            "Deleted original \(fileName)"
        case "source_delete_fail":
            "Could not delete original \(fileName): \(detail)"
        case "complete":
            "Project complete"
        case "stopped":
            "Stopped after the current file"
        case "error":
            "Something went wrong: \(detail)"
        default:
            detail.isEmpty ? fileName : detail
        }
    }

    var tint: Color {
        switch typeLabel {
        case "ERROR":
            StudioPalette.danger
        case "COPIED", "ENCODE", "MOVED", "DONE", "DELETED":
            StudioPalette.accent
        case "SPACE":
            StudioPalette.warning
        case "SKIPPED":
            StudioPalette.cyan
        default:
            StudioPalette.secondaryText(.dark)
        }
    }

    private var fileName: String {
        guard !path.isEmpty else { return "file" }
        let name = URL(fileURLWithPath: path).lastPathComponent
        return name.isEmpty ? path : name
    }
}
