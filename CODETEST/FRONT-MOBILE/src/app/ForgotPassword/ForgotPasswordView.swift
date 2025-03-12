import SwiftUI
import Combine

struct ForgotPasswordView: View {
    @StateObject private var viewModel = ForgotPasswordViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                Text("RÉINITIALISER VOTRE MOT DE PASSE")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.top, 30)
                    .padding(.horizontal)
                
                // Description
                Text("Entrez votre adresse e-mail et nous vous enverrons un lien pour réinitialiser votre mot de passe.")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Form fields
                VStack(alignment: .leading, spacing: 20) {
                    // Email field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.headline)
                        
                        TextField("Entrez votre adresse email", text: $viewModel.email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(viewModel.emailError != nil ? Color.red : Color.clear, lineWidth: 1)
                            )
                        
                        if let error = viewModel.emailError {
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
                    viewModel.resetPassword()
                }) {
                    Text("Envoyer le lien de réinitialisation")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .disabled(viewModel.isLoading)
                .padding(.horizontal)
                
                // Back link
                Button(action: {
                    dismiss()
                }) {
                    Text("Retourner à la page de connexion")
                        .foregroundColor(.blue)
                }
                .padding(.bottom, 30)
                
                // Loading indicator
                if viewModel.isLoading {
                    ProgressView("Envoi en cours...")
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Mot de passe oublié")
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

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ForgotPasswordView()
        }
    }
}