class EmailVerificationModel: ObservableObject {
    @Published var verificationCode = ""
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var isResending = false
    @Published var showSuccessAlert = false
    
    private var cancellables = Set<AnyCancellable>()
    private let authService = AuthService()
    
    // Helper methods for digit-by-digit code entry
    func getCodeDigit(at index: Int) -> String {
        guard index < verificationCode.count else { return "" }
        let stringIndex = verificationCode.index(verificationCode.startIndex, offsetBy: index)
        return String(verificationCode[stringIndex])
    }
    
    func setCodeDigit(at index: Int, to value: String) {
        let sanitized = value.filter { "0123456789".contains($0) }
        if sanitized.isEmpty {
            // Delete digit
            if index < verificationCode.count {
                verificationCode.remove(at: verificationCode.index(verificationCode.startIndex, offsetBy: index))
            }
        } else {
            // Add/replace digit
            let digit = String(sanitized.prefix(1))
            if index < verificationCode.count {
                // Replace
                let stringIndex = verificationCode.index(verificationCode.startIndex, offsetBy: index)
                verificationCode.replaceSubrange(stringIndex...stringIndex, with: digit)
            } else if verificationCode.count < 6 {
                // Append
                verificationCode.append(digit)
            }
        }
    }
    
    func verifyCode(email: String) {
        errorMessage = nil
        guard verificationCode.count == 6 else {
            errorMessage = "Veuillez entrer le code à 6 chiffres."
            return
        }
        
        isLoading = true
        
        authService.verifyEmail(email: email, code: verificationCode)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                
                if case .failure(let error) = completion {
                    self?.errorMessage = "Erreur de vérification: \(error.localizedDescription)"
                }
            } receiveValue: { [weak self] response in
                if response.success {
                    self?.showSuccessAlert = true
                } else {
                    self?.errorMessage = response.message ?? "Code de vérification incorrect."
                }
            }
            .store(in: &cancellables)
    }
    
    func resendCode(email: String) {
        isResending = true
        
        authService.resendVerificationCode(email: email)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isResending = false
                
                if case .failure(let error) = completion {
                    self?.errorMessage = "Erreur d'envoi: \(error.localizedDescription)"
                }
            } receiveValue: { [weak self] response in
                if !response.success {
                    self?.errorMessage = response.message
                }
            }
            .store(in: &cancellables)
    }
}