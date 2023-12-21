import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = ManufacturerViewModel()
    @State private var showingUploadView = false
    @State private var searchText = ""

    // Filtered fabricantes based on searchText
    private var filteredFabricantes: [Fabricante] {
        if searchText.isEmpty {
            return viewModel.fabricantes
        } else {
            return viewModel.fabricantes.filter { $0.nombre.lowercased().contains(searchText.lowercased()) }
        }
    }

    // Agrupar los fabricantes por tipo
    private var groupedFabricantes: [String: [Fabricante]] {
        Dictionary(grouping: filteredFabricantes, by: { $0.tipo })
    }

    private var sortedKeys: [String] {
        groupedFabricantes.keys.sorted()
    }

    var body: some View {
        NavigationView {
            List {
                if viewModel.isLoading {
                    ProgressView()
                } else if let errorMessage = viewModel.errorMessage {
                    Text("Error: \(errorMessage)")
                } else {
                    // Search TextField
                    TextField("Buscar Fabricantes", text: $searchText)
                        

                    // Iterar sobre las claves ordenadas para mostrar las secciones
                    ForEach(sortedKeys, id: \.self) { key in
                        Section(header: Text(key.capitalized)) {
                            ForEach(groupedFabricantes[key] ?? []) { fabricante in
                                NavigationLink(destination: ManufacturerDetailView(viewModel: viewModel, idFabricante: fabricante.id)) {
                                    ManufacturerRow(fabricante: fabricante)
                                }
                            }
                            .onDelete(perform: deleteFabricante)
                        }
                    }
                }
            }
            .navigationTitle("Fabricantes")
            .onAppear {
                viewModel.loadFabricantes()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingUploadView.toggle()
                    }) {
                        Image(systemName: "plus.circle")
                    }
                }
            }
            .sheet(isPresented: $showingUploadView) {
                UploadFabricanteView(viewModel: viewModel)
                    .onDisappear {
                        viewModel.loadFabricantes()
                    }
            }
        }
    }

    private func deleteFabricante(at offsets: IndexSet) {
        viewModel.deleteFabricante(at: offsets)
    }
}

struct ManufacturerRow: View {
    let fabricante: Fabricante

    var body: some View {
        HStack {

            if let logoImage = fabricante.logoImage {
                Image(uiImage: logoImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .cornerRadius(8)
            } else {
                AsyncImage(url: URL(string: fabricante.logo)) { image in
                    image.resizable()
                } placeholder: {
                    Color.gray
                        .frame(width: 50, height: 50)
                        .cornerRadius(8)
                }
            }

            Text(fabricante.nombre)
                .font(.headline)
        }
    }
}

// Vista previa
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
