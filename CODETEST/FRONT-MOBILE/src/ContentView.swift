import SwiftUI

struct ContentView: View {
    // Correct declaration without parentheses
    @EnvironmentObject var appState: AppState
    @StateObject private var networkManager = NetworkManager()
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Festival de Jeux")
                    .font(.largeTitle)
                    .padding()
                
                // Ici les vues principales de l'app
                // Par exemple:
                NavigationLink(destination: CatalogueView()) {
                    Text("Accéder au Catalogue")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
            .navigationBarTitle("Accueil", displayMode: .inline)
            .overlay(
                Group {
                    if appState.isLoading {
                        ProgressView("Chargement...")
                            .background(Color.white.opacity(0.8))
                    }
                }
            )
        }
        .environmentObject(networkManager)
    }
}

// Vue d'aperçu pour le développement
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppState())
    }
}