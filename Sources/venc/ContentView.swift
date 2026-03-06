import SwiftUI
import UniformTypeIdentifiers
import AppKit

struct ContentView: View {
    @State private var inputPath = ""
    @State private var resizeEnabled = false
    @State private var resizeWidth = "1280"
    @State private var resizeHeight = "720"
    @State private var codec: Codec = .hevc
    @State private var quality: Double = 66
    @State private var audio: AudioOption = .copy

    private var command: String {
        CommandBuilder.build(
            inputPath: inputPath,
            resizeEnabled: resizeEnabled,
            resizeWidth: resizeWidth,
            resizeHeight: resizeHeight,
            codec: codec,
            quality: Int(quality),
            audio: audio
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            // File picker
            GroupBox("Input") {
                HStack {
                    Image(systemName: "film")
                        .foregroundStyle(.secondary)
                    Text(inputPath.isEmpty ? "No file selected" : (inputPath as NSString).lastPathComponent)
                        .foregroundStyle(inputPath.isEmpty ? .secondary : .primary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .help(inputPath)
                    Button("Browse\u{2026}") { pickFile() }
                }
            }

            // Encoding options
            GroupBox("Encoding") {
                VStack(alignment: .leading, spacing: 12) {

                    // Resize
                    Toggle("Resize", isOn: $resizeEnabled)
                    if resizeEnabled {
                        HStack(spacing: 6) {
                            TextField("W", text: $resizeWidth)
                                .frame(width: 64)
                            Text("\u{00d7}")
                                .foregroundStyle(.secondary)
                            TextField("H", text: $resizeHeight)
                                .frame(width: 64)
                            Text("px")
                                .foregroundStyle(.secondary)
                        }
                        .padding(.leading, 20)
                    }

                    Divider()

                    // Codec
                    HStack {
                        Text("Codec")
                        Spacer()
                        Picker("Codec", selection: $codec) {
                            ForEach(Codec.allCases) { c in
                                Text(c.rawValue).tag(c)
                            }
                        }
                        .labelsHidden()
                        .pickerStyle(.segmented)
                        .fixedSize()
                    }

                    // Quality
                    HStack {
                        Text("Quality")
                        Slider(value: $quality, in: 1...100, step: 1)
                        Text("\(Int(quality))")
                            .monospacedDigit()
                            .frame(width: 28, alignment: .trailing)
                    }

                    Divider()

                    // Audio
                    HStack {
                        Text("Audio")
                        Spacer()
                        Picker("Audio", selection: $audio) {
                            ForEach(AudioOption.allCases) { a in
                                Text(a.rawValue).tag(a)
                            }
                        }
                        .labelsHidden()
                        .pickerStyle(.segmented)
                        .fixedSize()
                    }
                }
            }

            // Command output
            GroupBox("Command") {
                HStack(alignment: .top) {
                    Text(command.isEmpty ? "Select an input file to generate a command." : command)
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(command.isEmpty ? .secondary : .primary)
                        .textSelection(.enabled)
                        .lineLimit(nil)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Button("Copy") { copyToClipboard() }
                        .disabled(command.isEmpty)
                }
            }
        }
        .padding()
        .frame(minWidth: 480)
    }

    private func pickFile() {
        let panel = NSOpenPanel()
        panel.directoryURL = URL(fileURLWithPath: NSHomeDirectory() + "/Downloads")
        panel.allowedContentTypes = [
            UTType.mpeg4Movie,
            UTType.quickTimeMovie,
            UTType.avi,
            UTType.mpeg,
            UTType(filenameExtension: "m4v") ?? .mpeg4Movie,
        ]
        panel.allowsOtherFileTypes = true
        if panel.runModal() == .OK, let url = panel.url {
            inputPath = url.path(percentEncoded: false)
        }
    }

    private func copyToClipboard() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(command, forType: .string)
    }
}
