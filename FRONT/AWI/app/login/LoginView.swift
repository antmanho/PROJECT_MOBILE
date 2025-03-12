import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @Environment(\.colorScheme) var colorScheme
    @State private var isShowingSignUp = false
    @State private var isShowingForgotPassword = false
    @State private var currentImageIndex = 0
    
    // Carousel images
    private let images = ["image1", "image2"]
    private let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            // Background color
            (colorScheme == .dark ? Color.black : Color.white)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 0) {
                    // Header space
                    Spacer()
                        .frame(height: 30)
                    
                    // Main content container
                    HStack(alignment: .center, spacing: 0) {
                        // Carousel on larger devices (iPad)
                        if UIDevice.current.userInterfaceIdiom == .pad {
                            carouselView
                                .frame(width: UIScreen.main.bounds.width * 0.45)
                        }
                        
                        // Login form
                        loginFormView
                            .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? 
                                   UIScreen.main.bounds.width * 0.45 : .infinity)
                    }
                    
                    // Footer
                    footerView
                }
                .padding(.horizontal)
            }
            
            // Loading overlay
            if viewModel.isLoading {
                loadingView
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            // Initialize any required data
        }
    }
    
    // MARK: - Subviews
    
    private var carouselView: some View {
        TabView(selection: $currentImageIndex) {
            ForEach(0..<images.count, id: \.self) { index in
                Image(images[index])
                    .resizable()
                    .scaledToFill()
                    .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .frame(height: 500)
        .cornerRadius(12)
        .shadow(radius: 5)
        .padding()
        .onReceive(timer) { _ in
            withAnimation {
                currentImageIndex = (currentImageIndex + 1) % images.count
            }
        }
    }
    
    private var loginFormView: some View {
        VStack(spacing: 20) {
            Text("CONNEXION")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 20)
            
            // Email field
            TextField("Email", text: $viewModel.email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            
            // Password field
            SecureField("Mot de passe", text: $viewModel.password)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            
            // Login button
            Button(action: {
                viewModel.login()
            }) {
                Text("Se connecter")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding(.top, 10)
            
            // Error message
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.subheadline)
                    .padding(.top, 5)
            }
            
            // Divider
            HStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.5))
                    .frame(height: 1)
                
                Text("OU")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Rectangle()
                    .fill(Color.gray.opacity(0.5))
                    .frame(height: 1)
            }
            .padding(.vertical)
            
            // Forgot password button
            Button(action: {
                isShowingForgotPassword = true
            }) {
                Text("Mot de passe oublié ?")
                    .foregroundColor(.blue)
                    .font(.subheadline)
            }
            .padding(.bottom, 20)
            
            // Sign up container
            VStack(spacing: 10) {
                Text("Vous n'avez pas de compte ?")
                    .font(.subheadline)
                
                Button(action: {
                    isShowingSignUp = true
                }) {
                    Text("Inscrivez-vous")
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray, lineWidth: 1)
            )
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 5)
        .padding()
        .navigationDestination(isPresented: $isShowingSignUp) {
            SignUpView() // This would be your sign up view
        }
        .navigationDestination(isPresented: $isShowingForgotPassword) {
            ForgotPasswordView() // This would be your forgot password view
        }
    }
    
    private var loadingView: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            
            ProgressView("Connexion en cours...")
                .padding()
                .background(Color(UIColor.systemBackground))
                .cornerRadius(10)
                .shadow(radius: 10)
        }
    }
    
    private var footerView: some View {
        Text("Barbedet Anthony & Delclaud Corentin production | Polytech school | © 2024 Boardland")
            .font(.caption)
            .foregroundColor(.gray)
            .multilineTextAlignment(.center)
            .padding(.vertical, 20)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}