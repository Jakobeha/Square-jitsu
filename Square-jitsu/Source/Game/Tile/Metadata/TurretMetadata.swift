//
// Created by Jakob Hain on 6/1/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct TurretMetadata: TileMetadata, SingleSettingCodable {
    var initialTurretDirectionRelativeToAnchor: Angle
    var rotatesClockwise: Bool?

    // region encoding and decoding
    typealias AsSetting = StructSetting<TurretMetadata>

    static func newSetting() -> AsSetting {
        StructSetting(requiredFields: [
            "initialTurretDirectionRelativeToAnchor": AngleSetting()
        ], optionalFields: [
            "rotatesClockwise": OptionalSetting<Bool>(BoolSetting())
        ])
    }
    // endregion
}
