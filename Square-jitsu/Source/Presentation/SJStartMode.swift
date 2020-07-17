//
// Created by Jakob Hain on 7/16/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

enum SJStartMode: String, LosslessStringConvertible {
    case editorTestWorld
    case editorLevelSelection

    // region encoding and decoding
    var description: String {
        rawValue
    }

    init?(_ asString: String) {
        self.init(rawValue: asString)
    }
    // endregion
}
