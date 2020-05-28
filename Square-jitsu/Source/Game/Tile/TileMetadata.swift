//
// Created by Jakob Hain on 5/3/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

protocol TileMetadata: AnyObject, JSONCodable {
    /// This is guaranteed to be called before all other on... handlers
    func onFirstLoad(world: World, pos: WorldTilePos3D)
    func onEntityCollide(entity: Entity, pos: WorldTilePos3D)
    func tick(world: World, pos: WorldTilePos3D)
    func revert(world: World, pos: WorldTilePos3D)
}

func EncodeTileMetadataToJson(pos: ChunkTilePos3D, tileMetadata: TileMetadata) throws -> JSON {
    JSON([
        "pos": try pos.encodeToJson(),
        "metadata": try tileMetadata.encodeToJson()
    ])
}

func DecodeTileMetadataFrom(json: JSON, getTileMetadata: (ChunkTilePos3D) -> TileMetadata?) throws {
    let jsonDict = try json.toDictionary()

    try DecodeSettingError.assertKeysIn(dictionary: jsonDict, requiredKeys: ["pos", "metadata"])
    let posJson = jsonDict["pos"]!
    let tileMetadataJson = jsonDict["metadata"]!

    var pos3D = ChunkTilePos3D.zero
    try pos3D.decodeFrom(json: posJson)

    if var tileMetadata = getTileMetadata(pos3D) {
        try tileMetadata.decodeFrom(json: tileMetadataJson)
    } else {
        throw DecodeSettingError.noMetadataAtPos(pos3D: pos3D)
    }
}