//
// Created by Jakob Hain on 5/27/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

protocol ReadonlyWorld: ReadonlyStatelessWorld {
    var readonlyChunks: [WorldChunkPos:ReadonlyChunk] { get }

    // Exposes mutability via `Entity#world` and the entity itself, not a problem now though
    var entities: [Entity] { get }

    var didReset: Observable<()> { get }
    var didUnloadChunk: Observable<(pos: WorldChunkPos, chunk: ReadonlyChunk)> { get }
    var didLoadChunk: Observable<(pos: WorldChunkPos, chunk: ReadonlyChunk)> { get }
    var didAddEntity: Observable<Entity> { get }
    var didRemoveEntity: Observable<Entity> { get }
    var didChangeSpeed: Observable<()> { get }
    var didTick: Observable<()> { get }

    func peek(pos: WorldTilePos) -> [TileType]
}
