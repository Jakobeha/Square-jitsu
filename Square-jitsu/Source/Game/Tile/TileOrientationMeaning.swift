//
// Created by Jakob Hain on 5/28/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

/// How a tile's orientation affects a tile
enum TileOrientationMeaning: Int, CaseIterable, Codable, LosslessStringConvertibleEnum {
    case unused
    case directionAdjacentToSolid
    case atSolidBorder

    /// Whether part of a tile can be added to the same position even when another tile is present
    /// with a different orientation, because the orientations can unify
    var doesSupportUnion: Bool {
        switch self {
        case .unused, .directionAdjacentToSolid:
            return false
        case .atSolidBorder:
            return true
        }
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
