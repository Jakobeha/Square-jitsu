//
// Created by Jakob Hain on 5/3/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

struct TileSmallType: Equatable, Hashable, LosslessStringConvertible {
    var rawValue: UInt8

    var isOn: Bool {
        get { (rawValue & 1) == 1 }
        set {
            if newValue {
                rawValue |= 1
            } else {
                rawValue &= ~1
            }
        }
    }

    var isCameraBoundaryShift: Bool {
        get { (rawValue & 1) == 1 }
        set {
            if newValue {
                rawValue |= 1
            } else {
                rawValue &= ~1
            }
        }
    }

    var isClockwise: Bool {
        get { (rawValue & 2) == 2 }
        set {
            if newValue {
                rawValue |= 2
            } else {
                rawValue &= ~2
            }
        }
    }

    var asButtonAction: TileButtonAction {
        if let asButtonAction = TileButtonAction(rawValue: rawValue) {
            return asButtonAction
        } else {
            Logger.warn("tried to cast tile orientation to button action but no button action exists with this value: \(rawValue)")
            return .play
        }
    }

    var asFillerData: TileFillerData {
        get { TileFillerData(rawValue: rawValue) }
        set { rawValue = newValue.rawValue }
    }

    init(buttonAction: TileButtonAction) {
        self.init(buttonAction.rawValue)
    }

    init(fillerData: TileFillerData) {
        self.init(fillerData.rawValue)
    }

    init(_ rawValue: UInt8) {
        self.rawValue = rawValue
    }

    // region encoding and decoding
    init?(_ description: String) {
        if let rawValue = UInt8(description) {
            self.init(rawValue)
        } else {
            return nil
        }
    }

    var description: String { rawValue.description }
    // endregion
}
