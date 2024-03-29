//
// Created by Jakob Hain on 6/26/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct CreateOnDestroyComponent: SingleSettingCodable, Codable {
    var createdType: TileType

    // region encoding and decoding
    enum CodingKeys: CodingKey {
        case createdType
    }

    typealias AsSetting = StructSetting<CreateOnDestroyComponent>

    static func newSetting() -> AsSetting {
        StructSetting(requiredFields: [
            "createdType": TileTypeSetting()
        ], optionalFields: [:])
    }
    // endregion
}
