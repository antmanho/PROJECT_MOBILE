import SwiftUI

struct Game: Identifiable, Decodable {
    let id: Int               // Correspond à id_stock
    let nomJeu: String        // Correspond à nom_jeu
    let prixUnit: Double      // Correspond à Prix_unit
    let photoPath: String     // Correspond à photo_path
    let fraisDepotFixe: Int   // Correspond à Frais_depot_fixe
    let fraisDepotPercent: Int// Correspond à Frais_depot_percent
    let prixFinal: Double     // Correspond à prix_final
    var estEnVente: Bool      // Converti depuis un entier (1 ou 0)

    private enum CodingKeys: String, CodingKey {
        case id = "id_stock"
        case nomJeu = "nom_jeu"
        case prixUnit = "Prix_unit"
        case photoPath = "photo_path"
        case fraisDepotFixe = "Frais_depot_fixe"
        case fraisDepotPercent = "Frais_depot_percent"
        case prixFinal = "prix_final"
        case estEnVente = "est_en_vente"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.nomJeu = try container.decode(String.self, forKey: .nomJeu)
        self.prixUnit = try container.decode(Double.self, forKey: .prixUnit)
        self.photoPath = try container.decode(String.self, forKey: .photoPath)
        self.fraisDepotFixe = try container.decode(Int.self, forKey: .fraisDepotFixe)
        self.fraisDepotPercent = try container.decode(Int.self, forKey: .fraisDepotPercent)
        self.prixFinal = try container.decode(Double.self, forKey: .prixFinal)
        let estEnVenteValue = try container.decode(Int.self, forKey: .estEnVente)
        self.estEnVente = (estEnVenteValue == 1)
    }
    
    init(id: Int, nomJeu: String, prixUnit: Double, photoPath: String, fraisDepotFixe: Int, fraisDepotPercent: Int, prixFinal: Double, estEnVente: Bool) {
        self.id = id
        self.nomJeu = nomJeu
        self.prixUnit = prixUnit
        self.photoPath = photoPath
        self.fraisDepotFixe = fraisDepotFixe
        self.fraisDepotPercent = fraisDepotPercent
        self.prixFinal = prixFinal
        self.estEnVente = estEnVente
    }
}

struct CatalogueResponse: Decodable {
    let results: [Game]
}

struct CatalogueView: View {
    var games: [Game]         // Passé depuis le parent
    var onGameSelected: (Game) -> Void = { _ in }
    
    @State private var localGames: [Game] = [] // Données chargées localement
    @State private var searchText: String = ""
    
    let baseImageURL = BaseUrl.lien
    let columns = [GridItem(.adaptive(minimum: 160), spacing: 10)]
    
    var allGames: [Game] {
        return !games.isEmpty ? games : localGames
    }
    
    var filteredGames: [Game] {
        if searchText.isEmpty {
            return allGames
        } else {
            return allGames.filter { $0.nomJeu.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 10) {
                Text("CATALOGUE")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 10)
                
                HStack(spacing: 10) {
                    TextField("Rechercher...", text: $searchText)
                        .padding(8)
                        .background(Color.white)
                        .cornerRadius(5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.black, lineWidth: 2)
                        )
                    
                    Button(action: {
                        // Action de recherche éventuelle
                    }) {
                        Image("rechercher")
                            .resizable()
                            .scaledToFit()
                    }
                    .frame(width: 40, height: 40)
                    
                    Button(action: {
                        // Ouvrir une popup de filtres ou réglages
                    }) {
                        Image("reglage")
                            .resizable()
                            .scaledToFit()
                    }
                    .frame(width: 40, height: 40)
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
            }
            .background(Color.white)
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(filteredGames) { game in
                        Button(action: {
                            onGameSelected(game)
                        }) {
                            VStack(spacing: 0) {
                                Text(game.nomJeu)
                                    .font(.headline)
                                    .padding(.vertical, 5)
                                if let url = URL(string: baseImageURL + game.photoPath) {
                                    AsyncImage(url: url) { phase in
                                        if let image = phase.image {
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(height: 150)
                                                .clipped()
                                        } else if phase.error != nil {
                                            Color.red.frame(height: 150)
                                        } else {
                                            Color.gray.frame(height: 150)
                                        }
                                    }
                                } else {
                                    Color.gray.frame(height: 150)
                                }
                                VStack {
                                    Text("N°article : \(game.id)")
                                        .font(.subheadline)
                                    Divider()
                                    Text(String(format: "%.2f €", game.prixFinal))
                                        .font(.subheadline)
                                }
                                .padding(5)
                            }
                            .frame(width: 160)
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                            .padding(5)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
            Spacer()
        }
        .onTapGesture {
            self.hideKeyboard()
        }
        .background(Color(UIColor.systemGray6))
        .onAppear {
            if games.isEmpty {
                #if DEBUG
                if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
                    self.localGames = [
                        Game(id: 1, nomJeu: "Jeu Exemple 1", prixUnit: 10, photoPath: "/IMAGE/Cluedo.JPG", fraisDepotFixe: 5, fraisDepotPercent: 10, prixFinal: 15, estEnVente: true),
                        Game(id: 2, nomJeu: "Jeu Exemple 2", prixUnit: 20, photoPath: "/images/game2.jpg", fraisDepotFixe: 7, fraisDepotPercent: 12, prixFinal: 25, estEnVente: true)
                    ]
                } else {
                    fetchCatalogue()
                }
                #else
                fetchCatalogue()
                #endif
            }
        }
    }
    
    func fetchCatalogue() {
        guard let url = URL(string: "\(baseImageURL)/api/envente") else {
            print("URL invalide")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Erreur lors du chargement du catalogue: \(error)")
                return
            }
            
            guard let data = data else {
                print("Aucune donnée reçue")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let catalogue = try decoder.decode(CatalogueResponse.self, from: data)
                DispatchQueue.main.async {
                    self.localGames = catalogue.results
                }
            } catch {
                print("Erreur de décodage: \(error)")
            }
        }.resume()
    }
}

struct CatalogueView_Previews: PreviewProvider {
    static var previews: some View {
        CatalogueView(games: [], onGameSelected: { game in
            print("Jeu sélectionné: \(game.nomJeu)")
        })
    }
}
