//
// Created by Jakob Hain on 6/14/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

let OnDestroySystems: [OnDestroySystem.Type] = [
    CreateOnDestroySystem.self
]

/// System which runs immediately on collision
protocol OnDestroySystem: System {
    mutating func onDestroy()
}

extension OnDestroySystem {
    static func onDestroy(entities: [Entity]) {
        for entity in entities {
            onDestroy(entity: entity)
        }
    }
    
    static func onDestroy(entity: Entity) {
        var system = Self(entity: entity)
        system.onDestroy()
    }
}