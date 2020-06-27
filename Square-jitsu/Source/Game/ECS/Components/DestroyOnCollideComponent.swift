//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

struct DestroyOnCollideComponent: SingleSettingCodable, Codable {
    var destroyOnEntityCollision: Bool
    var destroyOnSolidCollision: Bool
    var ignoredTypes: TileTypePred

    var ignoredEntities: Set<EntityRef> = []
    var isRemoved: Bool = false

    // region encoding and decoding
    enum CodingKeys: String, CodingKey {
        case destroyOnEntityCollision
        case destroyOnSolidCollision
        case ignoredTypes
    }

    typealias AsSetting = StructSetting<DestroyOnCollideComponent>

    static func newSetting() -> AsSetting {
        StructSetting(requiredFields: [
            "destroyOnEntityCollision": BoolSetting(),
            "destroyOnSolidCollision": BoolSetting(),
            "ignoredTypes": TileTypePredSetting()
        ], optionalFields: [:])
    }
    // endregion
}
