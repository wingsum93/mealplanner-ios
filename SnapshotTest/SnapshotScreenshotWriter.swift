//
//  SnapshotScreenshotWriter.swift
//  SnapshotTest
//
//  Writes snapshot screenshots directly to the repository screenshots folder.
//

import XCTest

enum SnapshotScreenshotWriter {
    private static let cleanupLock = NSLock()
    private static var didCleanOutputDirectory = false

    static func write(
        _ screenshot: XCUIScreenshot,
        named name: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let outputURL = outputDirectory(sourceFile: file).appendingPathComponent("\(name).png")

        do {
            try prepareOutputDirectory(outputURL.deletingLastPathComponent())
            try screenshot.pngRepresentation.write(to: outputURL, options: .atomic)
        } catch {
            XCTFail("Failed to write screenshot to \(outputURL.path): \(error)", file: file, line: line)
        }
    }

    private static func outputDirectory(sourceFile: StaticString) -> URL {
        if let override = ProcessInfo.processInfo.environment["SNAPSHOT_SCREENSHOTS_DIR"],
           !override.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return URL(fileURLWithPath: (override as NSString).expandingTildeInPath, isDirectory: true)
                .standardizedFileURL
        }

        let sourceURL = URL(fileURLWithPath: String(describing: sourceFile))
        return sourceURL
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("screenshots", isDirectory: true)
            .standardizedFileURL
    }

    private static func prepareOutputDirectory(_ directory: URL) throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        cleanupLock.lock()
        defer { cleanupLock.unlock() }

        guard !didCleanOutputDirectory else { return }

        let existingFiles = try FileManager.default.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: nil
        )

        for file in existingFiles where file.pathExtension == "png" || file.lastPathComponent == "manifest.json" {
            try FileManager.default.removeItem(at: file)
        }

        didCleanOutputDirectory = true
    }
}
