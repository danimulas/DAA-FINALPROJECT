import SwiftUI

struct AddBeerView: View {
    @ObservedObject var viewModel: ManufacturerViewModel
    let idFabricante: String
    
    @State private var nombre: String = ""
    @State private var selectedType: String = "ipa"
    @State private var descripcion: String = ""
    @State private var grados: String = ""
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    let beerTypes = ["ipa", "lager", "pilsen"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Información de la Cerveza")) {
                    TextField("Nombre", text: $nombre)
                    Picker("Tipo", selection: $selectedType) {
                        ForEach(beerTypes, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    TextField("Descripción", text: $descripcion)
                    TextField("Grados", text: $grados)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Imagen de la Cerveza")) {
                    if let selectedImage = selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                    }
                    Button("Seleccionar Imagen") {
                        showingImagePicker = true
                    }
                }
                
                Button("Añadir Cerveza") {
                    let gradosDouble = Double(grados) ?? 0.0
                    viewModel.addCerveza(nombre: nombre, tipo: selectedType, descripcion: descripcion, grados: gradosDouble, idFabricante: idFabricante, logo: selectedImage)
                }
                .disabled(nombre.isEmpty || selectedType.isEmpty || descripcion.isEmpty)
            }
            .navigationTitle("Añadir Nueva Cerveza")
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $selectedImage)
            }
        }
    }
}
