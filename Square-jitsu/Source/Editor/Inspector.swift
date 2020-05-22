//
// Created by Jakob Hain on 5/19/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

struct Inspector {
    let positions: Set<WorldTilePos3D>
    weak var delegate: EditorToolsDelegate? = nil
    weak var world: ReadonlyWorld! = nil
}
