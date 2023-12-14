import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = ManufacturerViewModel()
    @State private var showingUploadView = false

    var body: some View {
        NavigationView {
            List {
                if viewModel.isLoading {
                    ProgressView()
                } else if let errorMessage = viewModel.errorMessage {
                    Text("Error: \(errorMessage)")
                } else {
                    ForEach(viewModel.fabricantes) { fabricante in
                        NavigationLink(destination: ManufacturerDetailView(viewModel: viewModel, idFabricante: fabricante.id)) {
                            ManufacturerRow(fabricante: fabricante)
                        }
                    }
                    .onDelete(perform: deleteFabricante)

                                   
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
                                    Image(systemName: "plus")
                                }
                            }
                        }
                        .sheet(isPresented: $showingUploadView) {
                            UploadFabricanteView(viewModel: viewModel)
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
