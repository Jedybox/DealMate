import UIKit

/// Simple in-memory image cache using NSCache. Decodes base64 on a background queue and caches UIImage.
final class ImageCache {
    static let shared = ImageCache()
    private let cache = NSCache<NSString, UIImage>()
    private init() {
        // Optionally tune cache limits
        cache.countLimit = 200
        cache.totalCostLimit = 1024 * 1024 * 200 // ~200MB
    }

    /// Returns a cached image if available or decodes the base64 string on a background queue.
    /// - Parameters:
    ///   - base64: base64 payload (may be a data URL) or a URL string. 
    ///   - id: optional stable id to key the cache. If nil, uses base64.hashValue.
    func image(forBase64 base64: String, id: String? = nil) async -> UIImage? {
        let keyString = id ?? String(base64.hashValue)
        let key = NSString(string: keyString)
        if let cached = cache.object(forKey: key) {
            // Debug: cache hit
            print("ImageCache: cache hit for key=\(keyString)")
            return cached
        }

        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let trimmed = base64.trimmingCharacters(in: .whitespacesAndNewlines)

                // Heuristic: if it looks like a URL (starts with http:// or https:// or contains ://), try downloading
                if trimmed.lowercased().hasPrefix("http://") || trimmed.lowercased().hasPrefix("https://") || trimmed.contains("://") {
                    if let url = URL(string: trimmed) {
                        do {
                            let data = try Data(contentsOf: url)
                            if let image = UIImage(data: data) {
                                self.cache.setObject(image, forKey: key)
                                print("ImageCache: downloaded image from URL for key=\(keyString)")
                                continuation.resume(returning: image)
                                return
                            } else {
                                print("ImageCache: failed to create UIImage from downloaded data for URL: \(url)")
                            }
                        } catch {
                            print("ImageCache: error downloading image from URL: \(error)")
                        }
                    } else {
                        print("ImageCache: invalid URL string: \(trimmed.prefix(120))")
                    }

                    // If download failed, fall through and try base64 decode as a last resort
                }

                // Use the existing Base64ImageConverter which already strips data URL prefixes
                if let image = Base64ImageConverter.image(from: base64) {
                    self.cache.setObject(image, forKey: key)
                    print("ImageCache: decoded base64 image for key=\(keyString)")
                    continuation.resume(returning: image)
                } else {
                    print("ImageCache: failed to decode base64 (or URL) for key=\(keyString). Preview: \(trimmed.prefix(120))")
                    continuation.resume(returning: nil)
                }
            }
        }
    }

    func clear() {
        cache.removeAllObjects()
    }
}
