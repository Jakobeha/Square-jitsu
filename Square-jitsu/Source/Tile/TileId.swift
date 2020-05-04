//
// Created by Jakob Hain on 5/3/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

struct TileId: Equatable, Hashable {
    static let anonymous: TileId = TileId(0)

    static func forIndex(_ index: Int) -> TileId {
        TileId(UInt16(index) + 1)
    }

    let id: UInt16

    var isAnonymous: Bool {
        id == 0
    }

    var index: Int {
        assert(!isAnonymous)
        return Int(id) - 1
    }

    private init(_ id: UInt16) {
        self.id = id
    }
}
