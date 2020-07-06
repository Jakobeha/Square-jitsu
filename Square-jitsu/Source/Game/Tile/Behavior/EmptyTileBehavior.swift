//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

/// Provides empty implementations of all on... handlers as well as a typed metadata variable.
/// When not subclassed, a behavior which does nothing.
class EmptyTileBehavior<Metadata: TileMetadata>: TileBehavior {
    var metadata: Metadata! = nil {
        didSet { _didChangeMetadata.publish() }
    }

    var untypedMetadata: TileMetadata? {
        get { metadata }
        set { metadata = newValue as! Metadata? }
    }

    private let _didChangeMetadata: Publisher<()> = Publisher()
    var didChangeMetadata: Observable<()> { Observable(publisher: _didChangeMetadata) }

    required init() {}

    func onFirstLoad(world: World, pos: WorldTilePos3D) {}
    func onEntityCollide(entity: Entity, pos: WorldTilePos3D) {}
    func onEntitySolidCollide(entity: Entity, pos: WorldTilePos3D, side: Side) {}
    func tick(world: World, pos: WorldTilePos3D) {}
    func revert(world: World, pos: WorldTilePos3D) {}

    // region encoding and decoding
    func encodeMetadata() throws -> Data {
        try TileBehaviorJsonEncoder.encodeWrapped(metadata)
    }

    func decodeMetadata(from data: Data) throws {
        if try JSON(data: data).dictionary == [:] {
            metadata = nil
        } else {
            metadata = try TileBehaviorJsonDecoder.decodeWrapped(Metadata?.self, from: data)
        }
    }
    // endregion
}
