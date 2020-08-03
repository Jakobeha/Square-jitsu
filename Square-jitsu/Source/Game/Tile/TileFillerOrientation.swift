//
// Created by Jakob Hain on 8/2/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

struct TileFillerOrientation {
    var rawValue: UInt8

    var direction: Side {
        get { Side(rawValue: Int(rawValue % Side.count))! }
        set { rawValue = UInt8(newValue.rawValue) + targetLayerData }
    }

    var targetLayer: Int {
        get { Int(rawValue / Side.count) }
        set {
            let targetLayerDataUnconstrained = newValue * Int(Side.count)
            assert(targetLayerDataUnconstrained <= UInt8.max)
            let targetLayerData = UInt8(targetLayerDataUnconstrained)

            rawValue = directionData + targetLayerData
        }
    }

    private var directionData: UInt8 {
        UInt8(direction.rawValue)
    }

    private var targetLayerData: UInt8 {
        (rawValue / Side.count) * Side.count
    }

    init(direction: Side, targetLayer: Int) {
        rawValue = 0

        self.direction = direction
        self.targetLayer = targetLayer
    }

    init(rawValue: UInt8) {
        self.rawValue = rawValue
    }

}
