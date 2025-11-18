import Foundation
import SwiftUI
import Combine

@MainActor
final class ItemsViewModel: ObservableObject {
    @Published var items: [Card] = []
    @Published var isLoading: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""

    // Simple guard to avoid repeated loads
    private var hasLoadedOnce: Bool = false
    private var loadingTask: Task<Void, Never>? = nil

    func loadItemsIfNeeded(token: String) async {
        // If we've loaded once and items exist, skip reloading
        if hasLoadedOnce && !items.isEmpty { return }
        if let task = loadingTask {
            await task.value
            return
        }

        // Use a Task that inherits the current actor (MainActor) so we can mutate loadingTask safely
        loadingTask = Task { [weak self] in
            guard let self = self else { return }
            await self.loadItems(token: token)
            // clear the reference on the main actor
            await MainActor.run {
                self.loadingTask = nil
            }
        }

        await loadingTask?.value
    }

    private func loadItems(token: String) async {
        let endpoint = "https://dealmatebackend.vercel.app/api/item/random"

        await MainActor.run {
            self.isLoading = true
            self.showError = false
            self.errorMessage = ""
        }

        defer {
            Task { @MainActor in
                self.isLoading = false
            }
        }

        guard let url = URL(string: endpoint) else {
            await MainActor.run {
                self.errorMessage = "Invalid URL"
                self.showError = true
            }
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if !token.isEmpty {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }

            switch http.statusCode {
            case 200:
                struct APIItem: Decodable {
                    let id: String?
                    let name: String?
                    let description: String?
                    let imageBase64: String?
                    let image: String?
                }

                let decoder = JSONDecoder()
                let apiItems = try decoder.decode([APIItem].self, from: data)

                var mapped: [Card] = []
                var base64s: [String?] = []

                for api in apiItems {
                    let card = Card(imageName: "item", title: api.name ?? "Untitled", description: api.description ?? "")
                    mapped.append(card)
                    base64s.append(api.imageBase64 ?? api.image)
                }

                await MainActor.run {
                    self.items = mapped
                    self.hasLoadedOnce = true
                }

                for (index, b64opt) in base64s.enumerated() {
                    guard let b64 = b64opt, !b64.isEmpty else { continue }
                    let idForCache = apiItems.indices.contains(index) ? apiItems[index].id : nil

                    print("ItemsViewModel: decoding image for item index=\(index), id=\(idForCache ?? "(nil)"), preview=\(b64.prefix(80))")

                    // Prepare image string: it may be base64, a full URL, or a relative path from the backend.
                    let trimmed = b64.trimmingCharacters(in: .whitespacesAndNewlines)
                    var imageStringToUse = trimmed

                    // If it looks like a relative path (starts with '/') or it looks like a filename with extension but no scheme,
                    // prefix it with the backend origin so ImageCache can download it.
                    if trimmed.hasPrefix("/") {
                        imageStringToUse = "https://dealmatebackend.vercel.app\(trimmed)"
                        print("ItemsViewModel: treated as relative path, converted to full URL: \(imageStringToUse)")
                    } else if !trimmed.contains("://") && (trimmed.lowercased().hasSuffix(".png") || trimmed.lowercased().hasSuffix(".jpg") || trimmed.lowercased().hasSuffix(".jpeg") || trimmed.lowercased().hasSuffix(".webp") || trimmed.lowercased().hasSuffix(".gif")) {
                        // e.g. 'uploads/image.jpg' => prefix
                        imageStringToUse = "https://dealmatebackend.vercel.app/\(trimmed)"
                        print("ItemsViewModel: treated as relative file path, converted to full URL: \(imageStringToUse)")
                    }

                    Task.detached {
                        if let img = await ImageCache.shared.image(forBase64: imageStringToUse, id: idForCache) {
                            await MainActor.run {
                                if self.items.indices.contains(index) {
                                    var copy = self.items
                                    copy[index].uiImage = img
                                    self.items = copy
                                    print("ItemsViewModel: set uiImage for index=\(index) and updated published items array")
                                }
                            }
                        } else {
                            print("ItemsViewModel: failed to decode image for index=\(index)")
                        }
                    }
                }

            case 500:
                struct ErrorResponse: Decodable { let message: String }
                let decoder = JSONDecoder()
                if let err = try? decoder.decode(ErrorResponse.self, from: data) {
                    await MainActor.run {
                        self.errorMessage = err.message
                        self.showError = true
                    }
                } else {
                    let text = String(data: data, encoding: .utf8) ?? "Server error"
                    await MainActor.run {
                        self.errorMessage = text
                        self.showError = true
                    }
                }

            default:
                let text = String(data: data, encoding: .utf8) ?? "HTTP \(http.statusCode)"
                await MainActor.run {
                    self.errorMessage = text
                    self.showError = true
                }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.showError = true
            }
        }
    }
}
