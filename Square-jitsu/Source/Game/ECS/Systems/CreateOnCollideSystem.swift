//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct CreateOnCollideSystem: System {
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
        if canCreateTileAt(side: side, pos: pos) {
            createTileAt(side: side, pos: pos)
        }
    }

    private func canCreateTileAt(side: Side, pos: WorldTilePos) -> Bool {
        !world[pos].contains { tileType in
            tileType.bigType.layer == entity.next.cocC!.createdTileType.bigType.layer &&
            !(tileType.withNullOrientation == entity.next.cocC!.createdTileType.withNullOrientation && doesOrientationSupportUnion(orientation: tileType.orientation))
        }
    }

    private func createTileAt(side: Side, pos: WorldTilePos) {
        var tileType: TileType = world[pos].first { tileType in tileType.bigType == entity.next.cocC!.createdTileType.bigType } ?? entity.next.cocC!.createdTileType
        tileType.orientation.asSideSet.insert(side.toSet)
        world.forceCreateTile(pos: pos, type: tileType)
    }

    private func doesOrientationSupportUnion(orientation: TileOrientation) -> Bool {
        (world.settings.tileOrientationMeanings[entity.next.cocC!.createdTileType] ?? .unused).doesSupportUnion
    }

    private var newAdjacentPositions: DenseEnumMap<Side, Set<WorldTilePos>> {
        DenseEnumMap { side in
            nextAdjacentPositions[side].subtracting(prevAdjacentPositions[side])
        }
    }

    private var nextAdjacentPositions: DenseEnumMap<Side, Set<WorldTilePos>> {
        CreateOnCollideSystem.getAdjacentPositionsFor(components: entity.next)
    }

    private var prevAdjacentPositions: DenseEnumMap<Side, Set<WorldTilePos>> {
        CreateOnCollideSystem.getAdjacentPositionsFor(components: entity.prev)
    }

    private static func getAdjacentPositionsFor(components: Entity.Components) -> DenseEnumMap<Side, Set<WorldTilePos>> {
        components.phyC?.adjacentPositions ??
        components.lilC?.adjacentPositions ??
        fatalError("illegal state - create-on-collide component missing dependencies").toValueViaAbsurd()
    }
}
