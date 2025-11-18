import SwiftUI
import PhotosUI

// MARK: - Item Model
struct Item: Identifiable, Hashable {
    let id = UUID()
    var itemId: String? = nil // backend item id
    var name: String
    var description: String
    var image: UIImage?
    // optional raw image source (URL or base64) so the UI can use AsyncImage when appropriate
    var imageSource: String? = nil
}

struct MyItems: View {
    @Binding var token: String
    
    @State private var items: [Item] = [
//        Item(name: "Steel Series Headset", description: "Gaming headset", image: UIImage(named: "pfp")),
//        Item(name: "Logitech KB", description: "Mechanical keyboard", image: UIImage(named: "pfp"))
    ]
    
    @State private var showDeleteAlert = false
    @State private var itemToDelete: Item? = nil
    @State private var showAddSheet = false
    @State private var isLoading: Bool = false
    @State private var loadError: String? = nil

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                
                // Top bar
                TopBar(page_name: "My Items")
                
                // Add button
                Button(action: {
                    showAddSheet = true
                }) {
                    Text("+")
                        .font(.title2)
                        .foregroundStyle(Color(red: 28/255, green: 139/255, blue: 150/255))
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(red: 28/255, green: 139/255, blue: 150/255), lineWidth: 1)
                        )
                }
                .padding(.horizontal)
                .sheet(isPresented: $showAddSheet) {
                    AddItemSheet { newItem in
                        items.append(newItem)
                        showAddSheet = false
                    } onCancel: {
                        showAddSheet = false
                    }
                    .presentationDetents([.fraction(0.5)])
                    .presentationDragIndicator(.visible)
                }
                
                // Item list
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(items, id: \.id) { item in
                            HStack {
                                // Show decoded UIImage first, otherwise if there's a URL use AsyncImage, otherwise placeholder
                                if let img = item.image {
                                    Image(uiImage: img)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 60, height: 60)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                } else if let src = item.imageSource, let url = URL(string: src), src.lowercased().contains("://") {
                                    AsyncImage(url: url) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFill()
                                        case .failure(_):
                                            Rectangle().fill(Color.gray)
                                        @unknown default:
                                            Rectangle().fill(Color.gray)
                                        }
                                    }
                                    .frame(width: 60, height: 60)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                } else {
                                    Rectangle()
                                        .fill(Color.gray)
                                        .frame(width: 60, height: 60)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.name)
                                        .font(.custom("Poppins", size: 16))
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                    Text(item.description)
                                        .font(.custom("Poppins", size: 12))
                                        .foregroundColor(.white.opacity(0.7))
                                        .lineLimit(2)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    itemToDelete = item
                                    showDeleteAlert = true
                                }) {
                                    Image(systemName: "trash.fill")
                                        .foregroundColor(.white)
                                        .padding(8)
                                        .background(Color.red)
                                        .clipShape(RoundedRectangle(cornerRadius: 6))
                                }
                            }
                            .padding(8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(red: 28/255, green: 139/255, blue: 150/255))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal)
                        }
                        // show empty state when no items loaded
                        if items.isEmpty && !isLoading {
                            VStack(alignment: .center) {
                                Text(loadError ?? "No items yet.")
                                    .font(.custom("Poppins", size: 16))
                                    .foregroundColor(.white.opacity(0.9))
                                    .padding()
                            }
                            .frame(maxWidth: .infinity)
                        }
                     }
                 }
             }
             .navigationBarHidden(true)
             .alert("Are you sure?", isPresented: $showDeleteAlert) {
                 Button("Delete", role: .destructive) {
                     // call delete async and remove on success
                     if let item = itemToDelete {
                         Task.detached {
                             await deleteItem(item)
                         }
                     }
                 }
                 Button("Cancel", role: .cancel) { }
             } message: {
                 Text("This action cannot be undone.")
             }
             .task {
                 await getItems()
             }
             .disabled(isLoading)
             .overlay {
                 if isLoading {
                     ZStack {
                         Color.black.opacity(0.4)
                             .ignoresSafeArea()

                         VStack(spacing: 12) {
                             ProgressView()
                                 .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                                 .scaleEffect(1.5)
                             Text("Loading items...")
                                 .font(.custom("Poppins", size: 16))
                                 .foregroundColor(.white)
                         }
                         .padding(24)
                         .background(Color.black.opacity(0.25))
                         .cornerRadius(12)
                     }
                 }
             }
         }
     }
    
    func deleteItems(at indexSet: IndexSet) {
        // For each selected index, call the async server delete.
        let toDelete: [Item] = indexSet.compactMap { (idx: Int) -> Item? in
            guard items.indices.contains(idx) else { return nil }
            return items[idx]
        }

        for item in toDelete {
            Task.detached {
                await deleteItem(item)
            }
        }
    }
    
    func getItems() async {
        let end_point = "https://dealmatebackend.vercel.app/api/item/"
        
        await MainActor.run { isLoading = true; loadError = nil }
        
        guard let url = URL(string: end_point) else {
            await MainActor.run { loadError = "Invalid URL"; isLoading = false }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if !token.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }
            
            guard (200...299).contains(http.statusCode) else {
                let txt = String(data: data, encoding: .utf8) ?? "HTTP \(http.statusCode)"
                await MainActor.run { loadError = txt; isLoading = false }
                return
            }
            
            // Robust APIItem decoder: accepts `id` or `_id`, string/int, or nested {$oid: "..."}
            struct APIItem: Decodable {
                let id: String?
                let name: String?
                let description: String?
                let imageBase64: String?
                let image: String?

                init(from decoder: Decoder) throws {
                    let container = try decoder.container(keyedBy: CodingKeys.self)

                    func decodeId(_ key: CodingKeys) -> String? {
                        // Try decode String safely
                        var maybeString: String? = nil
                        do {
                            maybeString = try container.decodeIfPresent(String.self, forKey: key)
                        } catch {
                            maybeString = nil
                        }
                        if let s = maybeString, !s.isEmpty {
                            return s.trimmingCharacters(in: .whitespacesAndNewlines)
                        }

                        // Try decode Int safely
                        var maybeInt: Int? = nil
                        do {
                            maybeInt = try container.decodeIfPresent(Int.self, forKey: key)
                        } catch {
                            maybeInt = nil
                        }
                        if let i = maybeInt {
                            return String(i)
                        }

                        // Try nested object like { "$oid": "..." }
                        var nestedContainer: KeyedDecodingContainer<DynamicKey>? = nil
                        do {
                            nestedContainer = try container.nestedContainer(keyedBy: DynamicKey.self, forKey: key)
                        } catch {
                            nestedContainer = nil
                        }
                        if let nested = nestedContainer, let dyn = DynamicKey(stringValue: "$oid") {
                            var maybeOid: String? = nil
                            do {
                                maybeOid = try nested.decodeIfPresent(String.self, forKey: dyn)
                            } catch {
                                maybeOid = nil
                            }
                            if let oid = maybeOid, !oid.isEmpty {
                                return oid.trimmingCharacters(in: .whitespacesAndNewlines)
                            }
                        }

                        return nil
                    }

                    var found = decodeId(.id)
                    if found == nil { found = decodeId(.underscoreId) }
                    self.id = found

                    self.name = try? container.decodeIfPresent(String.self, forKey: .name)
                    self.description = try? container.decodeIfPresent(String.self, forKey: .description)
                    self.imageBase64 = try? container.decodeIfPresent(String.self, forKey: .imageBase64)
                    self.image = try? container.decodeIfPresent(String.self, forKey: .image)
                }

                struct DynamicKey: CodingKey {
                    var stringValue: String
                    init?(stringValue: String) { self.stringValue = stringValue }
                    var intValue: Int? { nil }
                    init?(intValue: Int) { nil }
                }

                enum CodingKeys: String, CodingKey {
                    case id
                    case underscoreId = "_id"
                    case name, description, imageBase64, image
                }
            }

            let decoder = JSONDecoder()

            // Debug: print raw response preview
            if let raw = String(data: data, encoding: .utf8) {
                print("MyItems: raw response preview -> \(raw.prefix(2000))")
            }

            // Try decoding array directly; if that fails try common wrappers
            var apiItems: [APIItem] = []
            if let arr = try? decoder.decode([APIItem].self, from: data) {
                apiItems = arr
            } else if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                let keys = ["data","items","result","payload"]
                for k in keys {
                    if let arrAny = json[k] as? [[String: Any]], let arrData = try? JSONSerialization.data(withJSONObject: arrAny), let decoded = try? decoder.decode([APIItem].self, from: arrData) {
                        apiItems = decoded
                        break
                    }
                }
            }

            if apiItems.isEmpty { print("MyItems: warning - no items decoded from response") }

            var mapped: [Item] = []
            for api in apiItems {
                let title = api.name ?? "Untitled"
                let desc = api.description ?? ""
                var uiImage: UIImage? = nil
                var imageSource: String? = nil

                if let src = (api.imageBase64 ?? api.image)?.trimmingCharacters(in: .whitespacesAndNewlines), !src.isEmpty {
                    imageSource = src
                    if !(src.lowercased().contains("://")) {
                        uiImage = Base64ImageConverter.image(from: src)
                    }
                }

                mapped.append(Item(itemId: api.id, name: title, description: desc, image: uiImage, imageSource: imageSource))
                print("MyItems: mapped item -> itemId=\(api.id ?? "(nil)"), name=\(title)")
            }
            
            await MainActor.run {
                self.items = mapped
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.loadError = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    // Deletes an item on the server (if it has an itemId). On success removes it from the local list.
    func deleteItem(_ item: Item) async {
        // If no item ID, just remove locally
        guard let rawItemId = item.itemId, !rawItemId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            await MainActor.run {
                if let idx = items.firstIndex(of: item) {
                    items.remove(at: idx)
                }
            }
            return
        }

        let itemId = rawItemId.trimmingCharacters(in: .whitespacesAndNewlines)
        print("MyItems: deleting item rawId='\(rawItemId)' trimmed='\(itemId)'")

        // Build the delete URL by appending the itemId as a path component to avoid encoding issues.
        let base = "https://dealmatebackend.vercel.app/api/item"
        guard let baseURL = URL(string: base) else {
            await MainActor.run { loadError = "Invalid delete base URL" }
            return
        }

        let url = baseURL.appendingPathComponent(itemId)
        print("MyItems: delete URL -> \(url.absoluteString)")

        await MainActor.run { isLoading = true; loadError = nil }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if !token.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        print("MyItems: DELETE request headers -> \(request.allHTTPHeaderFields ?? [:])")

        do {
            let (respData, response) = try await URLSession.shared.data(for: request)
            if let http = response as? HTTPURLResponse {
                let body = String(data: respData, encoding: .utf8) ?? "(no body)"
                print("MyItems: DELETE response status=\(http.statusCode) body=\(body)")

                if (200...299).contains(http.statusCode) {
                    await MainActor.run {
                        if let idx = items.firstIndex(of: item) {
                            items.remove(at: idx)
                        }
                        isLoading = false
                    }
                } else {
                    await MainActor.run {
                        loadError = "Delete failed: HTTP \(http.statusCode) - \(body)"
                        isLoading = false
                    }
                }
            } else {
                throw URLError(.badServerResponse)
            }
        } catch {
            await MainActor.run {
                loadError = error.localizedDescription
                isLoading = false
            }
        }
    }
}

