import SwiftUI

struct RetraitListeView: View {
    let email: String
    let onRetour: () -> Void
    
    @State private var jeux: [Jeu] = []

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ScrollView {
                    VStack(spacing: 20) {
                        Spacer(minLength: 30)
                        
                        // Bouton retour + Titre
                        HStack {
                            Button(action: onRetour) {
                                Image("retour")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                            }
                            .padding(.leading, 20)
                            
                            Spacer()
                            
                            Text("Retirer jeu")
                                .font(.system(size: 22, weight: .bold))
                                .padding(.trailing, 50)
                            
                            Spacer()
                        }
                        .padding(.top, 10)
                        
                        // Tableau de jeux
                        VStack(spacing: 0) {
                            // Ligne d'entête
                            HStack(spacing: 0) {
                                cellHeader("ID Stock", geometry: geometry)
                                cellHeader("Nom du Jeu", geometry: geometry)
                                cellHeader("Prix Demandé", geometry: geometry)
                                cellHeader("Sélection", geometry: geometry)
                            }
                            .frame(height: 40)
                            .background(Color.gray.opacity(0.2))

                            // Lignes de jeux
                            ForEach($jeux) { $jeu in
                                HStack(spacing: 0) {
                                    cellBody("\(jeu.id_stock)", geometry: geometry)
                                    cellBody(jeu.nom_jeu, geometry: geometry)
                                    cellBody(String(format: "%.2f€", jeu.prix_unit), geometry: geometry)

                                    // "Checkbox"
                                    HStack {
                                        Toggle("", isOn: $jeu.selectionne)
                                            .labelsHidden()
                                            .frame(width: 30, height: 30)
                                            .tint(.blue)
                                    }
                                    .frame(width: largeurColonne(geometry), height: 40)
                                    .border(Color.black)
                                }
                            }
                        }
                        .border(Color.black)
                        .frame(width: geometry.size.width * 0.9)
                        .padding(.horizontal, geometry.size.width * 0.05)

                        // Bouton retirer
                        Button(action: retirerJeux) {
                            Text("Retirer les jeux sélectionnés")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .font(.system(size: 17, weight: .bold))
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer(minLength: 50)
                    }
                }
            }
            .onAppear(perform: fetchJeux)
        }
    }

    private func fetchJeux() {
        self.jeux = [
            Jeu(id_stock: 101, nom_jeu: "Monopoly", prix_unit: 15.0, quantiteActuelle: 2),
            Jeu(id_stock: 202, nom_jeu: "Catan", prix_unit: 20.0, quantiteActuelle: 1),
            Jeu(id_stock: 303, nom_jeu: "7 Wonders", prix_unit: 25.0, quantiteActuelle: 3)
        ]
    }

    private func retirerJeux() {
        jeux.removeAll(where: \Jeu.selectionne)
    }

    private func largeurColonne(_ geometry: GeometryProxy) -> CGFloat {
        (geometry.size.width * 0.9) / 4
    }

    private func cellHeader(_ text: String, geometry: GeometryProxy) -> some View {
        Text(text)
            .font(.system(size: 14, weight: .bold))
            .multilineTextAlignment(.center)
            .frame(width: largeurColonne(geometry), height: 40)
            .border(Color.black)
    }

    private func cellBody(_ text: String, geometry: GeometryProxy) -> some View {
        Text(text)
            .font(.system(size: 13))
            .multilineTextAlignment(.center)
            .frame(width: largeurColonne(geometry), height: 40)
            .border(Color.black)
    }
}

struct Jeu: Identifiable {
    let id_stock: Int
    let nom_jeu: String
    let prix_unit: Double
    var quantiteActuelle: Int
    var selectionne: Bool = false

    var id: Int { id_stock }
}
