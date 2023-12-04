import SwiftUI

struct BeerDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var beer: Beer
    @State private var isImagePickerPresented = false

    var body: some View {
        Form {
            Section(header: Text("Beer Details")) {
                TextField("Name", text: Binding(
                    get: { self.beer.name },
                    set: { self.beer.name = $0 }
                ))
                TextField("Alcohol Content", value: Binding(
                    get: { self.beer.alcoholContent },
                    set: { self.beer.alcoholContent = $0 }
                ), formatter: NumberFormatter())
                TextField("Caloric Content", value: Binding(
                    get: { self.beer.caloricContent },
                    set: { self.beer.caloricContent = $0 }
                ), formatter: NumberFormatter())

                Button("Select Photo") {
                    isImagePickerPresented.toggle()
                }
                
                if let selectedImage = beer.image {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 200)
                }
            }

            Section {
                Button("Accept") {
                    presentationMode.wrappedValue.dismiss()
                }

                Button("Cancel", role: .cancel) {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .navigationTitle("Edit Beer")
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(selectedImage: Binding(
                get: { self.beer.image },
                set: { self.beer.image = $0 }
            ))
        }
    }
}
