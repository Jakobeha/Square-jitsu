//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

/// Records tiles near an entity but not adjacent or collided
struct NearTileComponent: SingleSettingCodable, Codable {
    /// The radius around the entity where near tiles will be detected
    var nearRadiusExtra: CGFloat

    var nearTypes: TileTypeSet = TileTypeSet()

    var isNearToxicSolid: Bool {
        // nearTypes.contains(bigType: TileBigType.toxic)
        false
    }

    mutating func reset() {
        nearTypes.removeAll()
    }

    // region encoding and decoding
    typealias AsSetting = StructSetting<NearTileComponent>

    static func newSetting() -> AsSetting {
        StructSetting(requiredFields: [
            "nearRadiusExtra": CGFloatRangeSetting(0...16)
        ], optionalFields: [:])
    }

    enum CodingKeys: String, CodingKey {
        case nearRadiusExtra
    }
    // endregion
}
