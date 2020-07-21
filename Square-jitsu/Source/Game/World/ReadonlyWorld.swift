//
// Created by Jakob Hain on 5/27/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

/// This protocol is actually only partially readonly,
/// will probably change in the future
protocol ReadonlyWorld: ReadonlyStatelessWorld {
    // Exposes mutability via whatever the conduit allows
    var conduit: WorldConduit { get }

    var readonlyChunks: [WorldChunkPos:ReadonlyChunk] { get }

    /// Total number of ticks which occurred in the world since it loaded
    var numTicksSoFar: UInt64 { get }

    // Exposes mutability via the behavior itself
    func getBehaviorAt(pos3D: WorldTilePos3D) -> TileBehavior?

    // Exposes mutability via `Entity#world` and the entity itself
    var entities: [Entity] { get }

    var showEditingIndicators: Bool { get }

    var didReset: Observable<()> { get }
    var didUnloadChunk: Observable<(pos: WorldChunkPos, chunk: ReadonlyChunk)> { get }
    var didLoadChunk: Observable<(pos: WorldChunkPos, chunk: ReadonlyChunk)> { get }
    var didAddEntity: Observable<Entity> { get }
    var didRemoveEntity: Observable<Entity> { get }
    var didChangeSpeed: Observable<()> { get }
    var didTick: Observable<()> { get }
    var didChangeEditorIndicatorVisibility: Observable<()> { get }

    func peek(pos: WorldTilePos) -> [TileType]
}

extension ReadonlyWorld {
    /// Total time which occurred in the world.
    /// This is proportional to the number of ticks which occurred so far
    var elapsedTime: TimeInterval {
        TimeInterval(numTicksSoFar) * TimeInterval(settings.fixedDeltaTime)
    }
}
