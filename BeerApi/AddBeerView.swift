import SwiftUI

struct AddBeerView: View {
    @ObservedObject var viewModel: ManufacturerViewModel
       let idFabricante: String
    
    @State private var nombre: String = ""
    @State private var tipo: String = ""
    @State private var descripcion: String = ""
    @State private var grados: String = ""
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Información de la Cerveza")) {
                    TextField("Nombre", text: $nombre)
                    TextField("Tipo", text: $tipo)
                    TextField("Descripción", text: $descripcion)
                    TextField("Grados", text: $grados)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Imagen de la Cerveza")) {
                    if let selectedImage = selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                    }
                    Button("Seleccionar Imagen") {
                        showingImagePicker = true
                    }
                }
                
                Button("Añadir Cerveza") {
                    let gradosDouble = Double(grados) ?? 0.0
                    viewModel.addCerveza(nombre: nombre, tipo: tipo, descripcion: descripcion, grados: gradosDouble, idFabricante: idFabricante, logo: selectedImage)
                }
                .disabled(nombre.isEmpty || tipo.isEmpty || descripcion.isEmpty)
            }
            .navigationTitle("Añadir Nueva Cerveza")
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: self.$selectedImage)
            }
        }
    }
}


