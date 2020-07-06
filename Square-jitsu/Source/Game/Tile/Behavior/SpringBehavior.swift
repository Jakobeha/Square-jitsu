//
// Created by Jakob Hain on 6/28/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class SpringBehavior: EmptyTileBehavior<Never> {
    override func onEntitySolidCollide(entity: Entity, pos: WorldTilePos3D, side: Side) {
        if entity.next.dynC != nil {
            bounceEntity(entity: entity, pos: pos, side: side)
        }
    }

    private func bounceEntity(entity: Entity, pos: WorldTilePos3D, side: Side) {
        let myType = entity.world![pos]
        let settingIndex = Int(myType.smallType.value >> 1)
        if let bounceMultiplier = entity.world!.settings.springEdgeBounceMultiplier.getIfPresent(at: settingIndex) {
            let actualBounceMultiplier = -bounceMultiplier
            // Check if entity is moving into the tile (otherwise don't bounce, if = 0 can't bounce anyways)
            if CGPoint.dot(entity.next.dynC!.velocity, side.perpendicularOffset.toCgPoint) > 0 {
                switch side.axis {
                case .horizontal:
                    entity.next.dynC!.velocity.x *= actualBounceMultiplier
                case .vertical:
                    entity.next.dynC!.velocity.y *= actualBounceMultiplier
                }
            }
        } else {
            Logger.warnSettingsAreInvalid("dash edge won't boost entity because its index is out of dashEdgeBoostSpeed's bounds: \(settingIndex)")
        }
    }
}
