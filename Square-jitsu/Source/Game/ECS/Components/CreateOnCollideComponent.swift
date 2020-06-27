//
// Created by Jakob Hain on 6/6/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

struct CreateOnCollideComponent: SingleSettingCodable, Codable {
    var createdType: TileType

    // region encoding and decoding
    enum CodingKeys: String, CodingKey {
        case createdType
    }

    typealias AsSetting = StructSetting<CreateOnCollideComponent>

    static func newSetting() -> AsSetting {
        StructSetting(requiredFields: [
            "createdType": TileTypeSetting()
        ], optionalFields: [:])
    }
    // endregion
}
