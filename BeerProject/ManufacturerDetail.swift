import SwiftUI
import UIKit

struct ManufacturerDetail: View {
    @ObservedObject var dataManager: DataManager
    @ObservedObject var manufacturer: Manufacturer

    @State private var searchText = ""
    @State private var isSortingSheetPresented = false
    @State private var isAddBeer = false
    @State private var newBeerName = ""
    @State private var sortingOption = SortingOption.name
    @State private var selectedBeer: Beer? 
    @State private var isBeerDetailPresented = false
    
    @State private var refreshFlag = false

    var body: some View {
        NavigationView {
            List {
                ForEach(sortedBeers) { beer in
                    BeerRow(beer: beer)
                        .onTapGesture {
                            self.selectedBeer = beer

                        }
                        
                }
                
                .onDelete(perform: deleteBeer) // Enable swipe-to-delete
            }
            .id(refreshFlag) // This will cause the view to refresh when refreshFlag changes
            .sheet(item: $selectedBeer,onDismiss: { refreshFlag.toggle() }) { selectedBeer in
                BeerDetailView(beer: selectedBeer)
            }
            .searchable(text: $searchText)
            .navigationTitle(manufacturer.name)
            .navigationBarItems(
                trailing: HStack {
                    Button("Add Beer") {
                        newBeerName = ""
                        isAddBeer.toggle()
                    }
                    .sheet(isPresented: $isAddBeer) {
                        AddBeerView(manufacturer: manufacturer, dataManager: dataManager)
                    }

                    Button("Sort by") {
                        isSortingSheetPresented.toggle()
                    }
                    .sheet(isPresented: $isSortingSheetPresented) {
                        SortingOptionsView(isPresented: $isSortingSheetPresented, sortingOption: $sortingOption)
                    }
                }
            )
            .onChange(of: sortingOption) {
                sortBeers()
            }
        }
    }

    // Function to delete beer
    func deleteBeer(at offsets: IndexSet) {
        manufacturer.beers.remove(atOffsets: offsets)
    }

    // Function to sort beers based on the sorting option
    func sortBeers() {
        switch sortingOption {
        case .name:
            manufacturer.beers.sort(by: { $0.name < $1.name })
        case .alcoholContent:
            manufacturer.beers.sort(by: { $0.alcoholContent < $1.alcoholContent })
        case .caloricContent:
            manufacturer.beers.sort(by: { $0.caloricContent < $1.caloricContent })
        }
    }

    // Property to get the sorted list of beers
    var sortedBeers: [Beer] {
        searchText.isEmpty ? manufacturer.beers : manufacturer.beers.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }
}
struct BeerRow: View {
    var beer: Beer

    var body: some View {
        HStack {
            if let beerImage = beer.image {
                Image(uiImage: beerImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            }
            Text(beer.name)
        }
    }
}

struct AddBeerView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var manufacturer: Manufacturer
    @ObservedObject var dataManager: DataManager

    @State private var newBeerName = ""
    @State private var alcoholContent = 0.0
    @State private var caloricContent = 0.0
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false

    var body: some View {
        VStack {
            TextField("Enter beer name", text: $newBeerName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            TextField("Enter alcohol content", text: Binding(get: {
                "\(alcoholContent)"
            }, set: { newValue in
                alcoholContent = Double(newValue) ?? 0.0
            }))
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .keyboardType(.decimalPad)
            .padding()

            TextField("Enter caloric content", text: Binding(get: {
                "\(caloricContent)"
            }, set: { newValue in
                caloricContent = Double(newValue) ?? 0.0
            }))
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .keyboardType(.decimalPad)
            .padding()

            Button("Select Photo") {
                isImagePickerPresented.toggle()
            }
            .padding()

            if let selectedImage = selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .padding()
            }

            Button("Add Beer") {
                // Add the new beer to the manufacturer's list of beers
                dataManager.addBeer(to: manufacturer, name: newBeerName, alcoholContent: alcoholContent, caloricContent: caloricContent, image: selectedImage)
                // Dismiss the sheet
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
        }
        .padding()
        .sheet(isPresented: $isImagePickerPresented, onDismiss: loadImage) {
            ImagePicker(selectedImage: $selectedImage)
        }
    }

    private func loadImage() {
        // Handle image picking logic here
    }
}
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        @Binding var selectedImage: UIImage?

        init(selectedImage: Binding<UIImage?>) {
            _selectedImage = selectedImage
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                selectedImage = uiImage
            }

            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(selectedImage: $selectedImage)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}
struct SortingOptionsView: View {
    @Binding var isPresented: Bool
    @Binding var sortingOption: SortingOption

    var body: some View {
        VStack {
            Text("Select Sorting Option")
                .font(.title)
                .padding()

            Button("Sort by Name") {
                sortingOption = .name
                isPresented = false
            }
            .padding()

            Button("Sort by Alcohol Content") {
                sortingOption = .alcoholContent
                isPresented = false
            }
            .padding()

            Button("Sort by Caloric Content") {
                sortingOption = .caloricContent
                isPresented = false
            }
            .padding()

            Button("Cancel") {
                isPresented = false
            }
            .padding()
        }
        .padding()
        .onDisappear {
            // Perform sorting based on the selected option before dismissing the sheet
            // You can add your sorting logic here
            // For simplicity, I'll just print the selected sorting option
            print("Sorting by: \(sortingOption)")
        }
    }
}

enum SortingOption {
    case name
    case alcoholContent
    case caloricContent
}
