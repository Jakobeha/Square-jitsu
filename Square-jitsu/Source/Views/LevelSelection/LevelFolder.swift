//
// Created by Jakob Hain on 7/12/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import UIKit

struct LevelFolder {
    let url: URL

    var name: String {
        url.lastPathComponent
    }

    var toLevelItem: LevelItem {
        .folder(name: name, url: url)
    }

    init(url: URL) {
        self.url = url
    }
}
