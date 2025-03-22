import SwiftUI
import UserNotifications

/// Vue pour l'enregistrement d'un achat
struct EnregistrerAchatView: View {
    /// ViewModel contenant la logique et les données
    @StateObject private var viewModel = EnregistrerAchatViewModel()
    
    /// Callback pour transmettre les informations d'achat validées
    let onConfirmerAchat: (String, String) -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Arrière-plan
                Image("sport")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        Spacer(minLength: 40)
                        
                        // Formulaire
                        VStack(spacing: 15) {
                            // Titre
                            Text("ENREGISTRER UN ACHAT")
                                .font(.system(size: 24, weight: .bold))
                                .padding(.top, 10)
                            
                            // Message d'erreur
                            if !viewModel.errorMessage.isEmpty {
                                Text(viewModel.errorMessage)
                                    .foregroundColor(.red)
                                    .padding(.horizontal)
                            }
                            
                            // Champs de saisie
                            TextField("ID Stock", text: $viewModel.idStock)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal)
                                .keyboardType(.numberPad)
                            
                            TextField("Quantité Vendue", text: $viewModel.quantiteVendue)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal)
                                .keyboardType(.numberPad)
                            
                            // Bouton de confirmation
                            Button {
                                viewModel.confirmerAchat()
                                
                                // Si succès, appeler le callback
                                if viewModel.isSuccess {
                                    onConfirmerAchat(viewModel.idStock, viewModel.quantiteVendue)
                                }
                            } label: {
                                HStack {
                                    // Indicateur de chargement
                                    if viewModel.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .padding(.trailing, 5)
                                    }
                                    Text("Confirmer l'achat")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(viewModel.isFormValid ? Color.blue : Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            .disabled(!viewModel.isFormValid || viewModel.isLoading)
                            .padding(.horizontal)
                        }
                        .padding()
                        .frame(maxWidth: 300)
                        .background(Color.white.opacity(0.97))
                        .cornerRadius(15)
                        .shadow(radius: 5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.black, lineWidth: 2)
                        )
                        
                        Spacer(minLength: 60)
                    }
                }
            }
        }
        .onTapGesture {
            // Masquer le clavier quand on touche ailleurs
            hideKeyboard()
        }
        .onAppear {
            // Demander l'autorisation pour les notifications
            viewModel.requestNotificationPermission()
        }
    }
    
    /// Fonction pour masquer le clavier
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

/// Prévisualisation pour Xcode
struct EnregistrerAchatView_Previews: PreviewProvider {
    static var previews: some View {
        EnregistrerAchatView(onConfirmerAchat: { _, _ in })
    }
}