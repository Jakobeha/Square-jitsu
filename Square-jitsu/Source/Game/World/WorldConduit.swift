//
// Created by Jakob Hain on 7/7/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

/// Allows objects inside a world (e.g. behaviors) to perform actions outside of the world.
/// For example, allows a portal to teleport the player to another world (load the other world in the game).
///
/// This functions exactly like a delegate,
/// except it's exposed publicly by the world to allow the world's objects to directly access it,
/// so that performing a conduit out-of-world action is more clearly distinguished from performing an in-world action.
///
/// Preferably, none of the methods should crash (instead display the issue or log a warning).
/// Remember that world data can be corrupt, and users can even create invalid worlds using the in-game editor (to an extent)
protocol WorldConduit: AnyObject {
    func teleportTo(relativePath: String)
    func perform(buttonAction: TileButtonAction)
}
