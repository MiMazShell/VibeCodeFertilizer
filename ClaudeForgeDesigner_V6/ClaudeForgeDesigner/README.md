# ClaudeForgeDesigner

ClaudeForgeDesigner is a starter macOS SwiftUI app that helps a developer generate `Claude.md` and related repo guidance files for Claude Code projects.

## What the app does
- Builds a base `Claude.md` with coding, planning, and Apple-platform best practices.
- Lets the user add reusable trigger phrases and supporting prompt files.
- Creates Apple UI direction text and image prompt files based on a chosen design preset.
- Provides copy/paste-ready GitHub clone commands for HTTPS and SSH.
- Exports all generated files into a selected folder, intended for a cloned GitHub repository.

## Open in Xcode
1. Open `ClaudeForgeDesigner.xcodeproj`.
2. Choose the `ClaudeForgeDesigner` scheme.
3. Run on `My Mac`.

## Suggested next improvements
- Add template packs stored as editable bundled resources.
- Add image asset export and live preview thumbnails.
- Support loading an existing repo folder and diffing generated files.
- Add settings for multiple Claude.md variants by project type.
