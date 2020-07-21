//
// Created by Jakob Hain on 5/27/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

/// This protocol is actually only partially readonly,
/// will probably change in the future
protocol ReadonlyWorld: ReadonlyStatelessWorld {
    // Exposes mutability via whatever the conduit allows
    var conduit: WorldConduit { get }

    var readonlyChunks: [WorldChunkPos:ReadonlyChunk] { get }

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
