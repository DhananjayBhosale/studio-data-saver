import Foundation

enum ArchiveRule {
    static let videoExtensions: Set<String> = ["mp4", "mov", "mxf", "avi", "mkv", "m4v", "mts", "m2ts", "wmv"]

    static func isProxiesFolder(_ name: String) -> Bool {
        matches(name, pattern: "proxies")
    }

    static func isExportFolder(_ name: String) -> Bool {
        matches(name, pattern: "export")
    }

    static func isFinalFile(_ name: String) -> Bool {
        matches(name, pattern: "final")
    }

    static func isProjectFilesFolder(_ name: String) -> Bool {
        matches(name, pattern: "project\\s*files?")
    }

    static func isAutoSaveFolder(_ name: String) -> Bool {
        matches(name, pattern: "auto[-_ ]?save")
    }

    static func isAdobeCacheFolder(_ name: String) -> Bool {
        matches(name, pattern: "video previews|audio previews|motion graphics template")
    }

    static func isSourceClutterFolder(_ name: String) -> Bool {
        isAutoSaveFolder(name) || isAdobeCacheFolder(name) || isProxiesFolder(name)
    }

    static func isVideoFile(_ url: URL) -> Bool {
        videoExtensions.contains(url.pathExtension.lowercased())
            && !url.lastPathComponent.hasSuffix("_PREVIEW_COMPRESSED.mp4")
            && !url.lastPathComponent.hasSuffix(".tmp_compressed.mp4")
    }

    private static func matches(_ text: String, pattern: String) -> Bool {
        text.range(of: pattern, options: [.regularExpression, .caseInsensitive]) != nil
    }
}
