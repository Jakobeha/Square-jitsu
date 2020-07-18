//
// Created by Jakob Hain on 7/16/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

enum SJStartMode: String, LosslessStringConvertible {
    case editorTestWorld
    case editorLevelSelection

    /// This is the start mode regular users will get,
    /// and which will be run when the app is launched from the home screen
    /// (instead of on an IDE)
    static let `default`: SJStartMode = SJStartMode.editorLevelSelection

    // region encoding and decoding
    var description: String {
        rawValue
    }

    init?(_ asString: String) {
        self.init(rawValue: asString)
    }

    /// Helper which just returns nil when given nil
    init?(_ asOptionalString: String?) {
        if let asString = asOptionalString {
            self.init(asString)
        } else {
            return nil
        }
    }
    // endregion
}
