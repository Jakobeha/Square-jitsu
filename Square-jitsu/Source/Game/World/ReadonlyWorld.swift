//
// Created by Jakob Hain on 5/19/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

protocol ReadonlyWorld: AnyObject {
    var settings: WorldSettings { get }

    subscript(pos: WorldTilePos) -> [TileType] { get }
    subscript(pos3D: WorldTilePos3D) -> TileType { get }

    func adjacentsWithSameTypeAsTileAt(pos3D: WorldTilePos3D) -> Set<WorldTilePos3D>
}
