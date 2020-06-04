//
// Created by Jakob Hain on 5/3/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

let TileBehaviorJsonEncoder: JSONEncoder = JSONEncoder()
let TileBehaviorJsonDecoder: JSONDecoder = JSONDecoder()

/// Performs tile-specific actions and stores the tile's (permanent) metadata,
/// sometimes as well as any temporary (game-persistent) data
protocol TileBehavior: AnyObject {
    var untypedMetadata: TileMetadata? { get set }

    init()

    /// This is guaranteed to be called before all other on... handlers except onCreate
    func onFirstLoad(world: World, pos: WorldTilePos3D)
    func onEntityCollide(entity: Entity, pos: WorldTilePos3D)
    func tick(world: World, pos: WorldTilePos3D)
    /// Revert any game-persistent state, keep permanent state.
    /// `x.revert()` may do more than `x = x.clonePermanent()`,
    /// because the former might also revert entities and modified types
    func revert(world: World, pos: WorldTilePos3D)

    func encodeMetadata() throws -> Data
    func decodeMetadata(from data: Data) throws
}

extension TileBehavior {
    func onCreate(world: ReadonlyStatelessWorld, pos3D: WorldTilePos3D) {
        let tileType = world[pos3D]
        untypedMetadata = world.settings.defaultTileMetadatas[tileType]
    }

    /// Doesn't copy persistent state
    func clonePermanent() -> Self {
        let copy = Self()
        copy.untypedMetadata = self.untypedMetadata
        return copy
    }
}

func EncodeTileMetadataToJson(pos: ChunkTilePos3D, tileBehavior: TileBehavior) throws -> JSON {
    let encodedMetadata = try tileBehavior.encodeMetadata()
    return JSON([
        "pos": try pos.encodeToJson(),
        "metadata": try JSON(data: encodedMetadata)
    ])
}

func DecodeTileMetadataFromJson(json: JSON, getTileBehavior: (ChunkTilePos3D) -> TileBehavior?) throws {
    let jsonDict = try json.toDictionary()

    try DecodeSettingError.assertKeysIn(dictionary: jsonDict, requiredKeys: ["pos", "metadata"])
    let posJson = jsonDict["pos"]!
    let tileMetadataJson = jsonDict["metadata"]!

    let pos3D = try ChunkTilePos3D(from: posJson)

    if let tileBehavior = getTileBehavior(pos3D) {
        let encodedMetadata = try tileMetadataJson.rawData()
        try tileBehavior.decodeMetadata(from: encodedMetadata)
    } else {
        throw DecodeSettingError.noMetadataAtPos(pos3D: pos3D)
    }
}