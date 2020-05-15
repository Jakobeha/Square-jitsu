//
// Created by Jakob Hain on 5/7/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct HealthComponent: SettingCodableByCodable, Codable {
    var maxHealth: CGFloat

    var health: CGFloat

    var isAlive: Bool { health > 0 }

    init(maxHealth: CGFloat) {
        self.maxHealth = maxHealth
        health = maxHealth
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(maxHealth: try container.decode(CGFloat.self, forKey: .maxHealth))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(maxHealth, forKey: .maxHealth)
    }

    enum CodingKeys: String, CodingKey {
        case maxHealth
    }
}
