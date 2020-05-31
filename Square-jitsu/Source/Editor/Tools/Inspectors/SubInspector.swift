//
// Created by Jakob Hain on 5/28/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

protocol SubInspector {
    init(tiles: [TileAtPosition], world: ReadonlyStatelessWorld, delegate: EditorToolsDelegate?)
}
