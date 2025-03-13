import Foundation
import Combine

class ProductDetailViewModel: ObservableObject {
    @Published var product: Product?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let productService = ProductService()
    private var cancellables = Set<AnyCancellable>()
    
    func fetchProductDetails(id: Int) {
        isLoading = true
        errorMessage = nil
        
        productService.fetchProductDetails(id: id)
            .sink { [weak self] completion in
                self?.isLoading = false
                
                if case .failure(let error) = completion {
                    self?.errorMessage = "Erreur lors du chargement des détails du produit: \(error.localizedDescription)"
                    print("Error fetching product details: \(error)")
                }
            } receiveValue: { [weak self] product in
                self?.product = product
            }
            .store(in: &cancellables)
    }
    
    // Helper to determine availability status text and color
    func availabilityStatus() -> (String, Color) {
        guard let product = product else {
            return ("Indisponible", .gray)
        }
        
        if !product.est_en_vente {
            return ("Pas en vente", .red)
        }
        
        if product.quantiteRestante > 0 {
            return ("En stock (\(product.quantiteRestante))", .green)
        } else {
            return ("Épuisé", .red)
        }
    }
}