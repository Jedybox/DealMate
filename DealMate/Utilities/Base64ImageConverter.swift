import UIKit

/// Utilities for converting base64-encoded image strings into `UIImage`.
/// Put general-purpose image-conversion helpers here so multiple views can reuse them.
enum Base64ImageConverter {
    /// Convert a base64 string (optionally with a data URL prefix) into a UIImage.
    /// - Parameter base64: The base64 payload or a full data URL like "data:image/png;base64,..."
    /// - Returns: A `UIImage` if decoding succeeds, otherwise nil.
    static func image(from base64: String) -> UIImage? {
        var payload = base64.trimmingCharacters(in: .whitespacesAndNewlines)

        // Strip data URL prefix if present: data:[<mediatype>][;base64],<data>
        if let commaIndex = payload.firstIndex(of: ",") {
            let prefix = String(payload[..<commaIndex])
            if prefix.contains("base64") {
                payload = String(payload[payload.index(after: commaIndex)...])
            }
        }

        // Some servers include whitespace/newlines — remove them for safe decoding
        let cleaned = payload.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\r", with: "")

        guard let data = Data(base64Encoded: cleaned, options: .ignoreUnknownCharacters) else {
            return nil
        }

        return UIImage(data: data)
    }

    /// Convert base64 string to UIImage asynchronously (wrapper for potential future work).
    static func imageAsync(from base64: String) async -> UIImage? {
        return image(from: base64)
    }
}
