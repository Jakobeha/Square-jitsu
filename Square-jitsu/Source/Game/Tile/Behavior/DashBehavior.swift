//
// Created by Jakob Hain on 6/28/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class DashBehavior: EmptyTileBehavior<Never> {
    override func onEntitySolidCollide(entity: Entity, pos: WorldTilePos3D, side: Side) {
        if entity.next.dynC != nil {
            boostEntity(entity: entity, pos: pos, side: side)
        }
    }

    private func boostEntity(entity: Entity, pos: WorldTilePos3D, side: Side) {
        let myType = entity.world![pos]
        let settingIndex = Int(myType.smallType.value >> 2)
        if let boostSpeed = entity.world!.settings.dashEdgeBoostSpeed.getIfPresent(at: settingIndex) {
            let isClockwise = myType.smallType.isClockwise
            let boostVelocity = side.getParallelOffset(isClockwise: isClockwise).toCgPoint * boostSpeed
            entity.next.dynC!.velocity += boostVelocity
        } else {
            Logger.warnSettingsAreInvalid("dash edge won't boost entity because its index is out of dashEdgeBoostSpeed's bounds: \(settingIndex)")
        }
    }
}
