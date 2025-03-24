import SwiftUI

struct ConnexionView: View {
    @StateObject private var viewModel = ConnexionViewModel()
    
    let onMotDePasseOublie: () -> Void
    let onInscription: () -> Void
    let onLoginSuccess: (String) -> Void

    var body: some View {
        VStack {
            Spacer(minLength: 20)
            
            // Conteneur commun à largeur fixe
            VStack(spacing: 16) {
                // Premier cadre (Formulaire de connexion)
                VStack(spacing: 12) {
                    Text("CONNEXION")
                        .font(.custom("Bangers", size: 26))
                        .padding(.bottom, 6)
                    
                    VStack(spacing: 8) {
                        // Champs de formulaire liés au ViewModel
                        TextField("Email", text: $viewModel.email)
                            .padding(8)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(5)
                            .autocapitalization(.none)
                        
                        SecureField("Mot de passe", text: $viewModel.password)
                            .padding(8)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(5)
                        
                        // Bouton de connexion appelle la méthode login du ViewModel
                        Button(action: {
                            viewModel.login { role in
                                onLoginSuccess(role)
                            }
                        }) {
                            HStack {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .padding(.trailing, 5)
                                }
                                Text("Se connecter")
                                    .foregroundColor(.white)
                            }
                            .padding(10)
                            .frame(maxWidth: .infinity)
                            .background(viewModel.isFormValid ? Color.gray : Color.gray.opacity(0.5))
                            .cornerRadius(5)
                        }
                        .disabled(!viewModel.isFormValid || viewModel.isLoading)
                        .padding(.top, 8)
                        
                        // Message d'erreur du ViewModel
                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .padding(.top, 4)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(10)
                    
                    DividerView()
                    
                    Button(action: onMotDePasseOublie) {
                        Text("Mot de passe oublié ?")
                            .foregroundColor(.blue)
                    }
                    .padding(.top, 8)
                }
                .padding(10)
                .frame(maxWidth: .infinity)
                .border(Color.black, width: 1)
                
                // Second cadre (Lien vers inscription)
                VStack {
                    HStack {
                        Text("Vous n'avez pas de compte ?")
                        Button(action: onInscription) {
                            Text("Inscrivez-vous")
                                .foregroundColor(.blue)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .padding(10)
                .frame(maxWidth: .infinity)
                .border(Color.black, width: 1)
            }
            .frame(width: UIScreen.main.bounds.width * 0.8)
            .fixedSize(horizontal: false, vertical: true)
            
            Spacer(minLength: 20)
            
            Text("Barbedet Anthony & Delclaud Corentin production | Polytech school | © 2024 Boardland")
                .font(.footnote)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .onTapGesture {
            hideKeyboard()
        }
    }
}

// Divider component unchanged
struct DividerView: View {
    var body: some View {
        HStack {
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.black)
            Text("OU")
                .padding(.horizontal, 6)
                .background(Color.white)
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.black)
        }
        .padding(.vertical, 6)
    }
}

// Keep the hide keyboard extension
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// Preview for Xcode
struct ConnexionView_Previews: PreviewProvider {
    static var previews: some View {
        ConnexionView(
            onMotDePasseOublie: {},
            onInscription: {},
            onLoginSuccess: { _ in }
        )
    }
}