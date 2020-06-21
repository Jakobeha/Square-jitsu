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
    let tileViewWidthHeight: CGFloat = 32
    let fixedDeltaTime: CGFloat = 1.0 / 120
    let cameraSpeed: CGFloat = 1.0 / 16
    let shakeFade: CGFloat = 2
    let shakeInterpolationFractionPerFrame: CGFloat = 0.5
    let shakeInterpolationDistanceBeforeChange: CGFloat = 0.125

    // Display info
    var tileViewTemplates: TileTypeMap<TileViewTemplate>
    var entityViewTemplates: TileTypeMap<EntityViewTemplate>
    let glossTexture: SKTexture
    let glossyTileViews: TileTypePred
    var entityZPositions: TileTypeMap<CGFloat>
    var rotateTileViewBasedOnOrientation: TileTypeMap<Bool>
    var entityViewScaleModes: TileTypeMap<ScaleMode>
    var tileViewFadeDurations: TileTypeMap<TimeInterval>
    var entityViewFadeDurations: TileTypeMap<TimeInterval>
    var entityGrabColors: TileTypeMap<SKColor>
    var amountScreenShakesWhenEntityCollides: TileTypeMap<CGFloat>
    var tileDescriptions: TileTypeMap<String>

    // Functional info
    var playerInputSpeedMultiplier: CGFloat
    var tileDamage: TileTypeMap<CGFloat>
    var knockback: TileTypeMap<CGFloat>
    var entityData: TileTypeMap<Entity.Components>
    var entitySpawnRadius: TileTypeMap<CGFloat>

    // Editor info
    var defaultTileMetadatas: TileTypeMap<TileMetadata>
    var tileOrientationMeanings: TileTypeMap<TileOrientationMeaning>
    var selectableTypes: [TileBigType:[TileSmallType]]

    typealias AsSetting = StructSetting<WorldSettings>

    init(tileViewTemplates: TileTypeMap<TileViewTemplate>, entityViewTemplates: TileTypeMap<EntityViewTemplate>, glossTexture: SKTexture, glossyTileViews: TileTypePred, entityZPositions: TileTypeMap<CGFloat>, rotateTileViewBasedOnOrientation: TileTypeMap<Bool>, entityViewScaleModes: TileTypeMap<ScaleMode>, tileViewFadeDurations: TileTypeMap<TimeInterval>, entityViewFadeDurations: TileTypeMap<TimeInterval>, entityGrabColors: TileTypeMap<SKColor>, amountScreenShakesWhenEntityCollides: TileTypeMap<CGFloat>, tileDescriptions: TileTypeMap<String>, playerInputSpeedMultiplier: CGFloat, tileDamage: TileTypeMap<CGFloat>, knockback: TileTypeMap<CGFloat>, entityData: TileTypeMap<Entity.Components>, entitySpawnRadius: TileTypeMap<CGFloat>, defaultTileMetadatas: TileTypeMap<TileMetadata>, tileOrientationMeanings: TileTypeMap<TileOrientationMeaning>, selectableTypes: [TileBigType: [TileSmallType]]) {
        self.tileViewTemplates = tileViewTemplates
        self.entityViewTemplates = entityViewTemplates
        self.glossTexture = glossTexture
        self.glossyTileViews = glossyTileViews
        self.entityZPositions = entityZPositions
        self.rotateTileViewBasedOnOrientation = rotateTileViewBasedOnOrientation
        self.entityViewScaleModes = entityViewScaleModes
        self.tileViewFadeDurations = tileViewFadeDurations
        self.entityViewFadeDurations = entityViewFadeDurations
        self.entityGrabColors = entityGrabColors
        self.amountScreenShakesWhenEntityCollides = amountScreenShakesWhenEntityCollides
        self.tileDescriptions = tileDescriptions
        self.playerInputSpeedMultiplier = playerInputSpeedMultiplier
        self.tileDamage = tileDamage
        self.knockback = knockback
        self.entityData = entityData
        self.entitySpawnRadius = entitySpawnRadius
        self.defaultTileMetadatas = defaultTileMetadatas
        self.tileOrientationMeanings = tileOrientationMeanings
        self.selectableTypes = selectableTypes
    }

    static func newSetting() -> StructSetting<WorldSettings> {
        StructSetting(requiredFields: [
            "tileViewTemplates": TileTypeMapSetting<TileViewTemplate> { TileViewTemplateSetting() },
            "entityViewTemplates": TileTypeMapSetting<EntityViewTemplate> { EntityViewTemplateSetting() },
            "glossTexture": TextureSetting(),
            "glossyTileViews": TileTypePredSetting(),
            "entityZPositions": TileTypeMapSetting<CGFloat> { CGFloatRangeSetting(-TileType.zPositionUpperBound...TileType.zPositionUpperBound) },
            "rotateTileViewBasedOnOrientation": TileTypeMapSetting<Bool> { BoolSetting() },
            "entityViewScaleModes": TileTypeMapSetting<ScaleMode> { ScaleMode.newSetting() },
            "tileViewFadeDurations": TileTypeMapSetting<TimeInterval> { TimeRangeSetting(0...4) },
            "entityViewFadeDurations": TileTypeMapSetting<TimeInterval> { TimeRangeSetting(0...4) },
            "entityGrabColors": TileTypeMapSetting<SKColor> { ColorSetting() },
            "amountScreenShakesWhenEntityCollides": TileTypeMapSetting<CGFloat> { CGFloatRangeSetting(0...4) },
            "tileDescriptions": TileTypeMapSetting<String> { StringSetting() },
            "playerInputSpeedMultiplier": CGFloatRangeSetting(0...1),
            "tileDamage": TileTypeMapSetting<CGFloat> { CGFloatRangeSetting(0...1) },
            "knockback": TileTypeMapSetting<CGFloat> { CGFloatRangeSetting(0...128) },
            "entityData": TileTypeMapSetting<Entity.Components> { Entity.Components.newSetting() },
            "entitySpawnRadius": TileTypeMapSetting<CGFloat> { CGFloatRangeSetting(1...16) },
            "defaultTileMetadatas": TileTypeMapSetting<TileMetadata> { type in type.bigType.newMetadataSetting() },
            "tileOrientationMeanings": TileTypeMapSetting<TileOrientationMeaning> { SimpleEnumSetting<TileOrientationMeaning>() },
            "selectableTypes": DictionarySetting<TileBigType, [TileSmallType]> { CollectionSetting<[TileSmallType]> { TileSmallTypeSetting() } }
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