// MARK: - Add Item Sheet
struct AddItemSheet: View {
    @State private var newName = ""
    @State private var newDescription = ""
    @State private var selectedImage: UIImage? = nil
    @State private var selectedItem: PhotosPickerItem? = nil
    
    var onAdd: (Item) -> Void
    var onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Add New Item")
                .font(.headline)
            
            TextField("Item name", text: $newName)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            
            TextField("Description", text: $newDescription)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            
            // Image picker
            PhotosPicker(
                selection: $selectedItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                if let img = selectedImage {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 100, height: 100)
                        .overlay(Text("Select Image").font(.caption))
                }
            }
            .onChange(of: selectedItem) { _, newItem in
                guard let newItem else { return }
                Task {
                    if let data = try? await newItem.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        selectedImage = uiImage
                    }
                }
            }
            
            HStack {
                Button("Cancel", action: onCancel)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                
                Button("Add") {
                    let newItem = Item(name: newName, description: newDescription, image: selectedImage)
                    onAdd(newItem)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(red: 28/255, green: 139/255, blue: 150/255))
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}


// MARK: - PhotosPicker Extension
extension View {
    func photosPicker(selection: Binding<UIImage?>, matching: PHPickerFilter = .images) -> some View {
        self.background(
            PhotosPicker(
                selection: Binding<PhotosPickerItem?>(
                    get: { nil }, // always nil; we handle loading manually
                    set: { newItem in
                        guard let newItem else { return }
                        Task {
                            if let data = try? await newItem.loadTransferable(type: Data.self),
                               let uiImage = UIImage(data: data) {
                                selection.wrappedValue = uiImage
                            }
                        }
                    }
                ),
                matching: matching,
                photoLibrary: .shared()
            ) {
                EmptyView()
            }
            .opacity(0)
        )
    }
}
