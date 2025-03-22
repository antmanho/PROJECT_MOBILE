import Foundation

struct EmailVerificationModel {
    let email: String
    let verificationCode: String
}

// Response models
struct VerificationResponse: Codable {
    let message: String
    let success: Bool
}

struct UserInfoResponse: Codable {
    let role: String
    let userId: Int?
    
    enum CodingKeys: String, CodingKey {
        case role
        case userId = "user_id"
    }
}