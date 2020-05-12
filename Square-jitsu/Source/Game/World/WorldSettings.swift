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

    let entitySpawnRadius: TileTypeMap<CGFloat> = TileTypeMap([
        TileBigType.enemySpawn:[3]
    ])

    let tileViewWidthHeight: CGFloat = 48
    let tileViewConfigs: TileTypeMap<TileViewTemplate> = TileTypeMap([
        TileBigType.background:[
            Adjacent4TileViewTemplate(
                    baseName: "Background", 
                    adjoiningTypes: TileTypePred([TileLayer.background]),
                    semiAdjoiningTypes: TileTypePred([TileLayer.background, TileLayer.solid])
            )
        ],
        TileBigType.overlapSensitiveBackground:[
            StaticTileViewTemplate(textureName: "TestOffBackground"),
            StaticTileViewTemplate(textureName: "TestOnBackground")
        ],
        TileBigType.solid:[
            Adjacent8TileViewTemplate(baseName: "Solid", adjoiningTypes: TileTypePred([
                TileType.basicSolid,
                TileType.basicIce
            ]))
        ],
        TileBigType.adjacentSensitiveSolid:[
            StaticTileViewTemplate(textureName: "TestOffSolid"),
            StaticTileViewTemplate(textureName: "TestOnSolid")
        ],
        TileBigType.ice:[
            Adjacent8TileViewTemplate(baseName: "Ice", adjoiningTypes: TileTypePred([
                TileType.basicSolid,
                TileType.basicIce
            ]))
        ],
        TileBigType.shurikenSpawn:[StaticTileViewTemplate(textureName: "Shuriken")],
        TileBigType.enemySpawn:[StaticTileViewTemplate(textureName: "Enemy")]
    ])
    let entityViewConfigs: TileTypeMap<EntityViewTemplate> = TileTypeMap([
        TileBigType.playerSpawn:[StaticEntityViewTemplate(textureName: "Player")],
        TileBigType.shurikenSpawn:[StaticEntityViewTemplate(textureName: "Shuriken")],
        TileBigType.enemySpawn:[StaticEntityViewTemplate(textureName: "Enemy")]
    ])

    let tileViewFadeDuration: TileTypeMap<TimeInterval> = TileTypeMap([
        TileBigType.overlapSensitiveBackground:[nil, 0.5],
        TileBigType.adjacentSensitiveSolid:[nil, 0.5]
    ])

    let entityViewFadeDuration: TileTypeMap<TimeInterval> = TileTypeMap([
        TileBigType.shurikenSpawn:[1],
        TileBigType.enemySpawn:[1],
        TileBigType.playerSpawn:[1]
    ])

    let entityGrabColors: TileTypeMap<SKColor> = TileTypeMap([
        TileBigType.playerSpawn:[SKColor(hue: 1.0 / 12, saturation: 1, brightness: 1, alpha: 1)],
        TileBigType.enemySpawn:[SKColor(hue: 0, saturation: 1, brightness: 1, alpha: 1)]
    ])
}
