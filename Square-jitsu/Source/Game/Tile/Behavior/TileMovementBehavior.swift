//
// Created by Jakob Hain on 7/28/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

/// Different than other tile behaviors in that all tiles may or may not have this,
/// whereas regular behaviors some tiles always have and some tiles never have.
/// Also, this is stored separately from regular behaviors and tiles can have this metadata and a regular behavior.
class TileMovementBehavior {
    var metadata: TileMovementMetadata

    init(metadata: TileMovementMetadata) {
        self.metadata = metadata
    }
}
