//
// Created by Jakob Hain on 7/12/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

func ImageLocationSelector(
    width: CGFloat,
    selectedLocation: TextureLocation?,
    selectAction: @escaping (TextureLocation) -> ()
) -> LocationSelector<TextureLocation> {
    LocationSelector<TextureLocation>(
        width: width,
        selectedLocation: selectedLocation,
        selectionOptions: [
            LocationSelector.SelectionOption(label: "Built-in") { selectLocation, parentController in
                let alert = UIAlertController(title: "Enter built-in image name", message: nil, preferredStyle: .alert)
                alert.addTextField()
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                alert.addAction(UIAlertAction(title: "Select", style: .default) { _ in
                    if let imageName = alert.textFields![0].text,
                       !imageName.isEmpty {
                        do {
                            let imageLocation = try TextureLocation.builtin(asString: imageName)
                            selectLocation(imageLocation)
                        } catch {
                            let errorAlert = UIAlertController(title: "Couldn't select image", message: error.localizedDescription, preferredStyle: .alert)
                            errorAlert.addAction(UIAlertAction(title: "Continue", style: .default))
                            parentController.present(errorAlert, animated: true)
                        }
                    }
                })

                parentController.present(alert, animated: true)
            },
            LocationSelector.SelectionOption(label: "From URL") { selectLocation, parentController in
                let alert = UIAlertController(title: "Enter built-in image url", message: nil, preferredStyle: .alert)
                alert.addTextField { textField in
                    textField.placeholder = "http://the.url/of/the.image"
                    textField.keyboardType = .URL
                }
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                alert.addAction(UIAlertAction(title: "Select", style: .default) { _ in
                    if let imageUrlAsString = alert.textFields![0].text,
                       !imageUrlAsString.isEmpty {
                        do {
                            let imageLocation = try TextureLocation.fromUrl(asString: imageUrlAsString)
                            selectLocation(imageLocation)
                        } catch {
                            let errorAlert = UIAlertController(title: "Couldn't select image", message: error.localizedDescription, preferredStyle: .alert)
                            errorAlert.addAction(UIAlertAction(title: "Continue", style: .default))
                            parentController.present(errorAlert, animated: true)
                        }
                    }
                })

                parentController.present(alert, animated: true)
            },
            LocationSelector.SelectionOption(label: "From Library") { selectLocation, parentController in
                if !UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                    let alert = UIAlertController(title: "Can't pick image from photo library", message: "The library isn't available", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default))
                    parentController.present(alert, animated: true)
                    return
                }

                let pickerController = UIImagePickerController()
                pickerController.sourceType = .photoLibrary
                pickerController.mediaTypes = ["public.image"]
                pickerController.onPick { image in
                    selectLocation(TextureLocation.embeddedUiImage(image))
                }

                parentController.present(pickerController, animated: true)
            }
        ],
        selectAction: selectAction
    )
}
