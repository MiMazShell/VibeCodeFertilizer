import AppKit
import Foundation

struct ExportService {
    func export(rootFolderName: String, files: [GeneratedFile], requiredFolders: [String], screenshots: [ImportedScreenshot]) throws -> URL? {
        guard !files.isEmpty else { return nil }

        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.prompt = "Choose"
        panel.message = "Choose the destination folder for the generated Claude Code project pack."

        guard panel.runModal() == .OK, let destination = panel.url else {
            return nil
        }

        let fileManager = FileManager.default

        for folder in requiredFolders {
            let targetFolder = destination.appendingPathComponent(folder)
            try fileManager.createDirectory(at: targetFolder, withIntermediateDirectories: true, attributes: nil)
        }

        for file in files {
            let target = destination.appendingPathComponent(file.relativePath)
            try fileManager.createDirectory(at: target.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
            try file.content.write(to: target, atomically: true, encoding: .utf8)
        }

        let screenshotsFolder = destination.appendingPathComponent(rootFolderName).appendingPathComponent("screenshots")
        for screenshot in screenshots {
            let target = screenshotsFolder.appendingPathComponent(screenshot.fileName)
            if fileManager.fileExists(atPath: target.path) {
                try fileManager.removeItem(at: target)
            }
            try fileManager.copyItem(at: screenshot.sourceURL, to: target)
        }

        return destination
    }
}
