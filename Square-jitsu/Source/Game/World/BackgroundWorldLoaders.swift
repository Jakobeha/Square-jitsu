//
// Created by Jakob Hain on 5/17/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

class BackgroundWorldLoaders {
    static let emptyName: String = "Empty"
    private(set) static var all: [String:WorldLoader] = [
        emptyName: EmptyWorldLoader(),
        "Dummy": DummyWorldLoader()
    ]

    private init() {}

    static func register(name: String, backgroundLoader: WorldLoader) {
        assert(!all.keys.contains(name))
        all[name] = backgroundLoader
    }
}
