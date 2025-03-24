import SwiftUI

struct CheckEmailView: View {
    @StateObject private var viewModel: CheckEmailViewModel
    
    // Navigation
    let onRetour: () -> Void
    let onInvité: () -> Void
    let onVerificationSuccess: (String) -> Void
    
    init(email: String, onRetour: @escaping () -> Void, onInvité: @escaping () -> Void, onVerificationSuccess: @escaping (String) -> Void) {
        self._viewModel = StateObject(wrappedValue: CheckEmailViewModel(email: email))
        self.onRetour = onRetour
        self.onInvité = onInvité
        self.onVerificationSuccess = onVerificationSuccess
    }

    var body: some View {
        VStack {
            // Bouton retour
            HStack {
                Button(action: onRetour) {
                    Image("retour")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .padding(6)
                }
                Spacer()
            }
            .frame(maxWidth: .infinity)
            
            Spacer(minLength: 20)
            
            // Main content container
            VStack(spacing: 16) {
                VStack(spacing: 12) {
                    Text("VÉRIFICATION EMAIL")
                        .font(.custom("Bangers", size: 26))
                    
                    Image("lock")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70)
                        .padding(.top, 4)
                    
                    Text("Confirmation de l'email")
                        .font(.headline)
                    
                    Text("Afin de confirmer votre adresse, entrez le code reçu par e-mail.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 10)
                    
                    // Verification code input - bound to ViewModel
                    TextField("Code reçu", text: $viewModel.codeRecu)
                        .padding(8)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(5)
                        .keyboardType(.numberPad)
                    
                    // Verify button - calls ViewModel method
                    Button(action: {
                        viewModel.verifyCode { role in
                            onVerificationSuccess(role)
                        }
                    }) {
                        HStack {
                            if viewModel.isVerifying {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .padding(.trailing, 5)
                            }
                            Text("Vérifier")
                                .foregroundColor(.white)
                        }
                        .padding(10)
                        .frame(maxWidth: .infinity)
                        .background(Color.gray)
                        .cornerRadius(5)
                    }
                    .disabled(viewModel.isVerifying)
                    
                    // Error message from ViewModel
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding(.top, 4)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(10)
                .frame(maxWidth: .infinity)
                .border(Color.black, width: 1)
            }
            .frame(width: UIScreen.main.bounds.width * 0.8)
            
            Spacer(minLength: 20)
            
            Text("Barbedet Anthony & Delclaud Corentin production | Polytech school | © 2024 Boardland")
                .font(.footnote)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.bottom, 20)
        }
        .onTapGesture {
            hideKeyboard()
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

// Helper extension for keyboard handling toujours mais en anglais car c'est plus cool
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// Preview
struct CheckEmailView_Previews: PreviewProvider {
    static var previews: some View {
        CheckEmailView(
            email: "example@example.com",
            onRetour: {},
            onInvité: {},
            onVerificationSuccess: { _ in }
        )
    }
}