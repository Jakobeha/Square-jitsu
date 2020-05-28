//
// Created by Jakob Hain on 5/27/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

/// Readonly stateless world with editable state (the "state" doesn't persist).
protocol EditableReadonlyStatelessWorld: ReadonlyStatelessWorld {
    /// Synchronize actual (in-game) state with the persistent (file) state
    func resetStateAt(pos3D: WorldTilePos3D)

    func temporarilyHide(positions: Set<WorldTilePos3D>)
    func showTemporarilyHidden(positions: Set<WorldTilePos3D>)
}

extension EditableReadonlyStatelessWorld {
    func synchronizeInGameAndFileAt(positions: Set<WorldTilePos3D>) {
        for pos3D in positions {
            resetStateAt(pos3D: pos3D)
        }
    }
}