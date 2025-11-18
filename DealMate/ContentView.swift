import SwiftUI

struct ContentView: View {
    @AppStorage("token") private var isLoggedIn = false
    
    @State public var navPath = NavigationPath()
    @State private var username: String = ""
    @State private var pass: String = ""
    @State private var isLoading = false // Track loading

    var body: some View {
        NavigationStack(path: $navPath) {
            if isLoggedIn {
                Home(isLoggedIn: $isLoggedIn, navPath: $navPath)
            } else {
                VStack {
                    Spacer()
                    Text("DealMate")
                        .fontWeight(.bold)
                        .font(.custom("Poppins", size: 42))
                        .foregroundColor(Color(red: 28/255, green: 139/255, blue: 150/255))
                    Spacer()

                    TField(placeHolder: "Username or Email", val: $username)
                    PField(placeHolder: "Enter password", val: $pass)

                    Spacer()

                    // Login button + loading indicator
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 3/255, green: 53/255, blue: 56/255)))
                            .scaleEffect(1.5)
                            .padding()
                    } else {
                        Button(action: {
                            Task {
                                await login()
                            }
                        }) {
                            Text("Login")
                                .padding(10)
                                .font(.custom("Poppins", size: 22))
                                .frame(maxWidth: 300)
                                .foregroundColor(.white)
                                .background(Color(red: 3/255, green: 53/255, blue: 56/255))
                        }
                        .cornerRadius(12)
                        .padding()
                    }

                    Button(action:  {
                        navPath.append(Route.signup)
                    }) {
                        Text("Sign-Up")
                            .font(.custom("Poppins", size: 16))
                            .foregroundColor(Color(red: 3/255, green: 53/255, blue: 56/255))
                    }

                    Spacer()
                }
                .ignoresSafeArea(.keyboard)
                .navigationDestination(for: Route.self) { route in
                    if route == .signup {
                        Signup(navPath: $navPath)
                    }
                }
            }
        }
    }

    // MARK: - Login Function
    func login() async {
        isLoading = true
        defer { isLoading = false } // Always stop loading after the task

        do {
            let response = try await loginUser()
            print("✅ Login success: \(response.token)")
            
            username = ""
            pass = ""
            
            await MainActor.run {
                withAnimation(.easeInOut) {
                    isLoggedIn = true
                }
            }
        } catch {
            print("❌ Login failed with error: \(error)")
        }
    }

    // MARK: - API Call
    func loginUser() async throws -> loginResponse {
        let endpoint = "https://dealmatebackend.vercel.app/api/auth/login"

        guard let url = URL(string: endpoint) else { throw URLError(.badURL) }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["username": username, "password": pass]
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let decoder = JSONDecoder()
        return try decoder.decode(loginResponse.self, from: data)
    }
}

// MARK: - Models
struct loginResponse: Codable {
    let token: String
    let user: UserDTO
}

struct UserDTO: Codable {
    let id: String
    let name: String?
    let email: String?
}

enum Route: Hashable {
    case home
    case signup
    case myItems
}
