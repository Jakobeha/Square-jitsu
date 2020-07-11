//
// Created by Jakob Hain on 7/9/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

enum InvalidTextureLocationError: Error, CustomStringConvertible {
    case namedNotFound(textureName: String)

    var description: String {
        switch self {
        case .namedNotFound(let textureName):
            return "named texture not found: \(textureName)"
        }
    }
}
