import SwiftUI
import Combine

struct ForgotPasswordView: View {
    @StateObject private var viewModel = ForgotPasswordViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 25) {
            // Header
            Text("Mot de passe oublié")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Entrez votre adresse email pour recevoir un lien de réinitialisation")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.bottom)
            
            // Email field
            VStack(alignment: .leading) {
                TextField("Email", text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                
                if let error = viewModel.emailError {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            
            }
    }
}