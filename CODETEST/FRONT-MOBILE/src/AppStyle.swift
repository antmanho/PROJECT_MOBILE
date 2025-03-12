import SwiftUI

// Équivalent à styles.css pour définir des styles réutilisables
struct AppStyles {
    // Couleurs
    static let primaryColor = Color(red: 0.0, green: 0.48, blue: 1.0)
    static let backgroundColor = Color(red: 0.95, green: 0.95, blue: 0.95)
    static let textColor = Color.black
    
    // Styles de texte
    static let titleStyle = Text.LineStyle(font: .largeTitle)
    static let subtitleStyle = Text.LineStyle(font: .title2)
    
    // ViewModifiers réutilisables
    struct CardStyle: ViewModifier {
        func body(content: Content) -> some View {
            content
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 3)
        }
    }
    
    struct ButtonStyle: ViewModifier {
        func body(content: Content) -> some View {
            content
                .padding()
                .background(primaryColor)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
    }
}

// Extensions pour faciliter l'utilisation des styles
extension View {
    func cardStyle() -> some View {
        self.modifier(AppStyles.CardStyle())
    }
    
    func appButtonStyle() -> some View {
        self.modifier(AppStyles.ButtonStyle())
    }
}