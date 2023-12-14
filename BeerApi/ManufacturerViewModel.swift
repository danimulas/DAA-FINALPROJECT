import Combine
import SwiftUI

class ManufacturerViewModel: ObservableObject {
    @Published var fabricantes: [Fabricante] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var manufacturersModel = ManufacturersModel()
    
    @Published var name: String = ""

    
    
    @Published var cervezas: [Cerveza] = []
    @Published var message: String = ""
    
    func uploadFabricante(name: String, image: UIImage) {
            manufacturersModel.uploadFabricante(name: name, image: image)
        }

    init() {
        setupBindings()
    }

    func setupBindings() {
        manufacturersModel.$fabricantes.assign(to: &$fabricantes)
        manufacturersModel.$errorMessage.assign(to: &$errorMessage)
    }

    func loadFabricantes() {
        isLoading = true
        manufacturersModel.loadFabricantes()
        isLoading = false
    }
    func getCervezas(idFabricante: String) {
           manufacturersModel.getCervezas(idFabricante: idFabricante) {
               
               self.objectWillChange.send()// Notifica a SwiftUI que los datos han cambiado
           }
       }
    func deleteFabricante(at offsets: IndexSet) {
            //sacar el id del que hemos eliminado para eliminarlo despues de la API
            let idsToDelete = offsets.map { fabricantes[$0].id }

            fabricantes.remove(atOffsets: offsets)
            idsToDelete.forEach { id in //se podria hacer mas facil yo creo
                   manufacturersModel.deleteFabricante(idFabricante: id)
               }
        }
    func addCerveza(nombre: String, tipo: String, descripcion: String, grados: Double, idFabricante: String, logo: UIImage?) {
            // Convertir la imagen a Base64 si es UImage
            var logoBase64 = ""
            if let image = logo, let imageData = image.jpegData(compressionQuality: 0.8) {
                logoBase64 = imageData.base64EncodedString()
            } 
        //Creamos un objeto cerveza
        let cervezaData = CervezaRequest(id_fabricante: idFabricante, nombre: nombre, tipo: tipo, logo: logoBase64, descripcion: descripcion, grados: Int(grados))

            manufacturersModel.addBeer(cervezaData: cervezaData) { result in
                switch result {
                case .success():
                    print("Cerveza añadida con éxito")//deberiamos de hacerlo en un text
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
}
