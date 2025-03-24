import SwiftUI
import UserNotifications 
@main
struct MyApp: App {
    
    // On utilise un AppDelegate “UIKit” pour gérer les notifications
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            // première vue
            Menu()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil)
    -> Bool {
        
        // 1) Demander l’autorisation à l’utilisateur
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Erreur de permission: \(error.localizedDescription)")
            } else if granted {
                print("Permission accordée ")
            } else {
                print("Permission refusée ")
            }
        }
        
        // 2) Définir le delegate pour gérer l’affichage en foreground
        center.delegate = self
        
        return true
    }
    
    /// Méthode appelée quand l’app est **au premier plan** et reçoit une notif
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler:
                                    @escaping (UNNotificationPresentationOptions) -> Void) {
        // Forcer l’affichage sous forme de bannière + son même en foreground
        completionHandler([.banner, .sound])
    }
}
