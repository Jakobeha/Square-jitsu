//
// Created by Jakob Hain on 5/19/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

struct TileAtPosition {
    var type: TileType
    var position: WorldTilePos3D
    var metadata: TileMetadata?
}
