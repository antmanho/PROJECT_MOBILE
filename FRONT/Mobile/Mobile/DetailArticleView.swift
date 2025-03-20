import SwiftUI

struct DetailArticleView: View {
    let gameId: Int
    var onBack: (() -> Void)? = nil
    
    @State private var product: GameDetail? = nil
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    
    let baseURL = "http://localhost:3000"
    
    var body: some View {
        VStack {
            // Bouton retour placé séparément en haut
            HStack {
                Button(action: {
                    onBack?()
                }) {
                    HStack(spacing: 4) {
                        Image("retour") // Vérifiez que cette image est bien dans vos Assets
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            
            // Titre de la page
            Text("DETAIL DU PRODUIT")
                .font(.title)
                .bold()
                .foregroundColor(.primary)
                .padding(.horizontal, 16)
                .padding(.top, 8)
            
            if isLoading {
                Spacer()
                HStack {
                    Spacer()
                    ProgressView("Chargement...")
                    Spacer()
                }
                Spacer()
            } else if let product = product {
                ScrollView {
                    // Tout le contenu du produit dans un même cadre gris
                    VStack(spacing: 20) {
                        HStack(alignment: .top, spacing: 20) {
                            // Image du produit (dimensions ajustées)
                            if let url = URL(string: baseURL + product.photoPath) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 150, height: 150)
                                            .cornerRadius(8)
                                            .shadow(radius: 4)
                                    case .failure(_):
                                        Color.red
                                            .frame(width: 200, height: 200)
                                            .overlay(Text("Erreur").foregroundColor(.white))
                                    default:
                                        Color.gray
                                            .frame(width: 200, height: 200)
                                    }
                                }
                            } else {
                                Color.gray.frame(width: 200, height: 200)
                            }
                            
                            // Informations principales
                            VStack(alignment: .leading, spacing: 8) {
                                Text(product.nomJeu)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                // "N°article:" en noir, numéro en secondaire
                                HStack {
                                    Text("N°article: ")
                                        .foregroundColor(.black)
                                    Text("\(product.id)")
                                        .foregroundColor(.secondary)
                                }
                                .font(.subheadline)
                                
                                // "Prix:" en noir, le prix en secondaire
                                HStack {
                                    Text("Prix: ")
                                        .foregroundColor(.black)
                                    Text(String(format: "%.2f €", product.Prix_unit))
                                        .foregroundColor(.secondary)
                                }
                                .font(.subheadline)
                                
                                // "Éditeur:" en noir, le nom de l'éditeur en secondaire (si disponible)
                                if let editeur = product.editeur, !editeur.isEmpty {
                                    HStack {
                                        Text("Éditeur: ")
                                            .foregroundColor(.black)
                                        Text(editeur)
                                            .foregroundColor(.secondary)
                                    }
                                    .font(.subheadline)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(20)
                        
                        // Description dans le même cadre gris, en bas
                        if let description = product.description, !description.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Description: ")
                                        .foregroundColor(.black)
                                    Spacer()
                                }
                                .font(.headline)
                                Text(description)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                            .padding(20)
                        }
                    }
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .padding(.horizontal, 16)
                }
  
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
                Spacer()
            } else {
                Spacer()
                Text("Aucun produit trouvé")
                    .padding()
                Spacer()
            }
        }
        .onAppear {
            fetchProductDetail()
        }
    }
    
    private func fetchProductDetail() {
        guard let url = URL(string: "\(baseURL)/api/detail/\(gameId)") else {
            errorMessage = "URL invalide"
            return
        }
        isLoading = true
        URLSession.shared.dataTask(with: url) { data, response, error in
            defer { DispatchQueue.main.async { isLoading = false } }
            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = "Erreur: \(error.localizedDescription)"
                }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    errorMessage = "Aucune donnée reçue"
                }
                return
            }
            do {
                let decoder = JSONDecoder()
                let detail = try decoder.decode(GameDetail.self, from: data)
                DispatchQueue.main.async {
                    self.product = detail
                }
            } catch {
                DispatchQueue.main.async {
                    errorMessage = "Erreur de décodage: \(error)"
                }
            }
        }.resume()
    }
}

struct GameDetail: Decodable, Identifiable {
    let id: Int               // Correspond à id_stock
    let nomJeu: String        // Correspond à nom_jeu
    let Prix_unit: Double     // Correspond à Prix_unit
    let photoPath: String     // Correspond à photo_path
    let editeur: String?
    let description: String?
    let fraisDepotFixe: Int
    let fraisDepotPercent: Int
    let prixFinal: Double
    let estEnVente: Bool      // Converti depuis un entier (1 ou 0)
    
    private enum CodingKeys: String, CodingKey {
        case id = "id_stock"
        case nomJeu = "nom_jeu"
        case Prix_unit
        case photoPath = "photo_path"
        case editeur
        case description
        case fraisDepotFixe = "Frais_depot_fixe"
        case fraisDepotPercent = "Frais_depot_percent"
        case prixFinal = "prix_final"
        case estEnVente = "est_en_vente"
    }
    
    init(from decoder: Decoder) throws {
       let container = try decoder.container(keyedBy: CodingKeys.self)
       id = try container.decode(Int.self, forKey: .id)
       nomJeu = try container.decode(String.self, forKey: .nomJeu)
       Prix_unit = try container.decode(Double.self, forKey: .Prix_unit)
       photoPath = try container.decode(String.self, forKey: .photoPath)
       editeur = try container.decodeIfPresent(String.self, forKey: .editeur)
       description = try container.decodeIfPresent(String.self, forKey: .description)
       fraisDepotFixe = try container.decode(Int.self, forKey: .fraisDepotFixe)
       fraisDepotPercent = try container.decode(Int.self, forKey: .fraisDepotPercent)
       prixFinal = try container.decode(Double.self, forKey: .prixFinal)
       let estEnVenteInt = try container.decode(Int.self, forKey: .estEnVente)
       estEnVente = (estEnVenteInt == 1)
    }
}

struct DetailArticleView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DetailArticleView(gameId: 1, onBack: {
                // Action de retour pour la preview
            })
        }
    }
}
