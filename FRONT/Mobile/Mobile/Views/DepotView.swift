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
    @State private var fraisConfirme: Bool = false
    
    
    @State private var selectedImage: UIImage? = nil
    @State private var photosPickerItem: PhotosPickerItem?
    
    // Liste des sessions chargées depuis le back
    @State private var sessions: [Session] = []
    
    // Message d'erreur inline
    @State private var errorMessage: String = ""
    
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
                    .ignoresSafeArea()
                
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
                            
                            // Picker pour choisir une session
                            Picker("Sélectionnez une session", selection: Binding(
                                get: { selectedSession?.id ?? -1 },
                                set: { newValue in
                                    if newValue == -1 {
                                        selectedSession = nil
                                    } else {
                                        selectedSession = sessions.first { $0.id == newValue }
                                    }
                                }
                            )) {
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
                            if let session = selectedSession,
                               let prix = Double(prixUnit),
                               let quantite = Double(quantiteDeposee),
                               prix >= 0 {
                                
                                let fraisFixe = Double(session.fraisDepotFixe)
                                let fraisPourcent = Double(session.fraisDepotPercent)
                                let fraisTotaux = fraisFixe + (quantite * prix * fraisPourcent / 100)
                                
                                HStack {
                                    Text("Les frais de dépôt de \(String(format: "%.2f", fraisTotaux)) € sont payés")
                                        .font(.subheadline)
                                    Spacer()
                                    Toggle("", isOn: $fraisConfirme)
                                        .labelsHidden()
                                }
                                .padding(.horizontal)
                            }

                            
                            
                            Button {
                                showOptionalFields.toggle()
                            } label: {
                                Text(showOptionalFields
                                     ? "▲ Masquer les champs optionnels"
                                     : "▼ Afficher les champs optionnels")
                                .foregroundColor(.blue)
                            }
                            .padding(.top, 5)
                            // Message d'erreur en rouge
                            if !errorMessage.isEmpty {
                                Text(errorMessage)
                                    .foregroundColor(.red)
                                    .padding(.horizontal)
                            }
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
                                
                          
                            }
                            // Affichage de l'image sélectionnée
                            if let selectedImage {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: 250, maxHeight: 250)
                                    .cornerRadius(10)
                                    .padding(.horizontal)
                            }
                            Button("Ajouter") {
                                errorMessage = ""
                                // Validation des champs obligatoires
                                if fraisConfirme == false ||
                                    nomJeu.trimmingCharacters(in: .whitespaces).isEmpty ||
                                    prixUnit.trimmingCharacters(in: .whitespaces).isEmpty ||
                                    quantiteDeposee.trimmingCharacters(in: .whitespaces).isEmpty ||
                                    selectedSession == nil {
                                    errorMessage = "Veuillez remplir tous les champs obligatoires."
                                    return
                                }
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
        .onTapGesture {
            self.hideKeyboard()
        }
        .onAppear {
            loadSessions()
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
        }
        .onChange(of: photosPickerItem) { newItem in
            if let newItem {
                Task {
                    if let data = try? await newItem.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        selectedImage = uiImage
                    }
                }
            }
        }
        
    }
    
    
    private func loadSessions() {
        guard let url = URL(string: "\(baseURL)/get_all_sessions") else {
            print("URL sessions invalide")
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, error in
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
                }
            } catch {
                print("Erreur de décodage des sessions: \(error)")
            }
        }.resume()
    }
    
    private func addDepot() {
        guard let url = URL(string: "\(baseURL)/depot") else {
            errorMessage = "URL invalide pour depot"
            scheduleLocalNotification(title: "Erreur", message: errorMessage)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
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
        
        if let image = selectedImage,
           let imageData = image.jpegData(compressionQuality: 0.8) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"image\"; filename=\"depot.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        URLSession.shared.uploadTask(with: request, from: body) { data, _, error in
            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = "Erreur lors de l'ajout: \(error.localizedDescription)"
                    scheduleLocalNotification(title: "Erreur", message: errorMessage)
                }
                return
            }
            guard let data = data,
                  let responseJSON = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let message = responseJSON["message"] as? String else {
                DispatchQueue.main.async {
                    errorMessage = "Réponse invalide du serveur."
                    scheduleLocalNotification(title: "Erreur", message: errorMessage)
                }
                return
            }
            DispatchQueue.main.async {
                scheduleLocalNotification(title: "Succès", message: message)
                resetForm()
            }
        }.resume()
    }
    
    private func resetForm() {
        emailVendeur = ""
        nomJeu = ""
        prixUnit = ""
        quantiteDeposee = ""
        editeur = ""
        description = ""
        selectedImage = nil
        photosPickerItem = nil
        estEnVente = false
        selectedSession = nil
    }
    private func cleanText(_ text: String) -> String {
        let cleaned = text.folding(options: .diacriticInsensitive, locale: .current) // enlève accents
            .replacingOccurrences(of: "’", with: "'") // apostrophes courbes
            .replacingOccurrences(of: "“", with: "\"")
            .replacingOccurrences(of: "”", with: "\"")
            .replacingOccurrences(of: "\u{00A0}", with: " ") // espace insécable
            .replacingOccurrences(of: "\u{200B}", with: "") // zero-width space
        return cleaned
    }
    private func scheduleLocalNotification(title: String, message: String) {
        let content = UNMutableNotificationContent()
        content.title = cleanText(title)
        content.body = cleanText(message)
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
}

struct DepotView_Previews: PreviewProvider {
    static var previews: some View {
        DepotView()
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
