import SwiftUI

struct BilanView: View {
    @State private var bilanParticulier = false
    @State private var sessionParticuliere = false
    @State private var emailParticulier = ""
    @State private var numeroSession = ""
    @State private var chargesFixes = ""
    
    // Closure appelée avec les données récupérées du back pour afficher les graphes
    let onAfficherBilanGraphe: (BilanGraphData) -> Void
    
    // Base URL de votre back
    let baseURL = BaseUrl.lien
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image("sport")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                ScrollView {
                    VStack {
                        Spacer(minLength: 40)
                        VStack(spacing: 15) {
                            Text("BILAN")
                                .font(.system(size: 24, weight: .bold))
                                .padding(.top, 10)
                            
                            // Saisie des charges fixes
                            TextField("Charges fixes", text: $chargesFixes)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.decimalPad)
                                .padding(.horizontal)
                            
                            // Toggle bilan particulier
                            Toggle("Bilan particulier", isOn: $bilanParticulier)
                                .tint(.blue)
                                .padding(.horizontal)
                            
                            if bilanParticulier {
                                TextField("Email particulier", text: $emailParticulier)
                                    .textFieldStyle(.roundedBorder)
                                    .keyboardType(.emailAddress)
                                    .padding(.horizontal)
                            }
                            
                            // Toggle session particulière
                            Toggle("Session particulière", isOn: $sessionParticuliere)
                                .tint(.blue)
                                .padding(.horizontal)
                            
                            if sessionParticuliere {
                                TextField("Numéro de session", text: $numeroSession)
                                    .textFieldStyle(.roundedBorder)
                                    .keyboardType(.numberPad)
                                    .padding(.horizontal)
                            }
                            
                            Button {
                                fetchBilanData()
                            } label: {
                                Text("Créer le Bilan")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal)
                        }
                        .padding()
                        .frame(maxWidth: 320)
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
    }
    
    // Fonction qui construit l'URL avec les paramètres et appelle le back-end
    private func fetchBilanData() {
        // Conversion de chargesFixes (si vide, utiliser "0")
        let charges = chargesFixes.isEmpty ? "0" : chargesFixes
        let bilanPartStr = bilanParticulier ? "true" : "false"
        let sessionPartStr = sessionParticuliere ? "true" : "false"
        
        var components = URLComponents(string: "\(baseURL)/bilan-graphe")!
        components.queryItems = [
            URLQueryItem(name: "bilanParticulier", value: bilanPartStr),
            URLQueryItem(name: "sessionParticuliere", value: sessionPartStr),
            URLQueryItem(name: "emailParticulier", value: emailParticulier),
            URLQueryItem(name: "numeroSession", value: numeroSession),
            URLQueryItem(name: "chargesFixes", value: charges)
        ]
        
        guard let url = components.url else {
            print("URL invalide")
            return
        }
        print("URL bilan: \(url.absoluteString)")
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Erreur lors du chargement du bilan: \(error)")
                return
            }
            guard let data = data else {
                print("Aucune donnée reçue")
                return
            }
            do {
                let bilanData = try JSONDecoder().decode(BilanGraphData.self, from: data)
                DispatchQueue.main.async {
                    onAfficherBilanGraphe(bilanData)
                }
            } catch {
                print("Erreur de décodage du bilan: \(error)")
            }
        }.resume()
    }
}

struct BilanGraphData: Decodable {
    let listeYSomme: [Double]
    let listeY2Somme: [Double]
    let listeY3Somme: [Double]
    let listeX: [Int]
    let totalQuantiteDeposee: Double
    let totalQuantiteVendu: Int
    let chargesFixes: Double

    enum CodingKeys: String, CodingKey {
        case listeYSomme, listeY2Somme, listeY3Somme, listeX, totalQuantiteDeposee, totalQuantiteVendu, chargesFixes
    }

    // Initialiseur personnalisé pour le décodage
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.listeYSomme = try container.decode([Double].self, forKey: .listeYSomme)
        self.listeY2Somme = try container.decode([Double].self, forKey: .listeY2Somme)
        self.listeY3Somme = try container.decode([Double].self, forKey: .listeY3Somme)
        self.listeX = try container.decode([Int].self, forKey: .listeX)
        self.totalQuantiteDeposee = try container.decode(Double.self, forKey: .totalQuantiteDeposee)
        self.totalQuantiteVendu = try container.decode(Int.self, forKey: .totalQuantiteVendu)
        
        if let charges = try? container.decode(Double.self, forKey: .chargesFixes) {
            self.chargesFixes = charges
        } else {
            let chargesString = try container.decode(String.self, forKey: .chargesFixes)
            self.chargesFixes = Double(chargesString) ?? 0.0
        }
    }
    
    // Initialiseur membre explicite pour pouvoir créer des instances manuellement
    init(listeYSomme: [Double], listeY2Somme: [Double], listeY3Somme: [Double], listeX: [Int], totalQuantiteDeposee: Double, totalQuantiteVendu: Int, chargesFixes: Double) {
        self.listeYSomme = listeYSomme
        self.listeY2Somme = listeY2Somme
        self.listeY3Somme = listeY3Somme
        self.listeX = listeX
        self.totalQuantiteDeposee = totalQuantiteDeposee
        self.totalQuantiteVendu = totalQuantiteVendu
        self.chargesFixes = chargesFixes
    }
}


struct BilanView_Previews: PreviewProvider {
    static var previews: some View {
        BilanView(onAfficherBilanGraphe: { data in
            print("BilanGraphData: \(data)")
        })
    }
}
