import SwiftUI

struct ManufacturerDetailView: View {
    @ObservedObject var viewModel: ManufacturerViewModel
    let idFabricante: String
    
    var body: some View {
        VStack {
            if let fabricante = viewModel.fabricantes.first(where: { $0.id == idFabricante }) {
                Text("Detalles del Fabricante \(fabricante.nombre)")
                
                if let cervezas = fabricante.cervezas {
                    if cervezas.isEmpty {
                        Text("Cargando cervezas...")
                    } else {
                        List(cervezas, id: \.id) { cerveza in
                            NavigationLink(destination: BeerDetailView(cerveza: cerveza)) {
                                HStack {
                                    if let image = cerveza.logoImage {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 100, height: 100)
                                    } else {
                                        Rectangle()
                                            .fill(Color.gray)
                                            .frame(width: 100, height: 100)
                                    }

                                    Text(cerveza.nombre)
                                }
                            }
                        }
                    }
                } else {
                    Text("No hay cervezas disponibles o están cargando.")
                }
            } else {
                Text("Fabricante no encontrado")
            }

            NavigationLink("Añadir Cerveza", destination: AddBeerView(viewModel: viewModel, idFabricante: idFabricante))
                               .padding()
        }
        .onAppear {
            viewModel.getCervezas(idFabricante: idFabricante)
        }
    }
}
