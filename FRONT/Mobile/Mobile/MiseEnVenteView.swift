import SwiftUI

struct MiseEnVenteView: View {
    @State private var games: [Game] = []
    @State private var searchText: String = ""

    let baseImageURL = "http://localhost:3000"
    let columns = [GridItem(.adaptive(minimum: 160), spacing: 10)]
    var onGameSelected: (Game) -> Void = { _ in }

    var filteredGames: [Game] {
        if searchText.isEmpty {
            return games
        } else {
            return games.filter { $0.nomJeu.lowercased().contains(searchText.lowercased()) }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 10) {
                Text("MISE EN VENTE")
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
                    ForEach(filteredGames.indices, id: \.self) { index in
                        Button(action: {
                            onGameSelected(filteredGames[index])
                        }) {
                            VStack(spacing: 0) {
                                Text(filteredGames[index].nomJeu)
                                    .font(.headline)
                                    .padding(.vertical, 5)
                                if let url = URL(string: baseImageURL + filteredGames[index].photoPath) {
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
                                    Text("N°article : \(filteredGames[index].id)")
                                        .font(.subheadline)
                                    Divider()
                                    Text(String(format: "%.2f €", filteredGames[index].prixFinal))
                                        .font(.subheadline)
                                    Toggle("En vente", isOn: Binding(
                                        get: { filteredGames[index].estEnVente },
                                        set: { newValue in toggleEnVente(index: index, newValue: newValue) }
                                    ))
                                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                                }
                                .padding(5)
                            }
                            .frame(width: 160)
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                            .clipped() // Permet de masquer tout contenu débordant
                            .padding(5)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }

                }
                .padding()
            }
            Spacer()
        }
        .background(Color(UIColor.systemGray6))
        .onAppear {
            fetchCatalogue()
        }
    }

    func fetchCatalogue() {
        guard let url = URL(string: "\(baseImageURL)/api/catalogue") else {
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
                    self.games = catalogue.results
                }
            } catch {
                print("Erreur de décodage: \(error)")
            }
        }.resume()
    }

    func toggleEnVente(index: Int, newValue: Bool) {
        let game = filteredGames[index]
        guard let url = URL(string: "\(baseImageURL)/api/stock/\(game.id)/toggle-vente") else {
            print("URL invalide")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = ["est_en_vente": newValue]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Erreur lors de la mise à jour du statut de vente: \(error)")
            } else {
                DispatchQueue.main.async {
                    if let originalIndex = games.firstIndex(where: { $0.id == game.id }) {
                        games[originalIndex].estEnVente = newValue
                    }
                }
            }
        }.resume()
    }
}
