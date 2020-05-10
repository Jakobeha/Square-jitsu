//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

/// World-specific settings which are immutable
/// (except for now the values are always the same. Maybe in the future they could be world specific...)
class WorldSettings {
    // SpriteKit tries to run 60fps so we run 2x.
    // This makes user input same-frame, since velocity changes must propagate into an entity's prev state to be rendered
    let fixedDeltaTime: CGFloat = 1.0 / 120

    let cameraSpeed: CGFloat = 1.0 / 16

    let tileViewWidthHeight: CGFloat = 48
    let tileViewConfigs: TileTypeMap<TileViewTemplate> = TileTypeMap([
        TileBigType.background:[StaticTileViewTemplate(textureName: "TestBackground")],
        TileBigType.overlapSensitiveBackground:[
            StaticTileViewTemplate(textureName: "TestOffBackground"),
            StaticTileViewTemplate(textureName: "TestOnBackground")
        ],
        TileBigType.solid:[StaticTileViewTemplate(textureName: "TestSolid")],
        TileBigType.adjacentSensitiveSolid:[
            StaticTileViewTemplate(textureName: "TestOffSolid"),
            StaticTileViewTemplate(textureName: "TestOnSolid")
        ]
    ])
    let entityViewConfigs: TileTypeMap<EntityViewTemplate> = TileTypeMap([
        TileBigType.playerSpawn:[StaticEntityViewTemplate(textureName: "Player")]
    ])
}
