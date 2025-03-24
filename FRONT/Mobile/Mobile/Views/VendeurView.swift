import SwiftUI

struct VendeurView: View {
    @StateObject private var viewModel = VendeurViewModel()
    
    let onAfficherGraphe: (BilanData) -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("TABLEAU DE BORD")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                        .padding()
                }
                bilanFormSection
                soldGamesSection
                deposedGamesSection
            }
            .padding(.vertical)
        }
        .onTapGesture {
            hideKeyboard()
        }
        .refreshable {
            viewModel.fetchCatalogue()
            viewModel.fetchSoldGames()
        }
    }
    
    // MARK: - Sous-vues
    
    private var bilanFormSection: some View {
        VStack(spacing: 20) {
            VStack(spacing: 15) {
                HStack {
                    Text("Toutes les sessions")
                    Toggle("", isOn: $viewModel.sessionParticuliere)
                        .labelsHidden()
                    Text("Session particulière")
                }
                
                if viewModel.sessionParticuliere {
                    TextField("Entrez le numéro de session", text: $viewModel.numeroSession)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                }
                
                TextField("Entrez les charges fixes", text: $viewModel.chargesFixes)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
                
                Button(action: {
                    let bilanData = viewModel.createBilanData()
                    onAfficherGraphe(bilanData)
                }) {
                    Text("Voir le Bilan")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.isFormValid ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(!viewModel.isFormValid)
            }
            .padding()
            .frame(maxWidth: 300)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(10)
            .shadow(radius: 5)
        }
        .padding(.horizontal)
    }
    
    private var soldGamesSection: some View {
        VStack(spacing: 20) {
            Text("MES JEUX VENDUS")
                .font(.title2)
                .fontWeight(.semibold)
            
            if viewModel.soldGames.isEmpty {
                Text("Vous n'avez pas encore vendu de jeux.")
                    .foregroundColor(.gray)
                    .font(.title3)
            } else {
                ForEach(viewModel.soldGames) { soldGame in
                    CardView(
                        title: soldGame.nomJeu,
                        imageUrl: BaseUrl.lien + soldGame.photoPath,
                        details: """
                        Prix : \(soldGame.prixFormatte)
                        Quantité vendue : \(soldGame.quantiteVendue)
                        """
                    )
                }
            }
        }
        .padding(.horizontal)
    }
    
    private var deposedGamesSection: some View {
        VStack(spacing: 20) {
            Text("MES JEUX DEPOSES")
                .font(.title2)
                .fontWeight(.semibold)
            
            if viewModel.games.isEmpty {
                Text("Vous n'avez pas encore déposé de jeux en vente.")
                    .foregroundColor(.gray)
                    .font(.title3)
            } else {
                ForEach(viewModel.games) { game in
                    NavigationLink(destination: DetailArticleView(gameId: game.id)) {
                        CardView(
                            title: game.nomJeu,
                            imageUrl: BaseUrl.lien + (game.photoPath ?? ""),
                            details: """
                            N°article : \(game.id)
                            \(String(format: "%.2f", game.prixFinal)) €
                            Est en vente : \(game.estEnVente ? "OUI" : "NON")
                            """
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Méthodes utilitaires
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

/// Prévisualisation pour Xcode
struct VendeurView_Previews: PreviewProvider {
    static var previews: some View {
        VendeurView { _ in }
    }
}