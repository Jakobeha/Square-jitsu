//
// Created by Jakob Hain on 6/1/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

/// Additional persistent data for a tile.
/// Data which can't or is hard to fit in the tile's small type and orientation
protocol TileMetadata: Codable {}

/// For certain behaviors which derive from `EmptyTileBehavior` and have no metadata
extension Never: TileMetadata {}