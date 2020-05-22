//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

/// World-specific settings which are immutable
/// (except for now the values are always the same. Maybe in the future they could be world specific...)
final class WorldSettings: SingleSettingCodable, Codable {
    // Global game constants which can't actually be changed

    // SpriteKit tries to run 60fps so we run 2x.
    // This makes user input same-frame, since velocity changes must propagate into an entity's prev state to be rendered
    let fixedDeltaTime: CGFloat = 1.0 / 120
    let cameraSpeed: CGFloat = 1.0 / 16
    let tileViewWidthHeight: CGFloat = 48

    // Display info
    var tileViewTemplates: TileTypeMap<TileViewTemplate>
    var entityViewTemplates: TileTypeMap<EntityViewTemplate>
    var rotateTileViewBasedOnOrientation: TileTypeMap<Bool>
    var entityViewScaleModes: TileTypeMap<ScaleMode>
    var tileViewFadeDurations: TileTypeMap<TimeInterval>
    var entityViewFadeDurations: TileTypeMap<TimeInterval>
    var entityGrabColors: TileTypeMap<SKColor>
    var tileDescriptions: TileTypeMap<String>

    // Functional info
    var entityData: TileTypeMap<Entity.Components>
    var entitySpawnRadius: TileTypeMap<CGFloat>

    typealias AsSetting = StructSetting<WorldSettings>

    init(tileViewTemplates: TileTypeMap<TileViewTemplate>, entityViewTemplates: TileTypeMap<EntityViewTemplate>, rotateTileViewBasedOnOrientation: TileTypeMap<Bool>, entityViewScaleModes: TileTypeMap<ScaleMode>, tileViewFadeDurations: TileTypeMap<TimeInterval>, entityViewFadeDurations: TileTypeMap<TimeInterval>, entityGrabColors: TileTypeMap<SKColor>, tileDescriptions: TileTypeMap<String>, entityData: TileTypeMap<Entity.Components>, entitySpawnRadius: TileTypeMap<CGFloat>) {
        self.tileViewTemplates = tileViewTemplates
        self.entityViewTemplates = entityViewTemplates
        self.rotateTileViewBasedOnOrientation = rotateTileViewBasedOnOrientation
        self.entityViewScaleModes = entityViewScaleModes
        self.tileViewFadeDurations = tileViewFadeDurations
        self.entityViewFadeDurations = entityViewFadeDurations
        self.entityGrabColors = entityGrabColors
        self.tileDescriptions = tileDescriptions
        self.entityData = entityData
        self.entitySpawnRadius = entitySpawnRadius
    }

    static func newSetting() -> StructSetting<WorldSettings> {
        StructSetting(requiredFields: [
            "tileViewTemplates": TileTypeMapSetting<TileViewTemplate> { TileViewTemplateSetting() },
            "entityViewTemplates": TileTypeMapSetting<EntityViewTemplate> { EntityViewTemplateSetting() },
            "rotateTileViewBasedOnOrientation": TileTypeMapSetting<Bool> { BoolSetting() },
            "entityViewScaleModes": TileTypeMapSetting<ScaleMode> { ScaleMode.newSetting() },
            "tileViewFadeDurations": TileTypeMapSetting<TimeInterval> { TimeRangeSetting(0...4) },
            "entityViewFadeDurations": TileTypeMapSetting<TimeInterval> { TimeRangeSetting(0...4) },
            "entityGrabColors": TileTypeMapSetting<SKColor> { ColorSetting() },
            "tileDescriptions": TileTypeMapSetting<String> { StringSetting() },
            "entityData": TileTypeMapSetting<Entity.Components> { Entity.Components.newSetting() },
            "entitySpawnRadius": TileTypeMapSetting<CGFloat> { CGFloatRangeSetting(1...16) }
        ], optionalFields: [:])
    }

    convenience init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let json = try container.decode(JSON.self)

        let setting = WorldSettings.newSetting()
        try setting.decode(from: json)
        self.init(from: setting)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        let worldSettingsSetting = WorldSettings.newSetting()
        encode(to: worldSettingsSetting)
        let json = try worldSettingsSetting.encodeWellFormed()

        try container.encode(json)
    }
}