import SwiftUI
import UserNotifications

/// Vue pour la création d'une nouvelle session
struct CreerSessionView: View {
    /// ViewModel gérant toute la logique et les données
    @StateObject private var viewModel = CreerSessionViewModel()
    
    /// Callback pour retourner à l'écran précédent
    let onRetour: () -> Void
    
    /// Callback pour la gestion de la session créée
    let onSessionCreated: ((Session) -> Void)?

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
                
                VStack(spacing: 0) {
                    // Bouton retour en haut à gauche
                    HStack {
                        Button(action: onRetour) {
                            Image("retour")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .padding()
                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    
                    Spacer()
                    
                    // Formulaire dans un ScrollView
                    ScrollView {
                        VStack(spacing: 15) {
                            // Titre du formulaire
                            Text("CRÉER SESSION")
                                .font(.custom("Bangers", size: 30))
                                .padding(.top, 10)
                            
                            // Message d'erreur si présent
                            if !viewModel.errorMessage.isEmpty {
                                Text(viewModel.errorMessage)
                                    .foregroundColor(.red)
                                    .padding(.horizontal)
                            }
                            
                            // Message de succès si session créée
                            if viewModel.isSuccess {
                                Text("Session créée avec succès!")
                                    .foregroundColor(.green)
                                    .padding(.horizontal)
                            }
                            
                            // Champs du formulaire liés au ViewModel
                            Group {
                                TextField("Nom de la session", text: $viewModel.nomSession)
                                    .textFieldStyle(.roundedBorder)
                                
                                TextField("Adresse", text: $viewModel.adresseSession)
                                    .textFieldStyle(.roundedBorder)
                                
                                // Sélecteurs de dates
                                HStack(spacing: 10) {
                                    VStack(alignment: .leading) {
                                        Text("Date Début :")
                                            .font(.subheadline)
                                        DatePicker("", selection: $viewModel.dateDebut, displayedComponents: .date)
                                            .labelsHidden()
                                    }
                                    .frame(maxWidth: .infinity)
                                    
                                    VStack(alignment: .leading) {
                                        Text("Date Fin :")
                                            .font(.subheadline)
                                        DatePicker("", selection: $viewModel.dateFin, displayedComponents: .date)
                                            .labelsHidden()
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                                
                                // Champs pour les frais
                                TextField("Frais dépôt fixe (€)", text: $viewModel.fraisDepotFixe)
                                    .textFieldStyle(.roundedBorder)
                                    .keyboardType(.decimalPad)
                                
                                TextField("Frais dépôt variable (%)", text: $viewModel.fraisDepotPercent)
                                    .textFieldStyle(.roundedBorder)
                                    .keyboardType(.decimalPad)
                            }
                            .padding(.horizontal)
                            
                            // Bouton pour afficher/masquer les champs optionnels
                            Button(action: {
                                viewModel.showOptionalFields.toggle()
                            }) {
                                Text(viewModel.showOptionalFields ? "▲ Masquer les champs optionnels" : "▼ Afficher les champs optionnels")
                                    .foregroundColor(.blue)
                            }
                            
                            // Champs optionnels (description)
                            if viewModel.showOptionalFields {
                                TextEditor(text: $viewModel.descriptionSession)
                                    .frame(height: 80)
                                    .border(Color.gray, width: 1)
                                    .padding(.horizontal)
                            }
                            
                            // Bouton de création avec indicateur de chargement
                            Button(action: {
                                viewModel.creerSession()
                                
                                // Si une session est créée et qu'un callback est fourni, on l'appelle
                                if let session = viewModel.createdSession, let onSessionCreated = onSessionCreated {
                                    onSessionCreated(session)
                                }
                            }) {
                                HStack {
                                    if viewModel.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .padding(.trailing, 5)
                                    }
                                    Text("CRÉER SESSION")
                                }
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(viewModel.isFormValid ? Color.blue : Color.gray)
                                .cornerRadius(10)
                            }
                            .disabled(!viewModel.isFormValid || viewModel.isLoading)
                            .padding(.horizontal)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(radius: 5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.black, lineWidth: 2)
                        )
                        .frame(width: geometry.size.width * 0.9)
                    }
                    
                    Spacer()
                }
            }
        }
        .onTapGesture {
            // Masquer le clavier quand on touche ailleurs
            hideKeyboard()
        }
        .onAppear {
            // Demander l'autorisation pour les notifications au chargement
            viewModel.requestNotificationPermission()
        }
        // Observer les changements dans le ViewModel
        .onChange(of: viewModel.createdSession) { newSession in
            if let session = newSession, let onSessionCreated = onSessionCreated {
                onSessionCreated(session)
            }
        }
    }
    
    /// Masque le clavier virtuel
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

/// Prévisualisation pour Xcode
struct CreerSessionView_Previews: PreviewProvider {
    static var previews: some View {
        CreerSessionView(onRetour: {}, onSessionCreated: nil)
    }
}