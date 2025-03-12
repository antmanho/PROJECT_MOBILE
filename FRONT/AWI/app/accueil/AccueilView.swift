import SwiftUI

struct AcceuilView: View {
    @State private var currentIndex2 = 0
    @State private var currentIndex3 = 0
    private let timer = Timer.publish(every: 6, on: .main, in: .common).autoconnect()

    let images2 = ["acc4", "acc2"]
    let images3 = ["acc3", "acc1"]

    var body: some View {
        VStack {
            Text("Bienvenue sur le site du Festival de Jeux !")
                .font(.largeTitle)
                .padding()

            HStack {
                VStack {
                    FAQView(title: "Quel est le but de ce site ?", description: "Ce site a pour but de faciliter l'organisation du Festival de Jeux de Société. Il permet aux gestionnaires de suivre les ventes et de générer des bilans, aux administrateurs de gérer les sessions de vente et les utilisateurs, et aux vendeurs de consulter en temps réel le nombre de jeux vendus. Tout le monde peut accéder au catalogue des jeux disponibles.")
                }
                .frame(width: UIScreen.main.bounds.width * 0.45, height: UIScreen.main.bounds.height * 0.45)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding()

                ImageSliderView(images: images2, currentIndex: $currentIndex2)
                    .frame(width: UIScreen.main.bounds.width * 0.45, height: UIScreen.main.bounds.height * 0.45)
                    .background(Color.gray)
                    .cornerRadius(10)
                    .padding()
            }

            HStack {
                ImageSliderView(images: images3, currentIndex: $currentIndex3)
                    .frame(width: UIScreen.main.bounds.width * 0.45, height: UIScreen.main.bounds.height * 0.45)
                    .background(Color.gray)
                    .cornerRadius(10)
                    .padding()

                VStack {
                    FAQView(title: "Gérer les Ventes", description: "Les gestionnaires peuvent facilement suivre et gérer les ventes de jeux en temps réel, générer des bilans de vente et optimiser les stocks pour assurer le bon déroulement du festival.")
                    FAQView(title: "Accéder au Catalogue", description: "Tout le monde peut explorer le catalogue des jeux disponibles, y compris les visiteurs et les participants au festival. Découvrez les jeux en vedette et préparez votre visite en parcourant les titres que vous souhaitez essayer ou acheter.")
                }
                .frame(width: UIScreen.main.bounds.width * 0.45, height: UIScreen.main.bounds.height * 0.45)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding()
            }
        }
        .onReceive(timer) { _ in
            currentIndex2 = (currentIndex2 + 1) % images2.count
            currentIndex3 = (currentIndex3 + 1) % images3.count
        }
    }
}

struct FAQView: View {
    let title: String
    let description: String

    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.top)
            Text(description)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()
        }
    }
}

struct ImageSliderView: View {
    let images: [String]
    @Binding var currentIndex: Int

    var body: some View {
        ZStack {
            ForEach(0..<images.count, id: \.self) { index in
                Image(images[index])
                    .resizable()
                    .scaledToFill()
                    .opacity(currentIndex == index ? 1 : 0)
                    .animation(.easeInOut(duration: 1), value: currentIndex)
            }
        }
    }
}

struct AccueilView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // For iPad Pro
            AccueilView()  // Make sure this matches the actual view name
                .previewDevice(PreviewDevice(rawValue: "iPad Pro (12.9-inch) (6th generation)"))
                .previewDisplayName("iPad Pro")
            
            // For iPhone
            AccueilView()  // Make sure this matches the actual view name
                .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro"))
                .previewDisplayName("iPhone")
                .previewLayout(.fixed(width: 375, height: 812))
        }
    }
}