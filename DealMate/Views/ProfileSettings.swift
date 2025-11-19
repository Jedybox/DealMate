//
//  ProfileSettings.swift
//  DealMate
//
//  Created by Jhon Ericsson Ytac on 9/22/25.
//

import SwiftUI

struct ProfileSettings: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var isLoggedIn: String
    @Binding var pfp: String

    // Use persisted user values from AppStorage so the view shows actual logged-in data
    @AppStorage("token") private var token: String = "" // for Authorization
    @AppStorage("username") private var username: String = ""
    @AppStorage("email") private var email: String = ""
    @AppStorage("location") private var location: String = ""
    @AppStorage("radius") private var radius: Int = 0
    @AppStorage("createdAt") private var createdAt: String = "" // kept for display

    @State private var isEditingProfile: Bool = false
    @State private var traded_amount: Int = 12
    @State private var notificationsOn: Bool = true

    // Editable copies used when in edit mode
    @State private var editableUsername: String = ""
    @State private var editableEmail: String = ""
    @State private var editableLocation: String = ""
    @State private var editableRadius: String = ""

    @State private var isUpdating: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .center, spacing: 16) {

                    // Top bar
                    TopBar(page_name: "Profile")

                    VStack {

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

                        // editable fields when in edit mode
                        if isEditingProfile {
                            TextField("Username", text: $editableUsername)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(maxWidth: 320)

                            TextField("Email", text: $editableEmail)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(maxWidth: 320)
                        } else {
                            Text(username.isEmpty ? "Unknown" : username)
                                .font(.custom("Poppins", size: 26))
                            Text(email.isEmpty ? "" : email)
                                .font(.custom("Poppins", size: 15))
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Profile")
                            .font(.custom("Poppins-Bold", size: 22))

                        // Use a consistent icon size and spacing for the info rows
                        let infoIconSize: CGFloat = 20

                        HStack(alignment: .center, spacing: 12) {
                            Image("location")
                                .resizable()
                                .scaledToFit()
                                .frame(width: infoIconSize, height: infoIconSize)

                            if isEditingProfile {
                                TextField("Location", text: $editableLocation)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            } else {
                                Text("Location: \(location.isEmpty ? "Not set" : location)")
                                    .font(.custom("Inter-Regular_Light", size: 16))
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            }

                            Spacer()
                        }

                        HStack(alignment: .center, spacing: 12) {
                            Image("compass")
                                .resizable()
                                .scaledToFit()
                                .frame(width: infoIconSize, height: infoIconSize)

                            if isEditingProfile {
                                TextField("Radius (km)", text: $editableRadius)
                                    .keyboardType(.numberPad)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(width: 120)
                            } else {
                                Text("Radius: \(radius)km")
                                    .font(.custom("Inter-Regular_Light", size: 16))
                            }

                            Spacer()
                        }

                        Button(action: {
                            // Toggle edit mode. When entering edit, copy persisted values to editable vars.
                            if !isEditingProfile {
                                editableUsername = username
                                editableEmail = email
                                editableLocation = location
                                editableRadius = String(radius)
                                withAnimation { isEditingProfile = true }
                            } else {
                                // Done tapped: save changes
                                Task { await doneEditing() }
                            }
                        }) {
                            HStack {
                                if isUpdating {
                                    ProgressView()
                                }
                                Text(isEditingProfile ? "Done" : "Edit Profile")
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(Color(red: 28/255, green: 139/255, blue: 150/255))
                                    .cornerRadius(12)
                            }
                        }
                        .disabled(isUpdating)
                        .padding(.top, 8)
                    }
                    .padding() // inner padding
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 4)
                    .padding(.horizontal) // outer spacing from screen edges

                    VStack(alignment: .leading, spacing: 16) {
                        Text("My Listings")
                            .font(.custom("Poppins-Bold", size: 22))

                        HStack(spacing: 16) {
                            // Offerings button
                            Button(action: {}) {
                                Text("Offerings")
                                    .font(.custom("Poppins", size: 18))
                                    .foregroundStyle(.black)
                                    .frame(maxWidth: .infinity) // make them expand equally
                                    .padding(.vertical, 12)
                                    .background(Color(.systemGray6)) // light gray background
                                    .cornerRadius(12)
                            }

                            // Looking for button
                            Button(action: {}) {
                                Text("Looking for")
                                    .font(.custom("Poppins", size: 18))
                                    .foregroundStyle(.black)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 4)
                    .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 16) {
                        Text("Settings")
                            .font(.custom("Poppins-Bold", size: 22))

                        HStack {
                            Text("Notification")
                                .font(.custom("Poppins", size: 16))
                            Spacer()
                            Toggle("", isOn: $notificationsOn)
                                .labelsHidden()
                                .toggleStyle(SwitchToggleStyle(tint: .green))
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            Button(action: {}) {
                                Text("Privacy and Security Policy")
                                    .font(.custom("Poppins", size: 16))
                                    .foregroundStyle(Color(red: 28/255, green: 139/255, blue: 150/255))
                            }

                            Button(action: {}) {
                                Text("Change Password")
                                    .font(.custom("Poppins", size: 16))
                                    .foregroundStyle(Color(red: 28/255, green: 139/255, blue: 150/255))
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 4)
                    .padding(.horizontal)
                }

                Button(action: {
                    isLoggedIn = ""
                    dismiss()
                }) {
                    Text("Log-out")
                        .font(.custom("Poppins", size: 18))
                        .frame(maxWidth: 200)
                        .padding(.vertical, 12)
                        .foregroundStyle(.white)
                        .background(Color(red: 195/255, green: 74/255, blue: 74/255))
                        .cornerRadius(12)
                }
                .padding(.vertical)
            }
        }
        .navigationBarBackButtonHidden(true)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Profile"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    func toggleNotif() {
        notificationsOn.toggle()
    }

    // Build JSON with only changed fields and send PUT request
    func doneEditing() async {
        // compute changes by comparing editable values with persisted ones
        var changes: [String: Any] = [:]

        if editableUsername.trimmingCharacters(in: .whitespacesAndNewlines) != username {
            changes["username"] = editableUsername.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if editableEmail.trimmingCharacters(in: .whitespacesAndNewlines) != email {
            changes["email"] = editableEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if editableLocation.trimmingCharacters(in: .whitespacesAndNewlines) != location {
            changes["location"] = editableLocation.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if let newRadius = Int(editableRadius), newRadius != radius {
            changes["radius"] = newRadius
        }

        // if nothing changed, just exit edit mode
        if changes.isEmpty {
            withAnimation { isEditingProfile = false }
            return
        }

        isUpdating = true
        defer { isUpdating = false }

        // Call the centralized update function
        let (success, message) = await update_profile(changes: changes)

        if success {
            // update persisted values from editable fields where changed
            if let u = changes["username"] as? String { username = u }
            if let e = changes["email"] as? String { email = e }
            if let l = changes["location"] as? String { location = l }
            if let r = changes["radius"] as? Int { radius = r }

            withAnimation { isEditingProfile = false }
            alertMessage = "Profile updated"
            showAlert = true
        } else {
            alertMessage = message
            showAlert = true
        }
    }

    // Centralized update function uses the endpoint provided earlier and performs the PUT
    func update_profile(changes: [String: Any]) async -> (Bool, String) {
        guard let url = URL(string: "https://dealmatebackend.vercel.app/api/user") else {
            return (false, "Invalid update URL")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if !token.isEmpty {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: changes, options: [])
        } catch {
            return (false, "Failed to prepare update payload")
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                return (false, "No response from server")
            }
            let body = String(data: data, encoding: .utf8) ?? ""
            if (200...299).contains(http.statusCode) {
                return (true, body)
            } else {
                return (false, "Update failed (\(http.statusCode)): \(body)")
            }
        } catch {
            return (false, "Network error: \(error.localizedDescription)")
        }
    }

    // Format createdAt string into a human-friendly year (fallback to raw or "Unknown")
    func formatCreatedAt(_ raw: String) -> String {
        guard !raw.isEmpty else { return "Unknown" }

        // Try ISO8601 first
        let isoFormatter = ISO8601DateFormatter()
        if let date = isoFormatter.date(from: raw) {
            let year = Calendar.current.component(.year, from: date)
            return String(year)
        }

        // Try common date formats
        let formatter = DateFormatter()
        let formats = ["yyyy-MM-dd'T'HH:mm:ssZ", "yyyy-MM-dd", "MM/dd/yyyy"]
        for fmt in formats {
            formatter.dateFormat = fmt
            if let date = formatter.date(from: raw) {
                return String(Calendar.current.component(.year, from: date))
            }
        }

        // Fallback: if the server sends just a year or readable text, return it directly
        if raw.count == 4, Int(raw) != nil {
            return raw
        }
        return raw
    }
}

#Preview {
    ProfileSettings(isLoggedIn: .constant("testuser"), pfp: .constant(""))
}
