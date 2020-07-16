//
// Created by Jakob Hain on 7/12/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct Level {
    let url: URL

    var name: String {
        url.deletingPathExtension().lastPathComponent
    }

    var toLevelItem: LevelItem {
        .level(name: name, url: url)
    }
}
