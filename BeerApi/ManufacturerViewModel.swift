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
    func updateCerveza(updatedCerveza: Cerveza) {
        // Asegúrate de que Cerveza tiene las propiedades necesarias
        let updateRequest = UpdateCervezaRequest(
            id_cerveza: updatedCerveza.id, // Suponiendo que Cerveza tiene un 'id'
            nombre: updatedCerveza.nombre,
            tipo: updatedCerveza.tipo ?? "",
            logo: updatedCerveza.logo ?? "",
            descripcion: updatedCerveza.descripcion ?? "",
            grados: updatedCerveza.grados ?? 0.0
        )
        
        // Llamar al modelo con la estructura de solicitud correcta
        manufacturersModel.updateCerveza(updateRequest: updateRequest)
        
    }
        
    /*
    func filteredFabricantes(by type: BeerType) -> [Fabricante] {
        switch type {
        case .all:
            return fabricantes
        case .national:
            return fabricantes.filter { $0.tipo == "nacional" }
        case .imported:
            return fabricantes.filter { $0.tipo == "importado" }
        }
    }*/
    func deleteCerveza(idCerveza: String?) {
            guard let idCerveza = idCerveza else { return }
            manufacturersModel.deleteCerveza(idCerveza: idCerveza)
            
    }
    
    func uploadFabricante(name: String,tipo: String, image: UIImage) {
        manufacturersModel.uploadFabricante(name: name,tipo: tipo, image: image)
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
