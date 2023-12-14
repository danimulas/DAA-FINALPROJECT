import Foundation
import UIKit

class ManufacturersModel {
    @Published var fabricantes: [Fabricante] = []
    @Published var errorMessage: String?
    @Published var cervezas: [Cerveza] = []
    func loadFabricantes() {
        APIService.shared.fetchFabricantes { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fabricantes):
                    self?.fabricantes = fabricantes
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func uploadFabricante(name: String, image: UIImage) {
           
            APIService.shared.uploadFabricante(name: name, image: image) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                     
                        self?.loadFabricantes()
                        break;
                    case .failure(let error):
                        
                        break;
                    }
                }
            }
        }
    func getCervezas(idFabricante: String, completion: @escaping () -> Void) {
            APIService.shared.getCervezas(idFabricante: idFabricante) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let cervezaResponse):
                        if let index = self?.fabricantes.firstIndex(where: { $0.id == idFabricante }) {
                            self?.fabricantes[index].cervezas = cervezaResponse.cervezas
                        }
                        completion()
                    case .failure(let error):
                        print("Error al obtener cervezas: \(error.localizedDescription)")
                        completion()
                    }
                }
            }
        }
    func deleteFabricante(idFabricante: String) {
            APIService.shared.deleteFabricante(idFabricante: idFabricante) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(_):
                        print("Fabricante eliminado con éxito")
                        // Actualiza la lista de fabricantes después de la eliminación
                        self.loadFabricantes()
                    case .failure(let error):
                        self.errorMessage = "Error al eliminar fabricante: \(error.localizedDescription)"
                    }
                }
            }
        }
    
    func addBeer(cervezaData: CervezaRequest, completion: @escaping (Result<Void, Error>) -> Void) {
        APIService.shared.addCerveza(cerveza: cervezaData) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self?.getCervezas(idFabricante: cervezaData.id_fabricante) {
                        completion(.success(()))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
}
