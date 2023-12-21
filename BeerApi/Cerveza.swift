import SwiftUI

class Cerveza: Identifiable, Codable {
    var id: String
    var nombre: String
    var tipo: String? // deberia de quitarlo porque tienen q tener tipo 
    var descripcion: String?
    var grados: Double?
    var kcal : Double?
    var logo: String
    var logoImage: UIImage? {
        // COnversion de la API a UImage
        if let imageData = Data(base64Encoded: logo) {
            return UIImage(data: imageData)
        }
        //cargar la imagen desde una URL si `logo` es una URL
        if let url = URL(string: logo), let imageData = try? Data(contentsOf: url) {
            return UIImage(data: imageData)
        }
        return nil
    }

    enum CodingKeys: String, CodingKey {
        case id, nombre, tipo, descripcion, grados, logo, kcal
    }
    
    init(id: String, nombre: String, tipo: String?, descripcion: String?, grados: Double?, logo: String, kcal: Double?) {
        self.id = id
        self.nombre = nombre
        self.tipo = tipo
        self.descripcion = descripcion
        self.grados = grados
        self.logo = logo
        self.kcal = kcal
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        nombre = try container.decode(String.self, forKey: .nombre)
        tipo = try container.decodeIfPresent(String.self, forKey: .tipo)
        descripcion = try container.decodeIfPresent(String.self, forKey: .descripcion)
        grados = try container.decodeIfPresent(Double.self, forKey: .grados)
        logo = try container.decode(String.self, forKey: .logo)
        kcal = try container.decode(Double.self, forKey: .kcal)
    }
}
