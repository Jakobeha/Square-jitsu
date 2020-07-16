//
// Created by Jakob Hain on 7/12/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

func WorldLocationSelector(
    currentWorldUrl: URL,
    width: CGFloat,
    selectedLocation: String?,
    selectAction: @escaping (String) -> ()
) -> LocationSelector<String> {
    LocationSelector<String>(
        width: width,
        selectedLocation: selectedLocation,
        selectionOptions: [
            LocationSelector.SelectionOption(label: "Local") { selectLocation, parentController in
                do {
                    let levelSelector = try LevelPickerViewController.new(initialUrl: currentWorldUrl.deletingLastPathComponent()) { levelUrl in
                        let relativePath = currentWorldUrl.deletingLastPathComponent().relativePathTo(url: levelUrl)
                        selectAction(relativePath)
                    }
                    parentController.present(levelSelector, animated: true)
                } catch {
                    let errorAlert = UIAlertController(title: "Error selecting local levels", message: error.localizedDescription, preferredStyle: .alert)
                    errorAlert.addAction(UIAlertAction(title: "Continue", style: .default))
                    parentController.present(errorAlert, animated: true)
                }
            }
        ],
        selectAction: selectAction
    )
}
