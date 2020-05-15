//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

/// World-specific settings which are immutable
/// (except for now the values are always the same. Maybe in the future they could be world specific...)
final class WorldSettings: SingleSettingCodable {
    static let `default`: WorldSettings = {
        let defaultJsonUrl = Bundle.main.url(forResource: "default", withExtension: "json")!
        let defaultJsonData = try! Data(contentsOf: defaultJsonUrl)
        let defaultJson = try! JSON(data: defaultJsonData)

        let worldSettingsSetting = WorldSettings.newSetting()
        try! worldSettingsSetting.decode(from: defaultJson)
        return WorldSettings.decode(from: worldSettingsSetting)
    }()

    // Global game constants which can't actually be changed

    // SpriteKit tries to run 60fps so we run 2x.
    // This makes user input same-frame, since velocity changes must propagate into an entity's prev state to be rendered
    let fixedDeltaTime: CGFloat = 1.0 / 120
    let cameraSpeed: CGFloat = 1.0 / 16
    let tileViewWidthHeight: CGFloat = 48

    // Display info
    var tileViewTemplates: TileTypeMap<TileViewTemplate>
    var entityViewTemplates: TileTypeMap<EntityViewTemplate>
    var tileViewFadeDurations: TileTypeMap<TimeInterval>
    var entityViewFadeDurations: TileTypeMap<TimeInterval>
    var entityGrabColors: TileTypeMap<SKColor>
    var tileDescriptions: TileTypeMap<String>

    // Functional info
    var entityData: TileTypeMap<Entity.Components>
    var entitySpawnRadius: TileTypeMap<CGFloat>

    typealias AsSetting = StructSetting<WorldSettings>

    init(tileViewTemplates: TileTypeMap<TileViewTemplate>, entityViewTemplates: TileTypeMap<EntityViewTemplate>, tileViewFadeDurations: TileTypeMap<TimeInterval>, entityViewFadeDurations: TileTypeMap<TimeInterval>, entityGrabColors: TileTypeMap<SKColor>, tileDescriptions: TileTypeMap<String>, entityData: TileTypeMap<Entity.Components>, entitySpawnRadius: TileTypeMap<CGFloat>) {
        self.tileViewTemplates = tileViewTemplates
        self.entityViewTemplates = entityViewTemplates
        self.tileViewFadeDurations = tileViewFadeDurations
        self.entityViewFadeDurations = entityViewFadeDurations
        self.entityGrabColors = entityGrabColors
        self.tileDescriptions = tileDescriptions
        self.entityData = entityData
        self.entitySpawnRadius = entitySpawnRadius
    }

    static func newSetting() -> StructSetting<WorldSettings> {
        StructSetting([
            "tileViewTemplates": TileTypeMapSetting<TileViewTemplate> { TileViewTemplateSetting() },
            "entityViewTemplates": TileTypeMapSetting { EntityViewTemplateSetting() },
            "tileViewFadeDurations": TileTypeMapSetting { TimeRangeSetting(0...4) },
            "entityViewFadeDurations": TileTypeMapSetting { TimeRangeSetting(0...4) },
            "entityGrabColors": TileTypeMapSetting { ColorSetting() },
            "tileDescriptions": TileTypeMapSetting { StringSetting() },
            "entityData": TileTypeMapSetting { Entity.Components.newSetting() },
            "entitySpawnRadius": TileTypeMapSetting { CGFloatRangeSetting(1...16) }
        ])
    }
}