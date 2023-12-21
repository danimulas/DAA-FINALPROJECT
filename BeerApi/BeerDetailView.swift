import SwiftUI

struct BeerDetailView: View {
    var cerveza: Cerveza
    @ObservedObject var viewModel: ManufacturerViewModel
    @State private var isEditingSheetPresented = false
    @State private var navigateToManufacturerDetail = false
    let idFabricante: String

    init(cerveza: Cerveza, viewModel: ManufacturerViewModel, idFabricante: String) {
        self.cerveza = cerveza
        self.viewModel = viewModel
        self.idFabricante = idFabricante
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 16) {
                if let image = cerveza.logoImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .cornerRadius(10)
                } else {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray)
                        .frame(width: 100, height: 100)
                }

                Text("Nombre: \(cerveza.nombre)")
                    .font(.title)
                    .fontWeight(.bold)

                if let tipo = cerveza.tipo {
                    Text("Tipo: \(tipo)")
                        .foregroundColor(.secondary)
                }

                if let descripcion = cerveza.descripcion {
                    Text("Descripción: \(descripcion)")
                        .foregroundColor(.secondary)
                }

                if let grados = cerveza.grados {
                    Text(String(format: "Grados: %.1f %%", grados))
                        .foregroundColor(.secondary)
                }

                if let kcal = cerveza.kcal {
                    Text(String(format: "Calorias: %.1f cal", kcal))
                        .foregroundColor(.secondary)
                }

            }
            .padding()
        }
        .navigationTitle("Caracteristicas")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Editar") {
                    isEditingSheetPresented.toggle()
                }
                .sheet(isPresented: $isEditingSheetPresented) {
                    EditBeerView(cerveza: cerveza, viewModel: viewModel, idFabricante: idFabricante)
                        .onDisappear {
                            navigateToManufacturerDetail = true
                        }
                }
            }
        }
        .background(
            NavigationLink("", destination: ManufacturerDetailView(viewModel: viewModel, idFabricante: idFabricante), isActive: $navigateToManufacturerDetail)
        )
    }
}
