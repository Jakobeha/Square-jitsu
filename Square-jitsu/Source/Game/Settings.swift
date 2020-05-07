//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

/// For now the values are always the same. Maybe in the future they could be level specific...
class Settings {
    let fixedDeltaTime: CGFloat = 1.0 / 60

    let cameraSpeed: CGFloat = 1.0 / 16

    let tileViewWidthHeight: CGFloat = 48
    let tileViewConfigs: TileTypeMap<TileViewTemplate> = TileTypeMap([
        TileBigType.background:[StaticTileViewTemplate(textureName: "TestBackground")],
        TileBigType.solid:[StaticTileViewTemplate(textureName: "TestSolid")]
    ])
    let entityViewConfigs: TileTypeMap<EntityViewTemplate> = TileTypeMap([
        TileBigType.playerSpawn:[StaticEntityViewTemplate(textureName: "Player")]
    ])
}
