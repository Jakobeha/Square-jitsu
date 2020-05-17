//
// Created by Jakob Hain on 5/12/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

class Logger {
    static func warnSettingsAreInvalid(_ item: Any) {
        warn("the settings are invalid - \(item)")
    }

    static func warn(_ item: Any) {
        print("Warning: ", item)
    }

    private init() {}
}
