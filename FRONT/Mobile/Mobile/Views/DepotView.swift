import SwiftUI
import PhotosUI
import UserNotifications

/// Vue pour le dépôt de jeux
struct DepotView: View {
    /// ViewModel pour gérer toute la logique
    @StateObject private var viewModel = DepotViewModel()
    
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
                    VStack {
                        Spacer(minLength: 40)
                        
                        // Conteneur principal
                        VStack(spacing: 10) {
                            // Titre
                            Text("DEPOT")
                                .font(.system(size: 24, weight: .bold))
                                .padding(.top, 10)
                            
                            // Message d'erreur
                            if !viewModel.errorMessage.isEmpty {
                                Text(viewModel.errorMessage)
                                    .foregroundColor(.red)
                                    .padding(.horizontal)
                            }
                            
                            // Option de mise en vente
                            Toggle("Mise en vente immédiate", isOn: $viewModel.estEnVente)
                                .tint(.blue)
                                .padding(.horizontal)
                            
                            // Sélecteur de session
                            Picker("Sélectionnez une session", selection: Binding(
                                get: { viewModel.selectedSession?.id ?? -1 },
                                set: { newValue in
                                    if newValue == -1 {
                                        viewModel.selectedSession = nil
                                    } else {
                                        viewModel.selectedSession = viewModel.sessions.first { $0.id == newValue }
                                    }
                                }
                            )) {
                                Text("Sélectionnez une session").tag(-1)
                                ForEach(viewModel.sessions) { session in
                                    Text(session.nomSession).tag(session.id)
                                }
                            }
                            .pickerStyle(.menu)
                            .padding(.horizontal)
                            
                            // Affichage des informations de la session
                            if let session = viewModel.selectedSession {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Session: \(session.nomSession)")
                                        .fontWeight(.medium)
                                    Text("Adresse: \(session.adresseSession)")
                                    Text("Période: \(viewModel.formatDate(session.dateDebut)) - \(viewModel.formatDate(session.dateFin))")
                                    Text("Frais dépôt fixe: \(String(format: "%.2f €", session.fraisDepotFixe))")
                                    Text("Frais dépôt (%): \(String(format: "%.1f%%", session.fraisDepotPercent))")
                                    
                                    if !session.descriptionSession.isEmpty {
                                        Text("Description: \(session.descriptionSession)")
                                            .font(.caption)
                                            .lineLimit(2)
                                    }
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.blue.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.blue, lineWidth: 1)
                                        )
                                )
                                .padding(.horizontal)
                            }
                            
                            // Champs obligatoires
                            TextField("Email du vendeur", text: $viewModel.emailVendeur)
                                .textFieldStyle(.roundedBorder)
                                .padding(.horizontal)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                            
                            TextField("Nom du Jeu", text: $viewModel.nomJeu)
                                .textFieldStyle(.roundedBorder)
                                .padding(.horizontal)
                            
                            TextField("Prix Unitaire (on lui devra)", text: $viewModel.prixUnit)
                                .textFieldStyle(.roundedBorder)
                                .padding(.horizontal)
                                .keyboardType(.decimalPad)
                            
                            TextField("Quantité", text: $viewModel.quantiteDeposee)
                                .textFieldStyle(.roundedBorder)
                                .padding(.horizontal)
                                .keyboardType(.numberPad)
                            
                            // Bouton pour afficher/masquer les champs optionnels
                            Button {
                                viewModel.showOptionalFields.toggle()
                            } label: {
                                Text(viewModel.showOptionalFields
                                     ? "▲ Masquer les champs optionnels"
                                     : "▼ Afficher les champs optionnels")
                                    .foregroundColor(.blue)
                            }
                            .padding(.top, 5)
                            
                            // Champs optionnels
                            if viewModel.showOptionalFields {
                                TextField("Éditeur", text: $viewModel.editeur)
                                    .textFieldStyle(.roundedBorder)
                                    .padding(.horizontal)
                                
                                TextEditor(text: $viewModel.description)
                                    .frame(height: 100)
                                    .border(Color.gray, width: 1)
                                    .padding(.horizontal)
                                
                                // Sélecteur d'image
                                PhotosPicker(selection: $viewModel.photosPickerItem, matching: .images, photoLibrary: .shared()) {
                                    HStack {
                                        Image(systemName: "photo.on.rectangle")
                                            .font(.system(size: 20))
                                        Text("Choisir une image")
                                            .fontWeight(.medium)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(10)
                                    .padding(.horizontal)
                                }
                                
                                // Affichage de l'image sélectionnée
                                if let selectedImage = viewModel.selectedImage {
                                    Image(uiImage: selectedImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxWidth: 250, maxHeight: 250)
                                        .cornerRadius(10)
                                        .padding(.horizontal)
                                }
                            }
                            
                            // Bouton d'envoi
                            Button {
                                viewModel.submitDepot()
                            } label: {
                                HStack {
                                    if viewModel.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .padding(.trailing, 5)
                                    }
                                    Text("Ajouter")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(viewModel.isFormValid ? Color.blue : Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .padding(.horizontal)
                            }
                            .disabled(!viewModel.isFormValid || viewModel.isLoading)
                        }
                        .padding()
                        .frame(maxWidth: 320)
                        .background(Color.white)
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
            self.hideKeyboard()
        }
        .onAppear {
            viewModel.loadSessions()
            viewModel.requestNotificationPermission()
        }
    }
    
    /// Fonction pour masquer le clavier lorsqu'on tapote ailleurs sur l'écran
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

/// Prévisualisation pour SwiftUI Preview
struct DepotView_Previews: PreviewProvider {
    static var previews: some View {
        DepotView()
    }
}