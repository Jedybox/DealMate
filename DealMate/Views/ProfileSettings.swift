//
//  ProfileSettings.swift
//  DealMate
//
//  Created by Jhon Ericsson Ytac on 9/22/25.
//

import SwiftUI

struct ProfileSettings: View {
    
    @State private var username: String = "Jhon Eric"
    @State private var email: String = "jhonericsson@example.com"
    @State private var location: String = "Lucena City"
    @State private var created_date: String = "2025"
    @State private var radius: Int = 50
    @State private var traded_amount: Int = 12
    @State private var notificationsOn: Bool = true
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .center, spacing: 16) {
                    
                    // Top bar
                    TopBar(page_name: "Profile")
                    
                    VStack {
                        
                        Image("pfp")
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle())
                            .frame(maxWidth: 150, maxHeight: 150)
                        
                        Text(username)
                            .font(.custom("Poppins", size: 26))
                        Text(email)
                            .font(.custom("Poppins", size: 15))
                        Text("Trader since \(created_date)")
                            .font(.custom("Poppins", size: 15))
                            .foregroundStyle(Color(red:28/255, green:139/255, blue:150/255))
                        
                        Text("⭐️ \(traded_amount) Trades")
                            .padding()
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Profile")
                            .font(.custom("Poppins-Bold", size: 22))

                        HStack {
                            Image("location")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                            Text("Location: Mayao Crossing, Lucena City")
                                .font(.custom("Inter-Light", size: 16))
                        }

                        HStack {
                            Image("compass")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                            Text("Radius: \(radius)km")
                                .font(.custom("Inter-Light", size: 16))
                        }

                        Button(action: {
                            // handle edit
                        }) {
                            Text("Edit Profile")
                                .foregroundStyle(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color(red: 28/255, green: 139/255, blue: 150/255))
                                .cornerRadius(12)
                        }
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

                                // Toggle row
                                HStack {
                                    Text("Notification")
                                        .font(.custom("Poppins", size: 16))
                                    Spacer()
                                    Toggle("", isOn: $notificationsOn)
                                        .onTapGesture(perform: toggleNotif)
                                        .labelsHidden() // hide default label
                                        .toggleStyle(SwitchToggleStyle(tint: .green))
                                }

                                // Links
                                VStack(alignment: .leading, spacing: 12) {
                                    Button(action: {
                                        // navigate to privacy page
                                    }) {
                                        Text("Privacy and Security Policy")
                                            .font(.custom("Poppins", size: 16))
                                            .foregroundStyle(Color(red: 28/255, green: 139/255, blue: 150/255))
                                    }

                                    Button(action: {
                                        // navigate to change password
                                    }) {
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
                Button(action: {}) {
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
    }
    
    func toggleNotif() -> Void {
        if notificationsOn {
            notificationsOn = false
        } else {
            notificationsOn = true
        }
    }
}

#Preview {
    ProfileSettings()
}
