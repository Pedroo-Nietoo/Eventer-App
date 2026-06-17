import Foundation

struct PresignedUrlRequestDto: Codable {
    let fileName: String
    let contentType: String
    let folder: String
}

struct PresignedUrlResponseDto: Codable {
    let presignedUrl: String
    let fields: [String: String]
    let finalUrl: String
}

struct UpdateProfileDto: Codable {
    let password: String?
    let profilePicture: String?
}
