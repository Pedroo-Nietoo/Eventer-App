import Foundation

struct LoginDto: Codable {
    let email: String
    let password: String
}

struct CreateUserDto: Codable {
    let username: String
    let email: String
    let password: String
    let profilePicture: String?
}

struct LoginResponseDto: Codable {
    let access_token: String
    let refresh_token: String
}

struct RefreshRequestDto: Codable {
    let refresh_token: String
}

struct RefreshResponseDto: Codable {
    let access_token: String
    let refresh_token: String
}

struct UserResponseDto: Codable, Identifiable {
    let id: String
    let username: String
    let email: String
    let profilePicture: String?
}
