//
// Created by Jakob Hain on 7/16/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import UIKit

class WorldFilePreview {
    enum DecodingError: Error, CustomStringConvertible {
        case dataCorrupted(Data)

        var description: String {
            switch self {
            case .dataCorrupted(let data):
                return "data corrupted, not a valid image: \(data.description.truncatedFancy)"
            }
        }
    }

    static let missingOrCorrupted: UIImage = UIImage(named: "Misc/MissingOrCorruptedPreview")!

    private static let extendedAttributeName: String = "jakobeha.previewImage"

    static func readPreviewAt(url: URL) throws -> UIImage {
        let data = try url.getExtendedAttributeDataFor(name: extendedAttributeName)
        if let image = UIImage(data: data) {
            return image
        } else {
            throw DecodingError.dataCorrupted(data)
        }
    }

    static func writePreviewAt(url: URL, preview: UIImage) throws {
        try url.setExtendedAttribute(data: preview.pngData()!, name: extendedAttributeName)
    }
}
