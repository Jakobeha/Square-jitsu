//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct CreateOnCollideSystem: TopLevelSystem {
    let entity: Entity

    init(entity: Entity) {
        self.entity = entity
    }

    static func preTick(world: World) {}

    static func postTick(world: World) {}

    func tick() {
        if entity.prev.cocC != nil {
            for (side, positions) in newAdjacentPositions {
                for pos in positions {
                    createTileIfNecessaryAt(side: side, pos: pos)
                }
            }
        }
    }

    private func createTileIfNecessaryAt(side: Side, pos: WorldTilePos) {
        var tileType: TileType = entity.next.cocC!.createdType
        tileType.orientation.asSideSet.insert(side.toSet)
        world.tryCreateTilePersistent(pos: pos, type: tileType)
    }

    private var newAdjacentPositions: DenseEnumMap<Side, Set<WorldTilePos>> {
        DenseEnumMap { side in
            entity.next.colC!.adjacentPositions[side].subtracting(entity.prev.colC!.adjacentPositions[side])
        }
    }
}
