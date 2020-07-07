//
// Created by Jakob Hain on 5/28/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

/// How a tile's orientation affects a tile
enum TileOrientationMeaning: Int, CaseIterable, Codable, LosslessStringConvertibleEnum, HasDefault {
    case unused
    case directionAdjacentToSolid
    case directionToCorner
    case atBackgroundBorder
    case atSolidBorder

    static let defaultValue: TileOrientationMeaning = .unused

    var isDefault: Bool {
        self == TileOrientationMeaning.defaultValue
    }

    // region encoding and decoding
    var description: String { String(describing: self) }

    private static let meaningsByName: [String:TileOrientationMeaning] = [String:TileOrientationMeaning](
        uniqueKeysWithValues: allCases.map { meaning in (key: meaning.description, value: meaning) }
    )

    init?(_ description: String) {
        if let meaning = TileOrientationMeaning.meaningsByName[description] {
            self = meaning
        } else {
            return nil
        }
    }
    // endregion
}
