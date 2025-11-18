// Home.swift
// Restored Home view with items loading and CardStack binding

import SwiftUI

struct Home: View {
    @Binding var token: String
    @Binding var navPath: NavigationPath
    @Binding var username: String
    @Binding var pfp: String

    // Use a StateObject so the data survives view re-creations
    @StateObject private var viewModel = ItemsViewModel()

    var body: some View {
        ZStack(alignment: .top) {
            // Main column content (cards, loading, buttons)
            VStack {
                Spacer() // leave space because top bar is overlayed

                if viewModel.isLoading {
                    ProgressView("Loading items...")
                        .padding()
                }

                CardStack(cards: $viewModel.items)
                    .padding()
                    .zIndex(0)
                Spacer()

                NavigationLink(destination: MyItems(token: $token)) {
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
                NavigationLink(destination: ProfileSettings(isLoggedIn: $token, pfp: $pfp)) {
                    if pfp.isEmpty {
                        Image("default")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                            .padding(8)
                            .contentShape(Circle())
                    } else {
                        AsyncImage(url: URL(string: pfp)) { image in
                            image
                                .resizable()
                                .scaledToFit()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                        .padding(8)
                        .contentShape(Circle())
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .frame(minWidth: 44, minHeight: 44)

                Text("Welcome, \(username.isEmpty ? "User" : username)")
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
            // Only load items once (or when the items array is empty).
            // ViewModel handles concurrency and guards.
            await viewModel.loadItemsIfNeeded(token: token)
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}

#Preview {
    Home(token: .constant("sample_token"), navPath: .constant(NavigationPath()), username: .constant("SampleUser"), pfp: .constant("pfp"))
}
