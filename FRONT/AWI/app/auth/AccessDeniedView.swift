import SwiftUI

struct AccessDeniedView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.shield")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(.red)
            
            Text("Accès refusé")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Vous ne disposez pas des droits nécessaires pour accéder à cette page.")
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding()
            
            NavigationLink(destination: HomepageView()) {
                Text("Retour à l'accueil")
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

// Simple homepage view placeholder
struct HomepageView: View {
    var body: some View {
        Text("Page d'accueil")
            .font(.largeTitle)
    }
}

struct AccessDeniedView_Previews: PreviewProvider {
    static var previews: some View {
        AccessDeniedView()
    }
}