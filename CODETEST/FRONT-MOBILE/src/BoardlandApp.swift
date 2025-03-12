import SwiftUI

@main
struct BoardlandApp: App {
    // Create an AppState instance
    @StateObject private var appState = AppState()
    
    // Register custom fonts
    init() {
        registerFonts()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)  // Provide AppState to the view hierarchy
        }
    }
    
    private func registerFonts() {
        // Register the Bangers font if needed
        if let fontURL = Bundle.main.url(forResource: "Bangers-Regular", withExtension: "ttf") {
            CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, nil)
        }
    }
}