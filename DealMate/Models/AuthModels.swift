import Foundation

// API models for authentication
struct RegisterRequest: Codable {
    let username: String
    let email: String
    let password: String
}

struct RegisterResponse: Codable {
    let message: String?
    let email: String?
    let username: String?
}
