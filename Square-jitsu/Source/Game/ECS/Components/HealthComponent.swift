//
// Created by Jakob Hain on 5/7/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct HealthComponent {
    var maxHealth: CGFloat

    var health: CGFloat

    var isAlive: Bool { health > 0 }

    init(maxHealth: CGFloat = 1) {
        self.maxHealth = maxHealth
        health = maxHealth
    }
}
