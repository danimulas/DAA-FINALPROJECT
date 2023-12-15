import SwiftUI

struct ManufacturerDetailView: View {
    @ObservedObject var viewModel: ManufacturerViewModel
    let idFabricante: String
    var body: some View {
        VStack {
            if let fabricante = viewModel.fabricantes.first(where: { $0.id == idFabricante }) {
                            
                
                if let cervezas = fabricante.cervezas {
                    if cervezas.isEmpty {
                        ProgressView().progressViewStyle(CircularProgressViewStyle())
                    } else {
                        List {
                            HStack(alignment: .center) {
                                Text(fabricante.nombre)
                                    .font(.title)
                                if let logoImage = fabricante.logoImage {
                                    Image(uiImage: logoImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 150, height: 150)
                                } else {
                                    Rectangle()
                                        .fill(Color.gray)
                                        .frame(width: 150, height: 150)
                                }
                                
                            }
                            .padding()
                            ForEach(cervezas, id: \.id) { cerveza in
                                NavigationLink(destination: BeerDetailView(cerveza: cerveza,viewModel: viewModel)) {
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
                            .onDelete(perform: deleteCerveza)
                        }
                        NavigationLink("Añadir Cerveza", destination: AddBeerView(viewModel: viewModel, idFabricante: idFabricante))
                            .padding()
                    }
                } else {
                    ProgressView().progressViewStyle(CircularProgressViewStyle())
                }
            } else {
                Text("Fabricante no encontrado")
            }
                
            
        }
        .onAppear {
            viewModel.getCervezas(idFabricante: idFabricante)
        }
    }

    private func deleteCerveza(at offsets: IndexSet) {
        offsets.forEach { index in
            let idCerveza = viewModel.fabricantes.first(where: { $0.id == idFabricante })?.cervezas?[index].id
            //print(idCerveza ?? 0)
            viewModel.deleteCerveza(idCerveza: idCerveza)
        }
    }
}
