import SwiftUI



struct Fabricante: Codable, Identifiable {
    var id: String
    var nombre: String
    var logo: String
    var tipo : String
    var cervezas: [Cerveza]?

    var logoImage: UIImage? {
        //COmprobamos que lo q nos llega es una UImage
        if let imageData = Data(base64Encoded: logo) {
            return UIImage(data: imageData)
        }
        //o si es una URL
        if let url = URL(string: logo), let imageData = try? Data(contentsOf: url) {
            return UIImage(data: imageData)
        }
                
        //SIno significa que no tiene logo y lo ponemos a null
        return nil
    }
}
