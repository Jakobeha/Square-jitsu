//
// Created by Jakob Hain on 5/7/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct HealthComponent: SingleSettingCodable, Codable {
    var maxHealth: CGFloat

    // sourcery: nonSetting
    var health: CGFloat

    var isAlive: Bool { health > 0 }

    init(maxHealth: CGFloat) {
        self.maxHealth = maxHealth
        health = maxHealth
    }

    mutating func restoreAllHealth() {
        health = maxHealth
    }

    // region encoding and decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(maxHealth: try container.decode(CGFloat.self, forKey: .maxHealth))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(maxHealth, forKey: .maxHealth)
    }

    typealias AsSetting = StructSetting<HealthComponent>

    static func newSetting() -> AsSetting {
        StructSetting(requiredFields: [
            "maxHealth": CGFloatRangeSetting(0...128)
        ], optionalFields: [:])
    }

    enum CodingKeys: String, CodingKey {
        case maxHealth
    }
    // endregion
}
