//
// Created by Jakob Hain on 6/6/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

struct CreateOnCollideComponent: SettingCodableByCodable, Codable {
    var createdTileType: TileType

    enum CodingKeys: String, CodingKey {
        case createdTileType
    }
}
