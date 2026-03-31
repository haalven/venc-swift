import Foundation

enum Codec: String, CaseIterable, Identifiable {
    case hevc = "HEVC (h265)"
    case avc = "AVC (h264)"
    case copyVideo = "copy video"
    var id: String { rawValue }
}

enum AudioOption: String, CaseIterable, Identifiable {
    case copy = "copy audio"
    case aac = "AAC"
    case none = "no audio"
    var id: String { rawValue }
}

enum CommandBuilder {

    /// Shell-quote a string, replicating Python's `shlex.quote()`.
    static func shellQuote(_ s: String) -> String {
        if s.isEmpty { return "''" }
        // If string contains only safe characters, return as-is
        let safe = Set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@%+=:,./-_")
        if s.allSatisfy({ safe.contains($0) }) { return s }
        // Wrap in single quotes, escaping any embedded single quotes
        let escaped = s.replacingOccurrences(of: "'", with: "'\"'\"'")
        return "'\(escaped)'"
    }

    static func build(
        inputPath: String,
        resizeEnabled: Bool,
        resizeWidth: String,
        resizeHeight: String,
        codec: Codec,
        quality: Int,
        audio: AudioOption,
        volumeAdjust: Int? = nil
    ) -> String {
        let inp = inputPath.trimmingCharacters(in: .whitespaces)
        guard !inp.isEmpty else { return "" }

        let w = resizeWidth.trimmingCharacters(in: .whitespaces).isEmpty ? "1280" : resizeWidth.trimmingCharacters(in: .whitespaces)
        let h = resizeHeight.trimmingCharacters(in: .whitespaces).isEmpty ? "720" : resizeHeight.trimmingCharacters(in: .whitespaces)

        let vOpts: String
        switch codec {
        case .avc:
            vOpts = "-c:v h264_videotoolbox"
        case .hevc:
            vOpts = "-c:v hevc_videotoolbox -tag:v hvc1"
        case .copyVideo:
            vOpts = "-c:v copy"
        }

        let aOpts: String
        switch audio {
        case .none:
            aOpts = "-an"
        case .aac:
            aOpts = "-c:a aac_at"
        case .copy:
            aOpts = "-c:a copy"
        }

        let outp = inp + ".ffmpeg.mp4"

        var parts = ["ffmpeg"]
        if codec != .copyVideo {
            parts.append(contentsOf: [
                "-hwaccel videotoolbox",
                "-hwaccel_output_format videotoolbox_vld",
            ])
        }
        parts.append("-i \(shellQuote(inp))")
        if codec != .copyVideo && resizeEnabled {
            parts.append("-vf \"scale_vt=w=\(w):h=\(h)\"")
        }
        if audio == .aac, let db = volumeAdjust {
            parts.append("-af \"volume=\(db)dB\"")
        }
        parts.append(vOpts)
        if codec != .copyVideo {
            parts.append("-q:v \(quality)")
        }
        parts.append(contentsOf: [
            aOpts,
            shellQuote(outp),
        ])
        return parts.joined(separator: " ")
    }
}
