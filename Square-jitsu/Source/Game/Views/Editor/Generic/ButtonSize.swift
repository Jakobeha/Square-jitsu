//
// Created by Jakob Hain on 5/20/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

enum ButtonSize {
    case medium
    case small
    case tile

    var sideLength: CGFloat {
        switch self {
        case .medium:
            return 64
        case .small:
            return 32
        case .tile:
            return 32
        }
    }

    var cgSize: CGSize {
        CGSize.square(sideLength: sideLength)
    }
}
