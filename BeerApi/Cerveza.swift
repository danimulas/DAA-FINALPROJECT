import SwiftUI

class Cerveza: Identifiable, Codable {
    var id: String
    var nombre: String
    var tipo: String?
    var descripcion: String?
    var grados: Double?
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
        case id, nombre, tipo, descripcion, grados, logo
    }

    init(id: String, nombre: String, tipo: String?, descripcion: String?, grados: Double?, logo: String) {
        self.id = id
        self.nombre = nombre
        self.tipo = tipo
        self.descripcion = descripcion
        self.grados = grados
        self.logo = logo
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        nombre = try container.decode(String.self, forKey: .nombre)
        tipo = try container.decodeIfPresent(String.self, forKey: .tipo)
        descripcion = try container.decodeIfPresent(String.self, forKey: .descripcion)
        grados = try container.decodeIfPresent(Double.self, forKey: .grados)
        logo = try container.decode(String.self, forKey: .logo)
    }
}
