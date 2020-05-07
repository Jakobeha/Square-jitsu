//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

/// For now the values are always the same. Maybe in the future they could be level specific...
class Settings {
    let fixedDeltaTime: CGFloat = 1.0 / 60

    let tileViewWidthHeight: CGFloat = 48
    let tileViewConfigs: TileTypeMap<TileTemplate> = TileTypeMap([
        TileBigType.background:[
            TileSmallType.backgroundBasic:StaticTileTemplate(textureName: "TestBackground")
        ],TileBigType.solid:[
            TileSmallType.solidBasic:StaticTileTemplate(textureName: "TestSolid")
        ],
        TileBigType.playerSpawn:[
            TileSmallType.playerSpawn:StaticTileTemplate(textureName: "Player")
        ]
    ])
}
