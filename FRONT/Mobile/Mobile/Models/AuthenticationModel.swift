import Foundation

struct Credentials {
    let email: String
    let password: String
}

struct LoginResponse: Codable {
    let success: Bool
    let message: String?
}

struct UserInfoResponse: Codable {
    let role: String
    let userId: Int?
    
    enum CodingKeys: String, CodingKey {
        case role
        case userId = "user_id"
    }
}