import SwiftUI
import UserNotifications

struct PreinscriptionView: View {
    // Binding pour permettre de changer la vue depuis PreinscriptionView
    @Binding var selectedView: String
    
    // Variables d'état pour le formulaire
    @State private var email: String = ""
    @State private var role: String = ""
    
    // Liste des rôles disponibles
    let roles = ["Vendeur", "Admin", "Acheteur", "Gestionnaire"]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Image de fond occupant tout l'écran
                Image("sport")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width,
                           height: geometry.size.height)
                    .clipped()
                    .ignoresSafeArea()
                
                // Contenu scrollable
                ScrollView {
                    VStack {
                        Spacer(minLength: 40) // Espace en haut
                        
                        // Formulaire centré avec style "carte"
                        VStack(spacing: 10) {
                            Text("PREINSCRIRE")
                                .font(.system(size: 24, weight: .bold))
                                .padding(.top, 10)
                            
                            // Champ Email
                            VStack(alignment: .leading, spacing: 5) {
                                TextField("Email", text: $email)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.emailAddress)
                            }
                            .padding(.horizontal)
                            
                            // Sélection du rôle via Picker
                            VStack(alignment: .leading, spacing: 5) {
                                Picker("Choisissez un rôle", selection: $role) {
                                    Text("Choisissez un rôle").tag("")
                                    ForEach(roles, id: \.self) { r in
                                        Text(r).tag(r)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                
                            }
                            .padding(.horizontal)
                            
                            // Bouton de soumission
                            Button(action: {
                                // Programme la notification locale
                                scheduleLocalNotification()
                                // Vous pouvez ajouter ici d'autres actions, par exemple changer de vue :
                                // selectedView = "AutreVue"
                            }) {
                                Text("PREINSCRIRE")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal)
                        }
                        .padding()
                        .frame(maxWidth: 300) // Largeur similaire à celle du RetraitView
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(radius: 5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.black, lineWidth: 3)
                        )
                        
                        Spacer(minLength: 60) // Espace en bas
                    }
                }
            }
        }
        .onAppear {
            // Demande l'autorisation pour les notifications locales
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                // Vous pouvez gérer l'erreur ou le refus ici si besoin
            }
        }
    }
    
    // Fonction qui programme une notification locale
    private func scheduleLocalNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Préinscription effectuée"
        content.body = "Votre préinscription a été enregistrée avec succès."
        content.sound = UNNotificationSound.default
        
        // Notification déclenchée après 1 seconde
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString,
                                            content: content,
                                            trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}

struct PreinscriptionView_Previews: PreviewProvider {
    static var previews: some View {
        PreinscriptionView(selectedView: .constant("Pré-Inscription"))
    }
}
