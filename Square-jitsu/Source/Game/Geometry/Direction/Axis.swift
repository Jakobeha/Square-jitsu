//
// Created by Jakob Hain on 5/6/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

enum Axis {
    case horizontal
    case vertical

    var toSet: AxisSet {
        switch self {
        case .horizontal:
            return AxisSet.horizontal
        case .vertical:
            return AxisSet.vertical
        }
    }
}
