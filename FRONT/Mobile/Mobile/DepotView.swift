import SwiftUI
import PhotosUI
import UserNotifications

struct DepotView: View {
    @State private var emailVendeur: String = ""
    @State private var nomJeu: String = ""
    @State private var prixUnit: String = ""
    @State private var quantiteDeposee: String = ""
    @State private var editeur: String = ""
    @State private var description: String = ""
    
    @State private var estEnVente: Bool = false
    @State private var selectedSession: Session? = nil
    @State private var showOptionalFields: Bool = false
    
    @State private var selectedImage: UIImage? = nil
    @State private var photosPickerItem: PhotosPickerItem?
    
    // Liste des sessions chargées depuis le back
    @State private var sessions: [Session] = []
    
    // Pour afficher des alertes suite aux actions back
    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false

    // Binding pour le Picker de session.
    // Utilise -1 comme valeur par défaut lorsque aucune session n'est sélectionnée.
    private var sessionPickerBinding: Binding<Int> {
        Binding<Int>(
            get: { selectedSession?.id ?? -1 },
            set: { newValue in
                if newValue == -1 {
                    selectedSession = nil
                } else {
                    selectedSession = sessions.first { $0.id == newValue }
                }
            }
        )
    }
    
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
                        
                        VStack(spacing: 10) {
                            Text("DEPOT")
                                .font(.system(size: 24, weight: .bold))
                                .padding(.top, 10)
                            
                            Toggle("Mise en vente immédiate", isOn: $estEnVente)
                                .tint(.blue)
                                .padding(.horizontal)
                            
                            // Picker pour choisir la session
                            Picker("Sélectionnez une session", selection: sessionPickerBinding) {
                                Text("Sélectionnez une session").tag(-1)
                                ForEach(sessions, id: \.id) { session in
                                    Text(session.nom).tag(session.id)
                                }
                            }
                            .pickerStyle(.menu)
                            .padding(.horizontal)
                            
                            // Affichage des infos de la session sélectionnée
                            if let session = selectedSession {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Frais dépôt fixe : \(session.fraisDepotFixe)€")
                                    Text("Frais dépôt (%) : \(session.fraisDepotPercent)%")
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.black, lineWidth: 1)
                                )
                                .padding(.horizontal)
                            }
                            
                            TextField("Email du vendeur", text: $emailVendeur)
                                .textFieldStyle(.roundedBorder)
                                .padding(.horizontal)
                            
                            TextField("Nom du Jeu", text: $nomJeu)
                                .textFieldStyle(.roundedBorder)
                                .padding(.horizontal)
                            
                            TextField("Prix Unitaire (on lui devra)", text: $prixUnit)
                                .textFieldStyle(.roundedBorder)
                                .padding(.horizontal)
                                .keyboardType(.decimalPad)
                            
                            TextField("Quantité", text: $quantiteDeposee)
                                .textFieldStyle(.roundedBorder)
                                .padding(.horizontal)
                                .keyboardType(.numberPad)
                            
                            Button {
                                showOptionalFields.toggle()
                            } label: {
                                Text(showOptionalFields
                                     ? "▲ Masquer les champs optionnels"
                                     : "▼ Afficher les champs optionnels")
                                    .foregroundColor(.blue)
                            }
                            .padding(.top, 5)
                            
                            if showOptionalFields {
                                TextField("Éditeur", text: $editeur)
                                    .textFieldStyle(.roundedBorder)
                                    .padding(.horizontal)
                                
                                TextEditor(text: $description)
                                    .frame(height: 100)
                                    .border(Color.gray, width: 1)
                                    .padding(.horizontal)
                                
                                // Sélection d'image
                                PhotosPicker(selection: $photosPickerItem, matching: .images, photoLibrary: .shared()) {
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
                                
                                // Affichage de l'image choisie
                                if let selectedImage {
                                    Image(uiImage: selectedImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxWidth: 250, maxHeight: 250)
                                        .cornerRadius(10)
                                        .padding(.horizontal)
                                }
                            }
                            
                            Button("Ajouter") {
                                addDepot()
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }
                        .padding()
                        .frame(maxWidth: 300)
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
        .onChange(of: photosPickerItem) { newItem in
            Task {
                if let loadedImageData = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: loadedImageData) {
                    print("Image chargée avec succès, taille : \(uiImage.size)")
                    selectedImage = uiImage
                } else {
                    print("Échec du chargement de l'image.")
                }
            }
        }
        .onAppear {
            loadSessions()
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Information"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    // Charge les sessions depuis le back
    private func loadSessions() {
        guard let url = URL(string: "http://localhost:3000/get_all_sessions") else {
            print("URL sessions invalide")
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Erreur lors du chargement des sessions: \(error)")
                return
            }
            guard let data = data else {
                print("Aucune donnée reçue pour les sessions")
                return
            }
            do {
                let sessionsArray = try JSONDecoder().decode([Session].self, from: data)
                DispatchQueue.main.async {
                    sessions = sessionsArray
                    // Ne pas affecter automatiquement la première session.
                }
            } catch {
                print("Erreur de décodage des sessions: \(error)")
            }
        }.resume()
    }
    
    // Fonction pour envoyer les données vers /depot
    private func addDepot() {
        guard let url = URL(string: "http://localhost:3000/depot") else {
            alertMessage = "URL invalide pour depot"
            showAlert = true
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Création d'une boundary pour le multipart/form-data
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Construction du corps de la requête
        var body = Data()
        
        func appendFormField(name: String, value: String) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        appendFormField(name: "email_vendeur", value: emailVendeur)
        appendFormField(name: "nom_jeu", value: nomJeu)
        appendFormField(name: "prix_unit", value: prixUnit)
        appendFormField(name: "quantite_deposee", value: quantiteDeposee)
        appendFormField(name: "est_en_vente", value: "\(estEnVente)")
        appendFormField(name: "editeur", value: editeur)
        appendFormField(name: "description", value: description)
        if let session = selectedSession {
            appendFormField(name: "num_session", value: "\(session.id)")
        }
        
        // Ajout de l'image si disponible
        if let image = selectedImage,
           let imageData = image.jpegData(compressionQuality: 0.8) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"image\"; filename=\"depot.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        // Fermeture du body
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        // N'assigner pas manuellement request.httpBody, laissez uploadTask utiliser le body fourni
        URLSession.shared.uploadTask(with: request, from: body) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    alertMessage = "Erreur lors de l'ajout: \(error.localizedDescription)"
                    showAlert = true
                }
                return
            }
            guard let data = data,
                  let responseJSON = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let message = responseJSON["message"] as? String else {
                DispatchQueue.main.async {
                    alertMessage = "Réponse invalide du serveur."
                    showAlert = true
                }
                return
            }
            DispatchQueue.main.async {
                alertMessage = message
                showAlert = true
                // Réinitialisation du formulaire (optionnel)
                emailVendeur = ""
                nomJeu = ""
                prixUnit = ""
                quantiteDeposee = ""
                editeur = ""
                description = ""
                selectedImage = nil
                photosPickerItem = nil
            }
        }.resume()
    }

}

struct Session: Codable, Identifiable {
    var id: Int
    var nom: String
    var fraisDepotFixe: Int
    var fraisDepotPercent: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "id_session"
        case nom = "Nom_session"
        case fraisDepotFixe = "Frais_depot_fixe"
        case fraisDepotPercent = "Frais_depot_percent"
    }
}
