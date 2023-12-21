import SwiftUI

struct AddBeerView: View {
    @ObservedObject var viewModel: ManufacturerViewModel
    let idFabricante: String
    
    @State private var nombre: String = ""
    @State private var selectedType: String = "ipa"
    @State private var descripcion: String = ""
    @State private var grados: String = ""
    @State private var kcal: String = ""
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var isActionSheetPresented = false
    @State private var isURLTextFieldVisible = false
    @State private var urlString = ""
    @State private var isImagePickerPresented = false

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
                    TextField("Calorias ", text: $kcal)
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
                        isActionSheetPresented = true
                    }
                }
                .actionSheet(isPresented: $isActionSheetPresented) {
                    ActionSheet(title: Text("Seleccionar Imagen"), buttons: [
                        .default(Text("Desde la Galería")) {
                            isImagePickerPresented = true
                        },
                        .default(Text("Ingresar URL")) {
                            isURLTextFieldVisible.toggle()
                        },
                        .cancel()
                    ])
                }
                
                if isURLTextFieldVisible {
                    Section(header: Text("Ingresar URL de la Imagen")) {
                        TextField("Ingrese la URL de la imagen", text: $urlString)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.URL)
                            .autocapitalization(.none)
                    }
                }
                
                Button("Añadir Cerveza") {
                    let gradosDouble = Double(grados) ?? 0.0

                    // Lógica para decidir si usar la URL o la imagen seleccionada
                    let logo: Any?
                    if urlString.isEmpty {
                        logo = selectedImage
                        var logoBase64 = ""
                        if let image = logo as? UIImage, let imageData = image.jpegData(compressionQuality: 0.8) {
                            logoBase64 = imageData.base64EncodedString()
                        }
                        viewModel.addCerveza(nombre: nombre, tipo: selectedType, descripcion: descripcion, grados: gradosDouble, idFabricante: idFabricante, logo: logoBase64, kcal :kcal)
                    } else {
                        logo = urlString
                        viewModel.addCerveza(nombre: nombre, tipo: selectedType, descripcion: descripcion, grados: gradosDouble, idFabricante: idFabricante, logo: logo as? String, kcal :kcal)
                    }
                }
                .disabled(nombre.isEmpty || selectedType.isEmpty || descripcion.isEmpty || (isURLTextFieldVisible && urlString.isEmpty))
            }
            .navigationTitle("Añadir Nueva Cerveza")
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(image: $selectedImage)
            }
        }
    }
}
