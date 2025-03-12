import SwiftUI
import Combine

struct ChangePasswordView: View {
    @StateObject private var viewModel = ChangePasswordViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                Text("CHANGER VOTRE MOT DE PASSE")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 30)
                
                // Form fields
                VStack(alignment: .leading, spacing: 20) {
                    // Current password field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Mot de passe actuel")
                            .font(.headline)
                        
                        SecureField("Entrez votre mot de passe actuel", text: $viewModel.currentPassword)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(viewModel.currentPasswordError != nil ? Color.red : Color.clear, lineWidth: 1)
                            )
                        
                        if let error = viewModel.currentPasswordError {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    
                    // New password field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Nouveau mot de passe")
                            .font(.headline)
                        
                        SecureField("Entrez votre nouveau mot de passe", text: $viewModel.newPassword)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(viewModel.newPasswordError != nil ? Color.red : Color.clear, lineWidth: 1)
                            )
                        
                        if let error = viewModel.newPasswordError {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    
                    // Confirm new password field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Confirmez le nouveau mot de passe")
                            .font(.headline)
                        
                        SecureField("Confirmez votre nouveau mot de passe", text: $viewModel.confirmNewPassword)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(viewModel.confirmNewPasswordError != nil ? Color.red : Color.clear, lineWidth: 1)
                            )
                        
                        if let error = viewModel.confirmNewPasswordError {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Error message
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Submit button
                Button(action: {
                    viewModel.changePassword()
                }) {
                    Text("Changer le mot de passe")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .disabled(viewModel.isLoading)
                .padding(.horizontal)
                
                // Cancel button
                Button(action: {
                    dismiss()
                }) {
                    Text("Annuler")
                        .foregroundColor(.blue)
                }
                .padding(.bottom, 30)
                
                // Loading indicator
                if viewModel.isLoading {
                    ProgressView("Modification en cours...")
                }
            }
            .padding()
        }
        .navigationTitle("Modifier le mot de passe")
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text(viewModel.alertTitle),
                message: Text(viewModel.alertMessage),
                dismissButton: .default(Text("OK")) {
                    if viewModel.isSuccess {
                        dismiss()
                    }
                }
            )
        }
    }
}


// Add this to AuthService.swift
extension AuthService {
    struct ChangePasswordResponse: Decodable {
        let success: Bool
        let message: String
    }
    
    func changePassword(currentPassword: String, newPassword: String, confirmNewPassword: String) -> AnyPublisher<ChangePasswordResponse, Error> {
        guard let url = URL(string: "\(baseURL)/change-password") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = [
            "currentPassword": currentPassword,
            "newPassword": newPassword,
            "confirmPassword": confirmNewPassword
        ]
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: ChangePasswordResponse.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
