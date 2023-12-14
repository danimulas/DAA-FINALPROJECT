import Foundation
import SwiftUI

struct ApiResponse: Codable {
    var fabricantes: [Fabricante]
    var message: String
}
struct CervezaResponse: Codable {
    let cervezas: [Cerveza]
    let message: String
}
struct CervezaRequest: Codable {
    let id_fabricante: String
    let nombre: String
    let tipo: String
    let logo: String
    let descripcion: String
    let grados: Int
}
class APIService {
    static let shared = APIService()
    private let apiKey = "f8c393cd-5860-4c4a-a967-7edfb94d9c0a"
    
    func fetchFabricantes(completion: @escaping (Result<[Fabricante], Error>) -> Void) {
        let urlString = "http://143.47.45.118:6969/daa-api/v1/fabricante/getFabricantes"
        guard let url = URL(string: urlString) else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "X-API-KEY")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(URLError(.cannotDecodeContentData)))
                return
            }
            do {
                let decodedResponse = try JSONDecoder().decode(ApiResponse.self, from: data)
                completion(.success(decodedResponse.fabricantes))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    func uploadFabricante(name: String, image: UIImage, completion: @escaping (Result<ApiResponse, Error>) -> Void) {
           guard let imageData = image.jpegData(compressionQuality: 0.8) else {
               //self.errorMessage = "Image could not be converted to Data."
               return
           }

           let base64ImageString = imageData.base64EncodedString()

           let urlString = "http://143.47.45.118:6969/daa-api/v1/fabricante/addFabricante"
           guard let url = URL(string: urlString) else {
               //self.errorMessage = "Invalid URL."
               return
           }

           var request = URLRequest(url: url)
           request.httpMethod = "POST"
           request.setValue("f8c393cd-5860-4c4a-a967-7edfb94d9c0a", forHTTPHeaderField: "X-API-KEY")
           request.setValue("application/json", forHTTPHeaderField: "Content-Type")

           let body: [String: Any] = [
               "nombre": name,
               "logo": base64ImageString
           ]

           guard let bodyData = try? JSONSerialization.data(withJSONObject: body, options: []) else {
               //self.errorMessage = "Could not create JSON body."
               return
           }

           request.httpBody = bodyData
           
           URLSession.shared.dataTask(with: request) { data, response, error in
               DispatchQueue.main.async {
                   if error != nil {
                       //self.errorMessage = error.localizedDescription
                       return
                   }
                   guard let data = data else {
                       //self.errorMessage = "No data received from the API."
                       return
                   }
                   do {
                       _ = try JSONDecoder().decode(ApiResponse.self, from: data)
                       
                       //self.fetchFabricantes() TENGO QUE IMPLEMENTAR ESTO

                   } catch {
                       //self.errorMessage = "Error decoding response: \(error.localizedDescription)"
                   }
               }
           }.resume()
       }
    
    func getCervezas(idFabricante: String, completion: @escaping (Result<CervezaResponse, Error>) -> Void) {
        var components = URLComponents(string: "http://143.47.45.118:6969/daa-api/v1/cerveza/getCervezas")
        components?.queryItems = [URLQueryItem(name: "id_fabricante", value: idFabricante)]
        
        guard let url = components?.url else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "X-API-KEY")
        
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                    print("Response HTTP Status code: \(httpResponse.statusCode)")
                }
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("Raw response string: \(responseString)")
                }
                
                
                guard let responseData = data else {
                    completion(.failure(URLError(.cannotDecodeContentData)))
                    return
                }
            
            do {
                let decodedResponse = try JSONDecoder().decode(CervezaResponse.self, from: responseData)
                completion(.success(decodedResponse))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    func deleteFabricante(idFabricante: String, completion: @escaping (Result<Bool, Error>) -> Void) {
            let urlString = "http://143.47.45.118:6969/daa-api/v1/fabricante/deleteFabricante"
            var components = URLComponents(string: urlString)
            components?.queryItems = [URLQueryItem(name: "id_fabricante", value: idFabricante)]

            guard let url = components?.url else {
                completion(.failure(URLError(.badURL)))
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            request.setValue(apiKey, forHTTPHeaderField: "X-API-KEY")

            URLSession.shared.dataTask(with: request) { _, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    completion(.success(true))
                } else {
                    completion(.failure(URLError(.badServerResponse)))
                }
            }.resume()
        }
    func addCerveza(cerveza: CervezaRequest, completion: @escaping (Result<Bool, Error>) -> Void) {
        let urlString = "http://143.47.45.118:6969/daa-api/v1/cerveza/addCerveza"
        guard let url = URL(string: urlString) else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        guard let jsonData = try? JSONEncoder().encode(cerveza) else {
            let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unable to encode cerveza data"])
            completion(.failure(error))
            return
        }
        
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            print("JSON String: \(jsonString)")
        }
        //EL JSON LO IMPRIME BIEN
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "X-API-KEY")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200:
                    completion(.success(true))
                default:
                    let responseBody = data.flatMap { String(data: $0, encoding: .utf8) } ?? "No response body"
                    print("Response Body: \(responseBody)")
                    let serverError = NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server returned status code \(httpResponse.statusCode)"])
                    completion(.failure(serverError))
                }
            }
        }.resume()
    }

}
