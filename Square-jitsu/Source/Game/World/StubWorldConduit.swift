//
// Created by Jakob Hain on 7/7/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

/// Doesn't actually perform the actions,
/// instead warns that they can't be performed
class StubWorldConduit: WorldConduit {
    func teleportTo(relativePath: String) {
        Logger.warnActionOnStubConduit("teleportTo(relativePath: \(relativePath)")
    }

    func perform(buttonAction: TileButtonAction) {
        Logger.warnActionOnStubConduit("perform(buttonAction: \(buttonAction)")
    }
}
