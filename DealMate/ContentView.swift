// Swift
import SwiftUI

struct ContentView: View {
    // existing persisted fields
    @AppStorage("token") private var token: String = ""
    @AppStorage("username") private var username: String = ""
    @AppStorage("pfp") private var pfp: String = ""

    // Persist additional user details returned by login
    @AppStorage("userId") private var userId: String = ""
    @AppStorage("email") private var email: String = ""
    @AppStorage("location") private var location: String = ""
    @AppStorage("radius") private var radius: Int = 0
    @AppStorage("createdAtTimestamp") private var createdAtTimestamp: Double = 0 // store createdAt as timestamp

    @State public var navPath = NavigationPath()
    @State private var pass: String = ""
    @State private var isLoading = false // Track loading
    @State private var chatMatches: [ChatMatchDTO] = [] // store chatMatches from login

    var body: some View {
        NavigationStack(path: $navPath) {
            if token != "" {
                Home(token: $token, navPath: $navPath, username: $username, pfp: $pfp)
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
            print("Response user.username: \(response.user.username ?? "(nil)")")
            print("Response user.email: \(response.user.email ?? "(nil)")")
            print("Response user.pfp: \(response.user.pfp ?? "(nil)")")
            print("Response user._id: \(response.user.id ?? "(nil)")")
            print("Response user.location: \(response.user.location ?? "(nil)")")
            print("Response user.radius: \(response.user.radius ?? -1)")
            print("Response chatMatches count: \(response.chatMatches?.count ?? 0)")

            pass = ""

            // Parse createdAt string into timestamp (seconds since 1970)
            var parsedTimestamp: Double = 0
            if let rawCreated = response.user.createdAt {
                // Try ISO8601
                let iso = ISO8601DateFormatter()
                if let date = iso.date(from: rawCreated) {
                    parsedTimestamp = date.timeIntervalSince1970
                } else {
                    // Try a few common formats
                    let fmts = ["yyyy-MM-dd'T'HH:mm:ssZ", "yyyy-MM-dd HH:mm:ss", "yyyy-MM-dd", "MM/dd/yyyy"]
                    let df = DateFormatter()
                    df.locale = Locale(identifier: "en_US_POSIX")
                    for f in fmts {
                        df.dateFormat = f
                        if let d = df.date(from: rawCreated) {
                            parsedTimestamp = d.timeIntervalSince1970
                            break
                        }
                    }
                    // Fallback: if the server returned a numeric timestamp string
                    if parsedTimestamp == 0, let num = Double(rawCreated) {
                        parsedTimestamp = (num > 1_000_000_000_000) ? (num / 1000.0) : num
                    }
                }
            }

            await MainActor.run {
                withAnimation(.easeInOut) {
                    // persist token + user details in AppStorage so other views can use them
                    token = response.token
                    username = response.user.username ?? response.user.email ?? "User"
                    pfp = response.user.pfp ?? ""
                    email = response.user.email ?? ""
                    userId = response.user.id ?? ""
                    location = response.user.location ?? ""
                    radius = response.user.radius ?? 0
                    createdAtTimestamp = parsedTimestamp

                    // store chatMatches in state var so UI can use it
                    chatMatches = response.chatMatches ?? []
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
    let chatMatches: [ChatMatchDTO]?
}

// Map backend `_id` to `id` and include additional user fields
struct UserDTO: Codable {
    let id: String?
    let username: String?
    let email: String?
    let pfp: String?
    let location: String?
    let radius: Int?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case username, email, pfp, location, radius, createdAt
    }
}

// Minimal DTOs to decode chatMatches from login response
struct ChatMatchDTO: Codable, Identifiable {
    let id: String?
    let item1: ChatItemDTO?
    let item2: ChatItemDTO?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case item1, item2
    }
}

struct ChatItemDTO: Codable, Identifiable {
    let id: String?
    let title: String?
    let description: String?
    let image: String? // could be base64 or URL depending on backend

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title, description, image
    }
}


enum Route: Hashable {
    case home
    case signup
    case myItems
}

#Preview {
    ContentView()
}
