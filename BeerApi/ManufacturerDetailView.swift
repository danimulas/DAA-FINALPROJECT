import SwiftUI

struct ManufacturerDetailView: View {
    @ObservedObject var viewModel: ManufacturerViewModel
    let idFabricante: String
    @State private var sortOption: ManufacturerViewModel.SortOption = .name // Default sorting option
    @State private var sortOrder: ManufacturerViewModel.SortOrder = .ascending // Default sorting order
    @State private var showingAddBeerSheet = false // State para mostrar la hoja de agregar cerveza

    var sortedCervezas: [Cerveza] {
        guard let fabricante = viewModel.fabricantes.first(where: { $0.id == idFabricante }) else {
            return []
        }
        
        switch sortOption {
        case .name:
            return fabricante.cervezas?.sorted(by: { cerveza1, cerveza2 in
                let comparisonResult = cerveza1.nombre.compare(cerveza2.nombre)
                return sortOrder == .ascending ? comparisonResult == .orderedAscending : comparisonResult == .orderedDescending
            }) ?? []
        case .alcoholContent:
            return fabricante.cervezas?.sorted(by: { cerveza1, cerveza2 in
                if let grados1 = cerveza1.grados, let grados2 = cerveza2.grados {
                    return sortOrder == .ascending ? grados1 < grados2 : grados1 > grados2
                } else {
                    return false //manejar los nulls
                }
            }) ?? []
        }
    }
    
    var body: some View {
        VStack {
            if let fabricante = viewModel.fabricantes.first(where: { $0.id == idFabricante }) {
                if let cervezas = fabricante.cervezas {
                    if cervezas.isEmpty {
                        Text("No hay cervezas actualmente para este fabricante.")
                    } else {
                        List {
                            HStack(alignment: .center, spacing: 50) {
                                if let logoImage = fabricante.logoImage {
                                    Image(uiImage: logoImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 130, height: 130)
                                        .cornerRadius(10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.gray, lineWidth: 1)
                                        )
                                } else {
                                    Rectangle()
                                        .fill(Color.gray)
                                        .frame(width: 130, height: 130)
                                        .cornerRadius(10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.gray, lineWidth: 1)
                                        )
                                }
                                
                                VStack(alignment: .center) {
                                    Text(fabricante.nombre)
                                        .font(.title)
                                        .fontWeight(.bold)
                                    
                                }
                                .padding(.trailing, 25)
                            }
                            .padding(.vertical, 16)
                            
                            
                            ForEach(sortedCervezas, id: \.id) { cerveza in
                                NavigationLink(destination: BeerDetailView(cerveza: cerveza, viewModel: viewModel, idFabricante: idFabricante)) {
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
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Menu {
                        Picker(selection: $sortOption, label: Text("Ordenar por")) {
                            ForEach(ManufacturerViewModel.SortOption.allCases, id: \.self) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                        
                        Picker(selection: $sortOrder, label: Text("Orden")) {
                            Text("Ascendente").tag(ManufacturerViewModel.SortOrder.ascending)
                            Text("Descendente").tag(ManufacturerViewModel.SortOrder.descending)
                        }
                    } label: {
                        Label("Ordenar", systemImage: "arrow.up.arrow.down.circle")
                    }
                    
                    VStack {
                        Button(action: {
                            showingAddBeerSheet.toggle()
                        }) {
                            Label("Añadir Cerveza", systemImage: "plus.circle")
                        }
                        .sheet(isPresented: $showingAddBeerSheet) {
                            AddBeerView(viewModel: viewModel, idFabricante: idFabricante)
                        }
                    }
                }
            }
        }
    }

                
    private func deleteCerveza(at offsets: IndexSet) {
        offsets.forEach { index in
            let idCerveza = sortedCervezas[index].id
            viewModel.deleteCerveza(idCerveza: idCerveza)
        }
    }
}
