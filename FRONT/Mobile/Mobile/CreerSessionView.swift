import SwiftUI
import UserNotifications

struct CreerSessionView: View {
    @State private var nomSession: String = ""
    @State private var adresseSession: String = ""
    @State private var dateDebut = Date()
    @State private var dateFin = Date()
    @State private var fraisDepotFixe: String = ""
    @State private var fraisDepotPercent: String = ""
    @State private var descriptionSession: String = ""
    @State private var showOptionalFields: Bool = false
    @State private var errorMessage: String = ""
    
    // Base URL de votre back
    let baseURL = BaseUrl.lien
    
    let onRetour: () -> Void

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image("sport")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Bouton retour
                    HStack {
                        Button(action: onRetour) {
                            Image("retour")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .padding()
                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    
                    Spacer()
                    
                    // Formulaire dans un ScrollView
                    ScrollView {
                        VStack(spacing: 15) {
                            Text("CRÉER SESSION")
                                .font(.custom("Bangers", size: 30))
                                .padding(.top, 10)
                            
                            // Message d'erreur inline en rouge
                            if !errorMessage.isEmpty {
                                Text(errorMessage)
                                    .foregroundColor(.red)
                                    .padding(.horizontal)
                            }
                            
                            TextField("Nom de la session", text: $nomSession)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal)
                            
                            TextField("Adresse", text: $adresseSession)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal)
                            
                            HStack(spacing: 10) {
                                VStack(alignment: .leading) {
                                    Text("Date Début :")
                                        .font(.subheadline)
                                    DatePicker("", selection: $dateDebut, displayedComponents: .date)
                                        .labelsHidden()
                                }
                                .frame(maxWidth: .infinity)
                                
                                VStack(alignment: .leading) {
                                    Text("Date Fin :")
                                        .font(.subheadline)
                                    DatePicker("", selection: $dateFin, displayedComponents: .date)
                                        .labelsHidden()
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .padding(.horizontal)
                            
                            TextField("Frais dépôt fixe (€)", text: $fraisDepotFixe)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                                .padding(.horizontal)
                            
                            TextField("Frais dépôt variable (%)", text: $fraisDepotPercent)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                                .padding(.horizontal)
                            
                            Button(action: {
                                showOptionalFields.toggle()
                            }) {
                                Text(showOptionalFields ? "▲ Masquer les champs optionnels" : "▼ Afficher les champs optionnels")
                                    .foregroundColor(.blue)
                            }
                            
                            if showOptionalFields {
                                TextEditor(text: $descriptionSession)
                                    .frame(height: 80)
                                    .border(Color.gray, width: 1)
                                    .padding(.horizontal)
                            }
                            
                            Button(action: {
                                errorMessage = ""
                                // Vérification des champs obligatoires
                                if nomSession.trimmingCharacters(in: .whitespaces).isEmpty ||
                                    adresseSession.trimmingCharacters(in: .whitespaces).isEmpty ||
                                    fraisDepotFixe.trimmingCharacters(in: .whitespaces).isEmpty ||
                                    fraisDepotPercent.trimmingCharacters(in: .whitespaces).isEmpty {
                                    errorMessage = "Veuillez remplir tous les champs obligatoires."
                                    scheduleLocalNotification(title: "Erreur", message: errorMessage)
                                    return
                                }
                                creerSession()
                            }) {
                                Text("CRÉER SESSION")
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(radius: 5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.black, lineWidth: 2)
                        )
                        .frame(width: geometry.size.width * 0.9)
                    }
                    
                    Spacer()
                }
            }
        }
        .onTapGesture {
            self.hideKeyboard()
        }
        .onAppear {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
        }
    }
    
    private func creerSession() {
        guard let url = URL(string: "\(baseURL)/creer-session") else {
            errorMessage = "URL invalide"
            scheduleLocalNotification(title: "Erreur", message: errorMessage)
            return
        }
        
        // Créer un DateFormatter compatible MySQL
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Format pour DATETIME
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // En UTC, par exemple
        
        // Convertir les champs numériques (si besoin)
        let fraisFixeValue = Double(fraisDepotFixe) ?? 0
        let fraisPercentValue = Double(fraisDepotPercent) ?? 0
        
        let body: [String: Any] = [
            "Nom_session": nomSession,
            "adresse_session": adresseSession,
            "date_debut": formatter.string(from: dateDebut), // Formaté en "2025-03-26 03:35:00"
            "date_fin": formatter.string(from: dateFin),
            "Frais_depot_fixe": fraisFixeValue,
            "Frais_depot_percent": fraisPercentValue,
            "Description": descriptionSession
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = "Erreur: \(error.localizedDescription)"
                    scheduleLocalNotification(title: "Erreur", message: errorMessage)
                }
                return
            }
            guard let data = data,
                  let responseJSON = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let message = responseJSON["message"] as? String else {
                DispatchQueue.main.async {
                    errorMessage = "Réponse invalide du serveur"
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
        nomSession = ""
        adresseSession = ""
        dateDebut = Date()
        dateFin = Date()
        fraisDepotFixe = ""
        fraisDepotPercent = ""
        descriptionSession = ""
    }
    
    private func scheduleLocalNotification(title: String, message: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString,
                                            content: content,
                                            trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}

struct CreerSessionView_Previews: PreviewProvider {
    static var previews: some View {
        CreerSessionView(onRetour: {})
    }
}
