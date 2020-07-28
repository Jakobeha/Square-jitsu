//
// Created by Jakob Hain on 5/3/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

func EncodeTileMetadataToJsonV_0_1_1(pos: ChunkTilePos3DV_0_1_1, tileBehavior: TileBehavior) throws -> JSON {
    let encodedMetadata = try tileBehavior.encodeMetadata()
    return JSON([
        "pos": try pos.encodeToJson(),
        "metadata": try JSON(data: encodedMetadata)
    ])
}

func DecodeTileMetadataFromJsonV_0_1_1(json: JSON, getTileBehavior: (ChunkTilePos3DV_0_1_1) -> TileBehavior?) throws {
    let jsonDict = try json.toDictionary()

    try DecodeSettingError.assertKeysIn(dictionary: jsonDict, requiredKeys: ["pos", "metadata"])
    let posJson = jsonDict["pos"]!
    let tileMetadataJson = jsonDict["metadata"]!

    let pos3D = try ChunkTilePos3DV_0_1_1(from: posJson)

    if let tileBehavior = getTileBehavior(pos3D) {
        let encodedMetadata = try tileMetadataJson.rawData()
        try tileBehavior.decodeMetadata(from: encodedMetadata)
    } else {
        throw DecodeSettingError.noMetadataAtPos(pos3D: pos3D.upgraded)
    }
}