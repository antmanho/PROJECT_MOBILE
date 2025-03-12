import SwiftUI
import Combine

struct SignUpView: View {
    @StateObject private var viewModel = SignUpViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showingAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Header
                Text("INSCRIPTION")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 30)
                
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
                    
                    // Password field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Mot de passe")
                            .font(.headline)
                        
                        SecureField("Entrez votre mot de passe", text: $viewModel.password)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(viewModel.passwordError != nil ? Color.red : Color.clear, lineWidth: 1)
                            )
                        
                        if let error = viewModel.passwordError {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    
                    // Confirm password field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Confirmez le mot de passe")
                            .font(.headline)
                        
                        SecureField("Confirmez votre mot de passe", text: $viewModel.confirmPassword)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(viewModel.confirmPasswordError != nil ? Color.red : Color.clear, lineWidth: 1)
                            )
                        
                        if let error = viewModel.confirmPasswordError {
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
                    viewModel.register()
                }) {
                    Text("S'inscrire")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .disabled(viewModel.isLoading)
                .padding(.horizontal)
                
                // Back to login link
                Button(action: {
                    dismiss()
                }) {
                    Text("Déjà inscrit ? Se connecter")
                        .foregroundColor(.blue)
                }
                .padding(.bottom, 30)
                
                // Loading indicator
                if viewModel.isLoading {
                    ProgressView("Inscription en cours...")
                }
            }
            .padding()
        }
        .navigationTitle("Inscription")
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text(viewModel.alertTitle),
                message: Text(viewModel.alertMessage),
                dismissButton: .default(Text("OK")) {
                    if viewModel.isSuccess {
                        // Navigate to verification screen or login screen
                        if viewModel.needsVerification {
                            viewModel.navigateToVerification()
                        } else {
                            dismiss()
                        }
                    }
                }
            )
        }
        .onChange(of: viewModel.navigationDestination) { destination in
            if let destination = destination {
                switch destination {
                case .verification(let email):
                    // Navigation would happen here using NavigationLink or other mechanism
                    print("Navigate to verification with email: \(email)")
                    // Reset the destination after navigation
                    viewModel.navigationDestination = nil
                }
            }
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SignUpView()
        }
    }
}// à voir 
// + à voir si on peut mettre un bouton pour retourner à la page de connexion