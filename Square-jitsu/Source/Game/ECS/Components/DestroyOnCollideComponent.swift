//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

struct DestroyOnCollideComponent: SettingCodableByCodable, Codable {
    var destroyOnEntityCollision: Bool
    var destroyOnSolidCollision: Bool

    var isRemoved: Bool = false

    enum CodingKeys: String, CodingKey {
        case destroyOnEntityCollision
        case destroyOnSolidCollision
    }
}
