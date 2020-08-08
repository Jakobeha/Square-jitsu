//
// Created by Jakob Hain on 5/9/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

struct TileOrientation: Equatable, Hashable, LosslessStringConvertible {
    static let none = TileOrientation(rawValue: 0)

    var rawValue: UInt8

    var asOptionalSide: Side? {
        if rawValue > Side.count {
            Logger.warn("tried to access tile orientation as side but it isn't one")
            return .east
        } else {
            return rawValue == 0 ? nil : Side(rawValue: Int(rawValue - 1))
        }
    }

    var asSide: Side {
        rawValue == 0 ? .east : Side(rawValue: Int(rawValue - 1)) ?? {
            Logger.warn("tried to access tile orientation as side but it isn't one")
            return .east
        }()
    }

    var asCorner: Corner {
        rawValue == 0 ? .east : Corner(rawValue: Int(rawValue - 1)) ?? {
            Logger.warn("tried to access tile orientation as corner but it isn't one")
            return .east
        }()
    }

    var asSideSet: SideSet {
        get { SideSet(rawValue: rawValue) }
        set { self = TileOrientation(sideSet: newValue) }
    }

    var asFillerOrientation: TileFillerOrientation {
        get { TileFillerOrientation(rawValue: rawValue) }
        set { rawValue = newValue.rawValue }
    }

    init(optionalSide: Side?) {
        if let side = optionalSide {
            rawValue = UInt8(side.rawValue + 1)
        } else {
            rawValue = 0
        }
    }

    init(side: Side) {
        rawValue = UInt8(side.rawValue + 1)
    }

    init(corner: Corner) {
        rawValue = UInt8(corner.rawValue + 1)
    }

    init(sideSet: SideSet) {
        self.init(rawValue: sideSet.rawValue)
    }

    init(fillerOrientation: TileFillerOrientation) {
        self.init(rawValue: fillerOrientation.rawValue)
    }

    init(rawValue: UInt8) {
        self.rawValue = rawValue
    }

    // region encoding and decoding
    init?(_ description: String) {
        if let value = UInt8(description) {
            self.init(rawValue: value)
        } else {
            return nil
        }
    }

    var description: String { rawValue.description }
    // endregion
}
