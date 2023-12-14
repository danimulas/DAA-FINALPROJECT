import SwiftUI

struct BeerDetailView: View {
    var cerveza: Cerveza

    var body: some View {
        ScrollView {
            VStack {
                if let image = cerveza.logoImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                } else {
                    Rectangle()
                        .fill(Color.gray)
                        .frame(width: 100, height: 100)  
                }

                Text("Nombre: \(cerveza.nombre)")
                    .font(.title)
                if let tipo = cerveza.tipo {
                    Text("Tipo: \(tipo)")
                }
                if let descripcion = cerveza.descripcion {
                    Text("Descripción: \(descripcion)")
                }
                if let grados = cerveza.grados {
                    Text("Grados: \(grados)")
                }
            }
            .padding()
        }
        .navigationTitle("Detalles de la Cerveza")
    }
}
