//
//  MyItems.swift
//  DealMate
//
//  Created by Jhon Ericsson Ytac on 9/22/25.
//

import SwiftUI

struct MyItems: View {
    
    @State private var items: [String] = ["Steel Series Headset", "Logitech KB"]
    @State private var showDeleteAlert = false
    @State private var itemToDelete: String? = nil

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                
                // Top bar
                TopBar(page_name: "My Items")
                
                // Add button
                Button(action: {
                    for family in UIFont.familyNames {
                        print("Font family: \(family)")
                        for name in UIFont.fontNames(forFamilyName: family) {
                            print("   \(name)")
                        }
                    }
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
                
                // Item list
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(items, id: \.self) { item in
                            HStack {
                                Image("pfp") // replace with item.imageName
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                
                                Text(item)
                                    .font(.custom("Poppins", size: 16))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                
                                Spacer()
                                
                                Button(action: {
                                    // Ask confirmation before deleting
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


#Preview {
    MyItems()
}
