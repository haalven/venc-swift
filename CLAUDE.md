# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What is venc

A macOS SwiftUI app that generates ffmpeg commands for hardware-accelerated video encoding using Apple VideoToolbox. Users pick a video file, configure codec/quality/resize/audio options, and get a ready-to-copy ffmpeg command.

## Build & Run

```bash
# Build (debug)
swift build

# Build (release) and assemble .app bundle
./build-app.sh

# Run the app bundle
open venc.app
```

This is a Swift Package Manager project (swift-tools-version 5.10, macOS 14+). There is no Xcode project — build with `swift build`. No tests or linter are configured.

## Architecture

Three source files in `Sources/venc/`:

- **VencApp.swift** — App entry point. Sets activation policy so the SPM-built binary behaves as a proper GUI app.
- **ContentView.swift** — Single-window SwiftUI view with all UI controls (file picker, codec/quality/audio selectors, resize toggle). Calls `CommandBuilder.build(...)` to produce the command string.
- **CommandBuilder.swift** — Pure logic, no UI. Contains `Codec` and `AudioOption` enums plus `CommandBuilder.build()` which assembles the ffmpeg command string. Also has `shellQuote()` for safe shell escaping.

The app uses VideoToolbox hardware encoders (`hevc_videotoolbox`, `h264_videotoolbox`) and `scale_vt` for GPU-side resize.
