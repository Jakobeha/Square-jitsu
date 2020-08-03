//
// Created by Jakob Hain on 8/1/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

struct TileFillerData {
    static let maxId: Int = Int(UInt8.max / TileFillerType.count)

    var rawValue: UInt8

    var type: TileFillerType {
        get { TileFillerType(rawValue: rawValue % TileFillerType.count)! }
        set { rawValue = newValue.rawValue + idData }
    }

    var id: Int {
        get { Int(rawValue / TileFillerType.count) }
        set {
            var idDataUnconstrained = newValue * Int(TileFillerType.count)
            if idDataUnconstrained > UInt8.max {
                Logger.warn("filler id is larger than fits in the data, so it will be confused with another filler")
                idDataUnconstrained = Int(UInt8.max)
            }
            let idData = UInt8(idDataUnconstrained)

            rawValue = typeData + idData
        }
    }

    private var typeData: UInt8 {
        type.rawValue
    }

    private var idData: UInt8 {
        (rawValue / TileFillerType.count) * TileFillerType.count
    }

    init(type: TileFillerType, id: Int) {
        rawValue = 0

        self.type = type
        self.id = id
    }

    init(rawValue: UInt8) {
        self.rawValue = rawValue
    }
}
