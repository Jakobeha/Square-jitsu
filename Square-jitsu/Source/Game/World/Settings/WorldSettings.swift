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
    let edgeMaskTextureBase: TextureSet
    let glossTexture: SKTexture
    let imagePlaceholderTexture: SKTexture
    var entityZPositions: TileTypeMap<CGFloat>
    var rotateTileViewBasedOnOrientation: TileTypeMap<Bool>
    var entityViewScaleModes: TileTypeMap<ScaleMode>
    var entityGrabColors: TileTypeMap<SKColor>
    var amountScreenShakesWhenEntityCollides: TileTypeMap<CGFloat>
    var tileDescriptions: TileTypeMap<String>

    // Functional info
    var playerInputSpeedMultiplier: CGFloat
    var playerInputSpeedFractionChangePerSecond: CGFloat
    var tileDamage: TileTypeMap<CGFloat>
    var knockback: TileTypeMap<CGFloat>
    var entityData: TileTypeMap<Entity.Components>
    var entitySpawnRadius: TileTypeMap<CGFloat>
    var destructibleSolidInitialHealth: TileTypeMap<CGFloat>
    var dashEdgeBoostSpeed: [CGFloat]
    var springEdgeBounceMultiplier: [CGFloat]

    // Editor info
    var defaultTileMetadatas: TileTypeMap<TileMetadata>
    var tileOrientationMeanings: TileTypeMap<TileOrientationMeaning>
    var selectableTypes: [TileBigType:[TileSmallType]]

    init(tileViewTemplates: TileTypeMap<TileViewTemplate>, entityViewTemplates: TileTypeMap<EntityViewTemplate>, edgeMaskTextureBase: TextureSet, glossTexture: SKTexture, imagePlaceholderTexture: SKTexture, entityZPositions: TileTypeMap<CGFloat>, rotateTileViewBasedOnOrientation: TileTypeMap<Bool>, entityViewScaleModes: TileTypeMap<ScaleMode>, entityGrabColors: TileTypeMap<SKColor>, amountScreenShakesWhenEntityCollides: TileTypeMap<CGFloat>, tileDescriptions: TileTypeMap<String>, playerInputSpeedMultiplier: CGFloat, playerInputSpeedFractionChangePerSecond: CGFloat, tileDamage: TileTypeMap<CGFloat>, knockback: TileTypeMap<CGFloat>, entityData: TileTypeMap<Entity.Components>, entitySpawnRadius: TileTypeMap<CGFloat>, destructibleSolidInitialHealth: TileTypeMap<CGFloat>, dashEdgeBoostSpeed: [CGFloat], springEdgeBounceMultiplier: [CGFloat], defaultTileMetadatas: TileTypeMap<TileMetadata>, tileOrientationMeanings: TileTypeMap<TileOrientationMeaning>, selectableTypes: [TileBigType: [TileSmallType]]) {
        self.tileViewTemplates = tileViewTemplates
        self.entityViewTemplates = entityViewTemplates
        self.edgeMaskTextureBase = edgeMaskTextureBase
        self.glossTexture = glossTexture
        self.imagePlaceholderTexture = imagePlaceholderTexture
        self.entityZPositions = entityZPositions
        self.rotateTileViewBasedOnOrientation = rotateTileViewBasedOnOrientation
        self.entityViewScaleModes = entityViewScaleModes
        self.entityGrabColors = entityGrabColors
        self.amountScreenShakesWhenEntityCollides = amountScreenShakesWhenEntityCollides
        self.tileDescriptions = tileDescriptions
        self.playerInputSpeedMultiplier = playerInputSpeedMultiplier
        self.playerInputSpeedFractionChangePerSecond = playerInputSpeedFractionChangePerSecond
        self.tileDamage = tileDamage
        self.knockback = knockback
        self.entityData = entityData
        self.entitySpawnRadius = entitySpawnRadius
        self.destructibleSolidInitialHealth = destructibleSolidInitialHealth
        self.dashEdgeBoostSpeed = dashEdgeBoostSpeed
        self.springEdgeBounceMultiplier = springEdgeBounceMultiplier
        self.defaultTileMetadatas = defaultTileMetadatas
        self.tileOrientationMeanings = tileOrientationMeanings
        self.selectableTypes = selectableTypes
    }

    // region encoding and decoding
    typealias AsSetting = StructSetting<WorldSettings>

    static func newSetting() -> StructSetting<WorldSettings> {
        StructSetting(requiredFields: [
            "tileViewTemplates": TileTypeMapSetting<TileViewTemplate> { TileViewTemplateSetting() },
            "entityViewTemplates": TileTypeMapSetting<EntityViewTemplate> { EntityViewTemplateSetting() },
            "edgeMaskTextureBase": TextureSetSetting(),
            "glossTexture": TextureSetting(),
            "imagePlaceholderTexture": TextureSetting(),
            "entityZPositions": TileTypeMapSetting<CGFloat> { CGFloatRangeSetting(-TileType.zPositionUpperBound...TileType.zPositionUpperBound) },
            "rotateTileViewBasedOnOrientation": TileTypeMapSetting<Bool> { BoolSetting() },
            "entityViewScaleModes": TileTypeMapSetting<ScaleMode> { ScaleMode.newSetting() },
            "entityGrabColors": TileTypeMapSetting<SKColor> { ColorSetting() },
            "amountScreenShakesWhenEntityCollides": TileTypeMapSetting<CGFloat> { CGFloatRangeSetting(0...4) },
            "tileDescriptions": TileTypeMapSetting<String> { StringSetting() },
            "playerInputSpeedMultiplier": CGFloatRangeSetting(0...1),
            "playerInputSpeedFractionChangePerSecond": CGFloatRangeSetting(0...16),
            "tileDamage": TileTypeMapSetting<CGFloat> { CGFloatRangeSetting(0...1) },
            "knockback": TileTypeMapSetting<CGFloat> { CGFloatRangeSetting(0...128) },
            "entityData": TileTypeMapSetting<Entity.Components> { Entity.Components.newSetting() },
            "entitySpawnRadius": TileTypeMapSetting<CGFloat> { CGFloatRangeSetting(1...16) },
            "destructibleSolidInitialHealth": TileTypeMapSetting<CGFloat> { CGFloatRangeSetting(0...128) },
            "dashEdgeBoostSpeed": CollectionSetting<[CGFloat]> { CGFloatRangeSetting(0...128) },
            "springEdgeBounceMultiplier": CollectionSetting<[CGFloat]> { CGFloatRangeSetting(0...128) },
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
    // endregion

    /// Miscellaneous helper which is only here because I don't know where else to put it.
    /// Otherwise the settings object doesn't have helpers, just data
    func getUserFriendlyDescriptionOf(tileType: TileType) -> String {
        let bigTypeDescription = getUserFriendlyBigTypeDescriptionOf(bigType: tileType.bigType)
        let smallTypeDescription = getUserFriendlySmallTypeDescriptionOf(tileType: tileType)
        if smallTypeDescription.isEmpty {
            return bigTypeDescription
        } else {
            return "\(smallTypeDescription) \(bigTypeDescription)"
        }
    }

    private func getUserFriendlyBigTypeDescriptionOf(bigType: TileBigType) -> String {
        bigType.description.camelCaseToSubSentenceCase
    }

    private func getUserFriendlySmallTypeDescriptionOf(tileType: TileType) -> String {
        let description = tileDescriptions[tileType]
        if let description = description {
            return description.camelCaseToSentenceCase
        } else {
            Logger.warnSettingsAreInvalid("tile type doesn't have a description: \(tileType)")
            return TileType.unknownDescription
        }

    }
}
