import SwiftUI
import SafariServices

struct ContactView: View {
    @Environment(\.openURL) private var openURL
    @State private var showingSafariView = false
    @State private var currentURL: URL?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                VStack {
                    Text("Contactez-nous")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.vertical)
                }
                .frame(maxWidth: .infinity)
                .background(Color.white)
                
                // Main content container
                VStack(alignment: .leading, spacing: 20) {
                    // Contact info section
                    contactInfoSection
                    
                    // FAQ section
                    faqSection
                }
                .padding()
            }
            .background(Color(hex: "#fdfdfd"))
        }
        .navigationTitle("Contact")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingSafariView) {
            if let url = currentURL {
                SafariView(url: url)
            }
        }
    }
    
    // Contact information section
    private var contactInfoSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Informations de Contact")
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom, 5)
                .overlay(
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(.black),
                    alignment: .bottom
                )
            
            Text("Nous sommes là pour vous aider à faire de votre expérience au festival un succès. N'hésitez pas à nous contacter via les moyens suivants :")
                .font(.body)
                .padding(.bottom, 5)
            
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    Image(systemName: "phone")
                    Text("Téléphone : +33 1 23 45 67 89")
                }
                
                HStack(spacing: 10) {
                    Image(systemName: "envelope")
                    Text("Email : contact@festivaljeux.fr")
                }
                
                HStack(spacing: 10) {
                    Image(systemName: "mappin.and.ellipse")
                    Text("Adresse : 123 Rue des Jeux, 75001 Paris, France")
                }
            }
            .padding(.bottom, 15)
            
            Text("Suivez-nous sur les réseaux sociaux")
                .font(.headline)
                .padding(.top, 5)
            
            HStack(spacing: 15) {
                Button(action: {
                    openSocialMedia("https://www.facebook.com/festivaljeux")
                }) {
                    Label("Facebook", systemImage: "link")
                        .foregroundColor(.blue)
                }
                
                Button(action: {
                    openSocialMedia("https://www.instagram.com/festivaljeux")
                }) {
                    Label("Instagram", systemImage: "link")
                        .foregroundColor(.blue)
                }
                
                Button(action: {
                    openSocialMedia("https://www.twitter.com/festivaljeux")
                }) {
                    Label("Twitter", systemImage: "link")
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    // FAQ section
    private var faqSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("FAQ - Questions Fréquentes")
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom, 5)
                .overlay(
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(.black),
                    alignment: .bottom
                )
            
            FAQItemView(
                question: "Comment puis-je contacter vos équipes pour des questions spécifiques ?",
                answer: "Pour des questions spécifiques, vous pouvez nous envoyer un email à contact@festivaljeux.fr. Nous faisons de notre mieux pour répondre à toutes les demandes dans un délai de 24 à 48 heures. Vous pouvez également nous contacter via nos réseaux sociaux pour des réponses rapides."
            )
            
            FAQItemView(
                question: "Comment ce site peut-il aider pendant le festival ?",
                answer: "Notre site offre plusieurs fonctionnalités pour faciliter la gestion du festival :\n\n1. **Ventes en Temps Réel** : Les vendeurs peuvent consulter combien de jeux ont été vendus en temps réel.\n\n2. **Rapports pour Gestionnaires** : Les gestionnaires peuvent suivre les ventes et générer des rapports.\n\n3. **Gestion par les Administrateurs** : Les administrateurs ont la possibilité de gérer les sessions de vente et de superviser les opérations sur l'ensemble du festival.\n\nNous proposons également un support technique continu pour vous assurer une expérience fluide et réussie."
            )
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    // Function to open social media links
    private func openSocialMedia(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        #if os(iOS)
        // Use sheet on iOS for better control
        currentURL = url
        showingSafariView = true
        #else
        // Use standard link opening on other platforms
        openURL(url)
        #endif
    }
}

// Safari view controller wrapper for in-app browser
struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let safariViewController = SFSafariViewController(url: url)
        return safariViewController
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

// FAQ item view component
struct FAQItemView: View {
    let question: String
    let answer: String
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(question)
                        .font(.headline)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.gray)
                }
            }
            
            if isExpanded {
                Text(answer)
                    .font(.body)
                    .foregroundColor(.black)
                    .padding(.top, 5)
                    .transition(.opacity)
            }
        }
        .padding(.vertical, 8)
    }
}

