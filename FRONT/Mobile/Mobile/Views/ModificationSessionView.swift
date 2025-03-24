import SwiftUI
import UserNotifications

/// Vue pour la modification des sessions
struct ModificationSessionView: View {
    /// Liaison pour la navigation
    @Binding var selectedView: String
    
    /// ViewModel contenant la logique métier
    @StateObject private var viewModel = ModificationSessionViewModel()
    
    var body: some View {
        VStack {
            // Bouton retour
            navigationHeader
            
            // Barre de recherche
            searchBar
            
            // Message d'erreur
            errorMessage
            
            // Liste des sessions
            sessionList
            
            // Bouton de sauvegarde
            saveButton
            
            Spacer()
        }
        .onTapGesture {
            self.hideKeyboard()
        }
        .background(Color(UIColor.systemGroupedBackground))
        .overlay(
            loadingOverlay
        )
        .onAppear {
            viewModel.requestNotificationPermission()
            viewModel.fetchSessions()
        }
    }
    
    // MARK: - Sous-vues
    
    /// En-tête avec bouton retour et titre
    private var navigationHeader: some View {
        VStack {
            HStack {
                Button {
                    selectedView = "Session"
                } label: {
                    Image("retour")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .padding(4)
                }
                Spacer()
            }
            
            Text("MODIFICATION-SESSION")
                .font(.title2)
                .bold()
                .padding(.top, 10)
        }
    }
    
    /// Barre de recherche
    private var searchBar: some View {
        TextField("Rechercher...", text: $viewModel.searchText)
            .padding(6)
            .background(Color.white)
            .cornerRadius(5)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.black, lineWidth: 1)
            )
            .padding(.horizontal)
    }
    
    /// Message d'erreur
    private var errorMessage: some View {
        Group {
            if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }
        }
    }
    
    /// Liste des sessions
    private var sessionList: some View {
        ScrollView {
            VStack(spacing: 10) {
                ForEach(viewModel.filteredSessions, id: \.id) { session in
                    sessionCard(for: session)
                }
            }
            .padding(.vertical, 8)
        }
        .padding(.bottom, 20)
    }
    
    /// Carte d'une session individuelle
    private func sessionCard(for session: SessionMod) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("Nom", text: viewModel.binding(for: session, keyPath: \.nom))
                .font(.headline)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
            
            Group {
                // Adresse
                formField(title: "Adresse:", content: {
                    TextField("Adresse", text: viewModel.binding(for: session, keyPath: \.adresse))
                })
                
                // Date début
                formField(title: "Date début:", content: {
                    DatePicker("", selection: viewModel.dateBinding(for: session, keyPath: \.dateDebut), displayedComponents: .date)
                        .labelsHidden()
                })
                
                // Date fin
                formField(title: "Date fin:", content: {
                    DatePicker("", selection: viewModel.dateBinding(for: session, keyPath: \.dateFin), displayedComponents: .date)
                        .labelsHidden()
                })
                
                // Charge totale
                formField(title: "Charge totale:", content: {
                    TextField("Charge totale", value: viewModel.optionalDoubleBinding(for: session, keyPath: \.chargeTotale), formatter: ModificationSessionViewModel.decimalFormatter)
                        .keyboardType(.decimalPad)
                })
                
                // Frais fixe
                formField(title: "Frais dépôt fixe:", content: {
                    TextField("Frais fixe", value: viewModel.doubleBinding(for: session, keyPath: \.fraisFixe), formatter: ModificationSessionViewModel.decimalFormatter)
                        .keyboardType(.decimalPad)
                })
                
                // Frais pourcentage
                formField(title: "Frais dépôt %:", content: {
                    TextField("Frais %", value: viewModel.doubleBinding(for: session, keyPath: \.fraisPourcent), formatter: ModificationSessionViewModel.decimalFormatter)
                        .keyboardType(.decimalPad)
                })
                
                // Description
                formField(title: "Description:", alignment: .top, content: {
                    TextEditor(text: viewModel.binding(for: session, keyPath: \.description))
                        .frame(height: 40)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.gray.opacity(0.4))
                        )
                })
            }
            .font(.subheadline)
        }
        .padding(8)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(8)
        .padding(.horizontal, 8)
        .shadow(radius: 1)
    }
    
    /// Composant réutilisable pour les champs du formulaire
    private func formField<Content: View>(title: String, alignment: VerticalAlignment = .center, content: @escaping () -> Content) -> some View {
        HStack(alignment: alignment, spacing: 6) {
            Text(title)
                .bold()
            content()
        }
    }
    
    /// Bouton de sauvegarde
    private var saveButton: some View {
        Button(action: {
            viewModel.validateAndSaveChanges()
        }) {
            Text("Sauvegarder les modifications")
                .foregroundColor(.white)
                .padding(10)
                .frame(maxWidth: .infinity)
        }
        .background(Color.gray)
        .cornerRadius(6)
        .padding(.horizontal)
        .padding(.bottom, 15)
        .disabled(viewModel.isLoading)
    }
    
    /// Overlay de chargement
    private var loadingOverlay: some View {
        Group {
            if viewModel.isLoading {
                ZStack {
                    Color.black.opacity(0.3)
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                        
                        Text("Chargement...")
                            .foregroundColor(.white)
                            .padding(.top, 10)
                    }
                    .padding(20)
                    .background(Color.gray.opacity(0.8))
                    .cornerRadius(10)
                }
            }
        }
    }
    
    /// Masque le clavier
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

/// Prévisualisation pour Xcode
struct ModificationSessionView_Previews: PreviewProvider {
    static var previews: some View {
        ModificationSessionView(selectedView: .constant("Session"))
    }
}