//
// Created by Jakob Hain on 7/7/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct ImageMetadata: TileMetadata, SingleSettingCodable {
    var imageTexture: TextureLocation
    var sizeInTiles: CGSize

    // region encoding and decoding
    typealias AsSetting = StructSetting<ImageMetadata>

    static func newSetting() -> AsSetting {
        StructSetting(requiredFields: [
            "imageTexture": TextureLocationSetting(),
            "sizeInTiles": CGSizeRangeSetting(width: 1...CGFloat(Chunk.widthHeight), height: 1...CGFloat(Chunk.widthHeight))
        ], optionalFields: [:])
    }
    // endregion
}
