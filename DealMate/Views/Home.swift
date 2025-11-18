// Home.swift
// Restored Home view with items loading and CardStack binding

import SwiftUI

struct Home: View {
    @Binding var token: String
    @Binding var navPath: NavigationPath

    @State private var username: String = "Jhon"

    // state for cards
    @State private var items: [Card] = []

    // UI state
    @State private var isLoading: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""

    var body: some View {
        ZStack(alignment: .top) {
            // Main column content (cards, loading, buttons)
            VStack {
                Spacer() // leave space because top bar is overlayed

                if isLoading {
                    ProgressView("Loading items...")
                        .padding()
                }

                CardStack(cards: $items)
                    .padding()
                    .zIndex(0)
                Spacer()

                NavigationLink(destination: MyItems()) {
                    Text("My Items")
                        .font(.custom("Montserrat", size: 20))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, maxHeight: 60)
                        .background(Color(red: 3/255, green: 53/255, blue: 56/255))
                        .offset(y:10)
                }
            }

            // Top bar overlay so it always sits above the cards and receives taps
            HStack {
                NavigationLink(destination: ProfileSettings(isLoggedIn: $token)) {
                    Image("pfp")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                        .padding(8)
                        .contentShape(Circle())
                }
                .buttonStyle(PlainButtonStyle())
                .frame(minWidth: 44, minHeight: 44)

                Text("Welcome, \(username)")
                    .font(.custom("Poppins", size: 16))
                    .foregroundStyle(Color(red:28/255, green:139/255, blue:150/255))

                Spacer()

                NavigationLink(destination: Chats()) {
                    Image("chatlogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25)
                        .padding(8)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
                .frame(minWidth: 44, minHeight: 44)
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .background(Color.clear)
            .contentShape(Rectangle())
            .zIndex(20)
        }
        .navigationBarBackButtonHidden(true)
        .task {
            await loadItems()
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }

    func loadItems() async {
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
                    let title: String?
                    let description: String?
                    let imageUrl: String?
                }
                let decoder = JSONDecoder()
                let apiItems = try decoder.decode([APIItem].self, from: data)
                let mapped = apiItems.map { api in
                    Card(imageName: "item", title: api.title ?? "Untitled", description: api.description ?? "")
                }
                await MainActor.run {
                    self.items = mapped
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

#Preview {
    Home(token: .constant("sample_token"), navPath: .constant(NavigationPath()))
}
