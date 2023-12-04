import SwiftUI

class Beer: Identifiable, Comparable, ObservableObject {
    static func < (lhs: Beer, rhs: Beer) -> Bool {
        return lhs.name < rhs.name
    }

    var id = UUID()
    @Published var name: String
    @Published var alcoholContent: Double
    @Published var caloricContent: Double
    @Published var image: UIImage?

    // Initialize with default values
    init(name: String, alcoholContent: Double, caloricContent: Double, image: UIImage? = nil) {
        self.name = name
        self.alcoholContent = alcoholContent
        self.caloricContent = caloricContent
        self.image = image
    }

    static func == (lhs: Beer, rhs: Beer) -> Bool {
        return lhs.id == rhs.id
    }
}
class Manufacturer: Identifiable, Equatable, ObservableObject {
    static func == (lhs: Manufacturer, rhs: Manufacturer) -> Bool {
        lhs.id == rhs.id
    }

    var id = UUID()
    var name: String
    @Published var beers: [Beer]

    init(name: String, beers: [Beer]) {
        self.name = name
        self.beers = beers
    }
    
}

class DataManager: ObservableObject {

    @Published var manufacturers: [Manufacturer] = [
        Manufacturer(name: "Heineken", beers: [Beer(name: "Beer 1",alcoholContent: 30,caloricContent: 299),
                                               Beer(name: "Beer 2",alcoholContent: 20,caloricContent: 199)]),
        Manufacturer(name: "Mahou", beers: [Beer(name: "Beer A",alcoholContent: 10,caloricContent: 99),
                                            Beer(name: "Beer B",alcoholContent: 50,caloricContent: 389)])
    ]
    func addBeer(to manufacturer: Manufacturer, name: String, alcoholContent: Double, caloricContent: Double, image: UIImage?) {
        // Find the manufacturer in the list
        if let index = manufacturers.firstIndex(of: manufacturer) {
            // Create a new beer with specified values
            let newBeer = Beer(name: name, alcoholContent: alcoholContent, caloricContent: caloricContent, image: image)
            // Add the new beer to the manufacturer's list of beers
            manufacturers[index].beers.append(newBeer)
        }
    }
}
