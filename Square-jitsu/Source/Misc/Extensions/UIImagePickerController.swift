//
// Created by Jakob Hain on 7/12/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import UIKit

fileprivate class ImagePickerLambdaDelegate: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private let onPick: (UIImage) -> ()

    init(_ onPick: @escaping (UIImage) -> ()) {
        self.onPick = onPick
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(picker: picker)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey:Any]) {
        if let pickedImage = info[.originalImage] as! UIImage? {
            onPick(pickedImage)
        }

        dismiss(picker: picker)
    }

    private func dismiss(picker: UIImagePickerController) {
        picker.delegate = nil
        picker.dismiss(animated: true)
        _ = Unmanaged.passUnretained(self).autorelease()
    }
}

extension UIImagePickerController {
    /// Assigns the delegate to a wrapper for this lambda - it will be called if an image is picked
    func onPick(_ action: @escaping (UIImage) -> ()) {
        let lambdaDelegate = ImagePickerLambdaDelegate(action)
        _ = Unmanaged.passRetained(lambdaDelegate)
        delegate = lambdaDelegate
    }
}
