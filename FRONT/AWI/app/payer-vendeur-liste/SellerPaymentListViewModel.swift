// SellerPaymentListViewModel.swift

import Foundation
import Combine

class SellerPaymentListViewModel: ObservableObject {
    @Published var salesHistory: [SaleItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var showNotification = false
    @Published var notificationMessage = ""
    
    private var cancellables = Set<AnyCancellable>()
    private let service = ManagerService()
    
    var sellerEmail: String = ""
    
    var totalAmountDue: Double {
        if let lastItem = salesHistory.last, let totalDue = lastItem.Somme_total_du {
            return totalDue
        } else {
            // Calculate manually as a fallback
            return salesHistory.reduce(0) { $0 + ($1.Prix_unit * Double($1.Quantite_vendu)) }
        }
    }
    
    func fetchSalesHistory(for email: String) {
        sellerEmail = email
        isLoading = true
        errorMessage = nil
        
        service.fetchSellerSales(email: email)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    
                    if case .failure(let error) = completion {
                        self?.errorMessage = "Erreur lors du chargement: \(error.localizedDescription)"
                    }
                },
                receiveValue: { [weak self] sales in
                    self?.salesHistory = sales
                }
            )
            .store(in: &cancellables)
    }
    
    func paySeller() {
        isLoading = true
        
        service.paySeller(email: sellerEmail)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    
                    if case .failure(let error) = completion {
                        self?.errorMessage = "Erreur lors du paiement: \(error.localizedDescription)"
                    }
                },
                receiveValue: { [weak self] response in
                    self?.showNotification = true
                    self?.notificationMessage = "Vous avez validé le paiement du vendeur."
                    
                    // Reload data after 5 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        self?.fetchSalesHistory(for: self?.sellerEmail ?? "")
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    func closeNotification() {
        showNotification = false
    }
}