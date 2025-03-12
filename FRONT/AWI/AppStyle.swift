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

// For properly formatting percentages
extension FormatStyle where Self == FloatingPointFormatStyle<Double>.Percent {
    static var percent: Self {
        .percent.scale(100)
    }
}

// Color extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}