//
//  UploadFabricanteView.swift
//  BeerApi
//
//  Created by Dani Mulas on 12/12/23.
//

import SwiftUI

struct UploadFabricanteView: View {
    @ObservedObject var viewModel: ManufacturerViewModel
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var selectedType: String = "nacionales"
    
    @State private var ManufacturerType = ["importadas","nacionales"]
    var body: some View {
        NavigationView {
            VStack {
                TextField("Nombre del Fabricante", text: $viewModel.name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                if selectedImage != nil {
                    Image(uiImage: selectedImage!)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                }
                Picker("Tipo", selection: $selectedType) {
                    ForEach(ManufacturerType, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(.menu)
                Button("Seleccionar Imagen") {
                    showingImagePicker = true
                }
                .padding()
                
                Button("Subir Fabricante") {
                    if let selectedImage = selectedImage {
                        viewModel.uploadFabricante(name: viewModel.name,tipo: selectedType, image: selectedImage)
                        }
                }
                .padding()
                .disabled(selectedImage == nil || viewModel.name.isEmpty)
            }
            .navigationBarTitle("Nuevo Fabricante", displayMode: .inline)
            .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                ImagePicker(image: self.$inputImage)
            }
        }
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        selectedImage = inputImage
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: Context) -> some UIViewController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }

            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

