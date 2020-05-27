//
// Created by Jakob Hain on 5/19/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

protocol ReadonlyWorld: AnyObject {
    var settings: WorldSettings { get }

    subscript(pos: WorldTilePos) -> [TileType] { get }
    subscript(pos3D: WorldTilePos3D) -> TileType { get }

    func sideAdjacentsWithSameTypeAsTileAt(pos3D: WorldTilePos3D) -> Set<WorldTilePos3D>

    /// This is temporary because it's used by the editor and not guaranteed to actually hide the tile
    func temporarilyHide(positions: Set<WorldTilePos3D>)
    func showTemporarilyHidden(positions: Set<WorldTilePos3D>)
}
