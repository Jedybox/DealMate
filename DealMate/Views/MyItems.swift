import SwiftUI
import PhotosUI

// MARK: - Item Model
struct Item: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var description: String
    var image: UIImage?
}

struct MyItems: View {
    
    @State private var items: [Item] = [
//        Item(name: "Steel Series Headset", description: "Gaming headset", image: UIImage(named: "pfp")),
//        Item(name: "Logitech KB", description: "Mechanical keyboard", image: UIImage(named: "pfp"))
    ]
    
    @State private var showDeleteAlert = false
    @State private var itemToDelete: Item? = nil
    @State private var showAddSheet = false

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
                        ForEach(items) { item in
                            HStack {
                                if let img = item.image {
                                    Image(uiImage: img)
                                        .resizable()
                                        .scaledToFill()
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
                    }
                }
            }
            .navigationBarHidden(true)
            .alert("Are you sure?", isPresented: $showDeleteAlert) {
                Button("Delete", role: .destructive) {
                    if let item = itemToDelete,
                       let index = items.firstIndex(of: item) {
                        items.remove(at: index)
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This action cannot be undone.")
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
            .onChange(of: selectedItem) { newItem in
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

