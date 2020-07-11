//
// Created by Jakob Hain on 5/12/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

class Logger {
    static func warnSettingsAreInvalid(_ item: Any) {
        warn("the settings are invalid - \(item)")
    }

    static func warnActionOnStubConduit(_ methodDescription: String) {
        warn("action performed on stub conduit - \(methodDescription)")
    }

    static func warnInvalidActionOnConduit(_ description: String) {
        warn("tried to perform invalid action on conduit - \(description)")
    }

    static func warn(_ item: Any) {
        print("Warning: ", item)
    }

    static func log(_ item: Any) {
        print(item)
    }

    private init() {}
}
