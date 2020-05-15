//
// Created by Jakob Hain on 5/7/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct NinjaComponent: SettingCodableByCodable, Codable {
    var jumpSpeed: CGFloat
    var jumpAngularSpeed: UnclampedAngle

    var actionState: NinjaActionState = .idle
    var backgroundTypesUsed: Set<TileType> = []

    enum CodingKeys: String, CodingKey {
        case jumpSpeed
        case jumpAngularSpeed
    }
}
