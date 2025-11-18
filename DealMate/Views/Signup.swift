//
//  Signup.swift
//  DealMate
//
//  Created by Jhon Ericsson Ytac on 9/22/25.
//

import SwiftUI

struct Signup: View {
    
    @Environment(\.dismiss) private var dismiss
    @Binding var navPath: NavigationPath
    
    @State private var email: String = ""
    @State private var username: String = ""
    @State private var pass: String = ""
    @State private var re_pass: String = ""
    
    @State private var isLoading: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var registrationSucceeded: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Text("DealMate")
                    .fontWeight(.bold)
                    .font(.custom("Poppins", size: 32))
                    .foregroundStyle(Color(red:28/255, green:139/255, blue:150/255))
                    .offset(x:-60)
                Spacer()
                
                TField(placeHolder: "Email", val: $email)
                TField(placeHolder: "Username", val: $username)
                PField(placeHolder: "Password", val: $pass)
                PField(placeHolder: "Re-Enter Password", val: $re_pass)
                
                Spacer()
                Button(action: register) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: 300)
                            .padding(10)
                            .background(Color(red:3/255, green:53/255, blue:56/255))
                            .cornerRadius(12)
                    } else {
                        Text("Register")
                            .padding(10)
                            .font(.title2)
                            .frame(maxWidth: 300)
                            .foregroundStyle(.white)
                            .background(Color(red:3/255, green:53/255, blue:56/255))
                            .cornerRadius(12)
                    }
                }
                .disabled(isLoading)
                .padding()
                Spacer()
                
            }.background(Color(red:254/255, green:254/255, blue: 254))
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Registration"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"), action: {
                        if registrationSucceeded {
                            navPath.removeLast()
                        }
                    })
                )
            }
        }.navigationBarBackButtonHidden(true)
    }
    
    func register() {
        // Basic validation
        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !pass.isEmpty,
              !re_pass.isEmpty else {
            alertMessage = "Please fill in all fields."
            showAlert = true
            return
        }
        
        guard pass == re_pass else {
            alertMessage = "Passwords do not match."
            showAlert = true
            return
        }
        
        // Prepare request
        guard let url = URL(string: "https://dealmatebackend.vercel.app/api/auth/register") else {
            alertMessage = "Invalid endpoint URL."
            showAlert = true
            return
        }
        
        let reqBody = RegisterRequest(username: username, email: email, password: pass)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            request.httpBody = try JSONEncoder().encode(reqBody)
        } catch {
            alertMessage = "Failed to encode request."
            showAlert = true
            return
        }
        
        isLoading = true
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
            }
            if let error = error {
                DispatchQueue.main.async {
                    alertMessage = "Network error: \(error.localizedDescription)"
                    showAlert = true
                }
                return
            }
            guard let httpResp = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    alertMessage = "Invalid server response."
                    showAlert = true
                }
                return
            }
            switch httpResp.statusCode {
            case 201:
                // Success
                DispatchQueue.main.async {
                    alertMessage = "Registered successfully. You can now log in."
                    registrationSucceeded = true
                    showAlert = true
                }
            case 400:
                // User already exists or validation error - try to decode message body
                var msg = "User already exists or invalid data."
                if let data = data {
                    if let obj = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let m = obj["message"] as? String {
                        msg = m
                    } else if let text = String(data: data, encoding: .utf8), !text.isEmpty {
                        msg = text
                    }
                }
                DispatchQueue.main.async {
                    alertMessage = msg
                    showAlert = true
                }
            default:
                var msg = "Server error (\(httpResp.statusCode)). Please try again later."
                if let data = data, let text = String(data: data, encoding: .utf8), !text.isEmpty {
                    msg = text
                }
                DispatchQueue.main.async {
                    alertMessage = msg
                    showAlert = true
                }
            }
        }
        task.resume()
    }
}

#Preview {
    Signup(navPath: .constant(NavigationPath()))
}
