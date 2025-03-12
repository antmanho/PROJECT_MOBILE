import SwiftUI

@main
struct BoardlandApp: App {
    // Register custom fonts
    init() {
        registerFonts()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
    
    private func registerFonts() {
        // Register the Bangers font if needed
        if let fontURL = Bundle.main.url(forResource: "Bangers-Regular", withExtension: "ttf") {
            CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, nil)
        }
    }
}