import SwiftUI
struct ContentView: View {
    @State private var newManufacturer = ""
    @State private var searchText = ""
    @ObservedObject var dataManager = DataManager()

    var body: some View {
        NavigationView {
            VStack {
                Text("Beer Manufacturers🍺")
                    .font(.title)
                    .bold()
                TextField("Search", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                List {
                    ForEach(dataManager.manufacturers.filter {
                        searchText.isEmpty ? true : $0.name.localizedCaseInsensitiveContains(searchText)
                    }) { manufacturer in
                        NavigationLink(destination: ManufacturerDetail(dataManager: dataManager, manufacturer: manufacturer)) {
                            Text(manufacturer.name)
                        }
                        .contextMenu {
                            Button(action: {
                                if let index = dataManager.manufacturers.firstIndex(of: manufacturer) {
                                    dataManager.manufacturers.remove(at: index)
                                }
                            }) {
                                Text("Delete")
                                Image(systemName: "trash")
                            }
                        }
                    }
                    .onDelete(perform: deleteManufacturer) // Connect onDelete to the List
                }

                HStack {
                    TextField("Enter manufacturer", text: $newManufacturer)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Button(action: {
                        dataManager.manufacturers.append(Manufacturer(name: newManufacturer, beers: []))
                        newManufacturer = ""
                    }) {
                        Text("Add Manufacturer")
                    }
                    .padding(.leading, 8)
                }
                .padding()
            }
        }
    }

    // Move the delete function inside ContentView
    func deleteManufacturer(at offsets: IndexSet) {
        if let index = offsets.first {
            dataManager.manufacturers.remove(at: index)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
