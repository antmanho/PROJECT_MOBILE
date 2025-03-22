import SwiftUI

// Le modèle Game est déjà défini dans votre projet
// struct Game: Identifiable, Decodable { ... }

// Structure SoldGame adaptée à la réponse de /api/vendus
struct SoldGame: Identifiable, Decodable {
    let id = UUID() // Pour SwiftUI, on génère un identifiant unique
    let nomJeu: String      // Correspond à nom_jeu
    let prixUnit: Double    // Correspond à Prix_unit
    let photoPath: String   // Correspond à photo_path
    let quantiteVendue: Int // Correspond à Quantite_vendu

    private enum CodingKeys: String, CodingKey {
        case nomJeu = "nom_jeu", prixUnit = "Prix_unit", photoPath = "photo_path", quantiteVendue = "Quantite_vendu"
    }
}

// Réponse pour le catalogue vendeur
struct CatalogueResponse2: Decodable {
    let results: [Game]
    let email_connecte: String
}

class VendeurViewModel: ObservableObject {
    @Published var games: [Game] = []
    @Published var soldGames: [SoldGame] = []
    @Published var emailConnecte: String? = nil
    @Published var errorMessage: String? = nil
    
    private let baseURL = BaseUrl.lien

    init() {
        fetchCatalogue()
        fetchSoldGames()
    }
    
    func fetchCatalogue() {
        guard let url = URL(string: "\(baseURL)/api/catalogue-vendeur") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Erreur lors du chargement du catalogue: \(error.localizedDescription)"
                }
                return
            }
            guard let data = data else { return }
            
            do {
                let CatalogueResponse2 = try JSONDecoder().decode(CatalogueResponse2.self, from: data)
                DispatchQueue.main.async {
                    self.games = CatalogueResponse2.results
                    self.emailConnecte = CatalogueResponse2.email_connecte
                    self.errorMessage = nil
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Erreur de décodage: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
    
    func fetchSoldGames() {
        guard let url = URL(string: "\(baseURL)/api/vendus") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Erreur lors du chargement des jeux vendus: \(error.localizedDescription)"
                }
                return
            }
            guard let data = data else { return }
            
            do {
                let soldGames = try JSONDecoder().decode([SoldGame].self, from: data)
                DispatchQueue.main.async {
                    self.soldGames = soldGames
                    self.errorMessage = nil
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Erreur de décodage: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}

struct VendeurView: View {
    @StateObject private var viewModel = VendeurViewModel()
    
    // États pour le formulaire du bilan
    @State private var sessionParticuliere: Bool = false
    @State private var numeroSession: String = ""
    @State private var chargesFixes: String = ""
    
    // Callback pour afficher le graphe vendeur
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
                
                // Section Voir bilan personnel
                VStack(spacing: 20) {
                    VStack(spacing: 15) {
                        HStack {
                            Text("Toutes les sessions")
                            Toggle("", isOn: $sessionParticuliere)
                                .labelsHidden()
                            Text("Session particulière")
                        }
                        
                        if sessionParticuliere {
                            TextField("Entrez le numéro de session", text: $numeroSession)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                        }
                        
                        TextField("Entrez les charges fixes", text: $chargesFixes)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                        
                        Button(action: {
                            let data = BilanData(
                                bilanParticulier: false,
                                sessionParticuliere: sessionParticuliere,
                                emailParticulier: viewModel.emailConnecte ?? "",
                                numeroSession: numeroSession,
                                chargesFixes: Double(chargesFixes) ?? 0
                            )
                            onAfficherGraphe(data)
                        }) {
                            Text("Voir le Bilan")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.black)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                    .frame(maxWidth: 300)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)
                    .shadow(radius: 5)
                }
                .padding(.horizontal)
                
                // Section Mes jeux vendus
                VStack(spacing: 20) {
                    Text("MES JEUX VENDUS")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    if viewModel.soldGames.isEmpty {
                        Text("Vous n'avez pas encore vendu de jeux.")
                            .foregroundColor(.gray)
                            .font(.title3)
                    }else {
                        ForEach(viewModel.soldGames) { soldGame in
                            CardView(
                                title: soldGame.nomJeu,
                                imageUrl: BaseUrl.lien + soldGame.photoPath,
                                details: """
                                Prix : \(String(format: "%.2f", soldGame.prixUnit)) €
                                Quantité vendue : \(soldGame.quantiteVendue)
                                """
                            )
                        }
                    }

                    
                    // Section Mes jeux déposés
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
                                        imageUrl: BaseUrl.lien + game.photoPath,
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
                .padding(.vertical)
            }
        }
        .onTapGesture {
            self.hideKeyboard()
        }
    }
    
    
    // Vue réutilisable pour afficher une carte de jeu
    struct CardView: View {
        let title: String
        let imageUrl: String
        let details: String
        
        var body: some View {
            VStack(alignment: .center, spacing: 10) {
                Text(title)
                    .font(.headline)
                
                AsyncImage(url: URL(string: imageUrl)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 200, height: 150)
                        .clipped()
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 200, height: 150)
                }
                
                Text(details)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 4)
            .padding(5)
        }
    }
    
    
}
