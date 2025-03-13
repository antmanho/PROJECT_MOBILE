import Foundation
import Combine

class RegisterPurchaseViewModel: ObservableObject {
    // Form fields
    @Published var stockId: Int = 0
    @Published var soldQuantity: Int = 0
    
    // UI state
    @Published var isLoading = false
    @Published var showNotification = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let service = ManagerService()
    
    func submitPurchase() {
        // Validate form
        if stockId <= 0 {
            errorMessage = "L'ID du stock doit être un nombre positif."
            return
        }
        
        if soldQuantity <= 0 {
            errorMessage = "La quantité vendue doit être un nombre positif."
            return
        }
        
        errorMessage = nil
        isLoading = true
        
        let purchase = Purchase(
            id_stock: stockId,
            quantite_vendu: soldQuantity
        )
        
        service.registerPurchase(purchase)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    
                    if case .failure(let error) = completion {
                        self?.errorMessage = "Erreur lors de l'enregistrement de l'achat: \(error.localizedDescription)"
                    }
                },
                receiveValue: { [weak self] response in
                    self?.showNotification = true
                    
                    // Auto-hide notification after 5 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        self?.showNotification = false
                    }
                    
                    // Reset form
                    self?.resetForm()
                }
            )
            .store(in: &cancellables)
    }
    
    func resetForm() {
        stockId = 0
        soldQuantity = 0
    }
    
    func closeNotification() {
        showNotification = false
    }
}