//
// Created by Jakob Hain on 5/18/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

class WorldSettingsManager {
    static let defaultName: String = "Default"
    private(set) static var all: [String:WorldSettings] = [
        defaultName: `default`
    ]

    static let `default`: WorldSettings = try! loadBuiltinSettings(fileName: "default.json")

    static func register(name: String, settings: WorldSettings) {
        assert(!all.keys.contains(name))
        all[name] = settings
    }

    private static func loadBuiltinSettings(fileName: String) throws -> WorldSettings {
        let defaultJsonUrl = Bundle.main.url(forResource: "default", withExtension: "json")!
        let defaultJsonData = try Data(contentsOf: defaultJsonUrl)
        return try JSONDecoder().decode(WorldSettings.self, from: defaultJsonData)
    }
}
