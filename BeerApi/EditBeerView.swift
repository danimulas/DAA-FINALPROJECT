import SwiftUI

struct EditBeerView: View {
    @State private var nombre: String
    @State private var tipo: String
    @State private var descripcion: String
    @State private var grados: Int
    @State private var kcal: Double
    @State private var kcalText: String = ""
    @State private var selectedImage: UIImage?
    @State private var originalImage: UIImage?
    @State private var isImagePickerPresented = false
    @State private var isActionSheetPresented = false
    @State private var isURLTextFieldVisible = false
    @State private var urlString = ""
    @Environment(\.presentationMode) var presentationMode

    let idFabricante: String
    
    var cerveza: Cerveza
    @ObservedObject var viewModel: ManufacturerViewModel

    init(cerveza: Cerveza, viewModel: ManufacturerViewModel, idFabricante: String) {
        self.cerveza = cerveza
        self.viewModel = viewModel
        _nombre = State(initialValue: cerveza.nombre)
        _tipo = State(initialValue: cerveza.tipo ?? "")
        _descripcion = State(initialValue: cerveza.descripcion ?? "")
        _grados = State(initialValue: Int(cerveza.grados ?? 0.0))
        _kcal = State(initialValue: Double(cerveza.kcal ?? 0.0))
        self.idFabricante = idFabricante
    }
    let beerTypes = ["ipa", "lager", "pilsen"]

    var body: some View {
        Form {
            Section(header: Text("Información de la Cerveza")) {
                VStack {
                    if let image = selectedImage ?? originalImage ?? cerveza.logoImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                            .cornerRadius(10)
                    } else {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray)
                            .frame(height: 150)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                    }
                }
                .onTapGesture {
                    isImagePickerPresented = true
                }
                .frame(maxWidth: .infinity, alignment: .center)

                TextField("Nombre", text: $nombre)
                Picker("Tipo", selection: $tipo) {
                    ForEach(beerTypes, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(.menu)
                TextField("Descripción", text: $descripcion)
                Stepper("Grados: \(grados)", value: $grados)
                TextField("Calorias", text: $kcalText)
                .keyboardType(.decimalPad)
                .onChange(of: kcalText) { newValue in
                    if let kcalValue = Double(newValue) {
                        kcal = kcalValue
                    }
                }
            }

            Section(header: Text("Seleccionar Imagen")) {
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
                TextField("Ingrese la URL de la imagen", text: $urlString)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.URL)
                    .autocapitalization(.none)
            }

            Section {
                Button("Guardar Cambios") {
                    let gradosDouble = Double(grados)
                    
                    // si no hay url usa UIImage
                    let logoString = urlString.isEmpty ? (selectedImage?.jpegData(compressionQuality: 1.0)?.base64EncodedString() ?? (originalImage?.jpegData(compressionQuality: 1.0)?.base64EncodedString() ?? "")) : urlString

                    let updatedCerveza = Cerveza(id: cerveza.id, nombre: nombre, tipo: tipo, descripcion: descripcion, grados: gradosDouble, logo: logoString, kcal: kcal)
                    viewModel.updateCerveza(updatedCerveza: updatedCerveza)
                    
                    presentationMode.wrappedValue.dismiss()

                }
                .padding()
            }
        }
        .navigationTitle("Editar Cerveza")
        .onAppear {
            originalImage = cerveza.logoImage
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(image: $selectedImage)
        }
    }
}
