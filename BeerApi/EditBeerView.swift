import SwiftUI

struct EditBeerView: View {
    @State private var nombre: String
    @State private var tipo: String
    @State private var descripcion: String
    @State private var grados: Int
    var cerveza: Cerveza
    @ObservedObject var viewModel: ManufacturerViewModel
    @State private var selectedImage: UIImage?
        @State private var isImagePickerPresented = false
    init(cerveza: Cerveza, viewModel: ManufacturerViewModel) {
        self.cerveza = cerveza
        self.viewModel = viewModel
        _nombre = State(initialValue: cerveza.nombre)
        _tipo = State(initialValue: cerveza.tipo ?? "")
        _descripcion = State(initialValue: cerveza.descripcion ?? "")
        _grados = State(initialValue: Int(cerveza.grados ?? 0.0))
    }

    var body: some View {
        Form {
            Section(header: Text("Información de la Cerveza")) {
                TextField("Nombre", text: $nombre)
                TextField("Tipo", text: $tipo)
                TextField("Descripción", text: $descripcion)
                Stepper("Grados: \(grados)", value: $grados)
                Button("Seleccionar Imagen") {
                                    isImagePickerPresented = true
                                }
            }
            
            Button("Guardar Cambios") {
                let gradosDouble = Double(grados) // Convertir Int a Double

                
                let logoString = selectedImage?.jpegData(compressionQuality: 1.0)?.base64EncodedString() ?? ""

                let updatedCerveza = Cerveza(id: cerveza.id, nombre: nombre, tipo: tipo, descripcion: descripcion, grados: gradosDouble, logo: logoString)
                viewModel.updateCerveza(updatedCerveza: updatedCerveza)
            }
            .padding()
        }
        .navigationTitle("Editar Cerveza")
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(image:$selectedImage)
                }
    }
}
