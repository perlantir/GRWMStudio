import Foundation

extension URL {
    /// User documents directory.
    static var documentsURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    /// Local captures directory, created on first access.
    static var documentsCapturesURL: URL {
        let url = documentsURL.appendingPathComponent("captures", isDirectory: true)
        if !FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        }
        return url
    }
}
