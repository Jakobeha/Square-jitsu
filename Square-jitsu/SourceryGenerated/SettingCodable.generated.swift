// Generated using Sourcery 0.18.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// Modified from https://raw.githubusercontent.com/krzysztofzablocki/Sourcery/master/Templates/Templates/AutoCodable.swifttemplate
import SpriteKit
extension Adjacent4TileViewTemplate {
    static internal func decode(from setting: StructSetting<Adjacent4TileViewTemplate>) -> Adjacent4TileViewTemplate {
        self.init(
            base: setting.fieldSettings["base"]!.decodeDynamically(),
            adjoiningTypes: setting.fieldSettings["adjoiningTypes"]!.decodeDynamically(),
            semiAdjoiningTypes: setting.fieldSettings["semiAdjoiningTypes"]!.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<Adjacent4TileViewTemplate>) {
        self.base.encodeDynamically(to: setting.fieldSettings["base"]!)
        self.adjoiningTypes.encodeDynamically(to: setting.fieldSettings["adjoiningTypes"]!)
        self.semiAdjoiningTypes.encodeDynamically(to: setting.fieldSettings["semiAdjoiningTypes"]!)
    }
}
extension Adjacent8TileViewTemplate {
    static internal func decode(from setting: StructSetting<Adjacent8TileViewTemplate>) -> Adjacent8TileViewTemplate {
        self.init(
            base: setting.fieldSettings["base"]!.decodeDynamically(),
            adjoiningTypes: setting.fieldSettings["adjoiningTypes"]!.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<Adjacent8TileViewTemplate>) {
        self.base.encodeDynamically(to: setting.fieldSettings["base"]!)
        self.adjoiningTypes.encodeDynamically(to: setting.fieldSettings["adjoiningTypes"]!)
    }
}
extension Entity.Components {
    static internal func decode(from setting: StructSetting<Entity.Components>) -> Entity.Components {
        self.init(
        )
    }

    internal func encode(to setting: StructSetting<Entity.Components>) {
    }
}
extension StaticEntityViewTemplate {
    static internal func decode(from setting: StructSetting<StaticEntityViewTemplate>) -> StaticEntityViewTemplate {
        self.init(
            texture: setting.fieldSettings["texture"]!.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<StaticEntityViewTemplate>) {
        self.texture.encodeDynamically(to: setting.fieldSettings["texture"]!)
    }
}
extension StaticTileViewTemplate {
    static internal func decode(from setting: StructSetting<StaticTileViewTemplate>) -> StaticTileViewTemplate {
        self.init(
            texture: setting.fieldSettings["texture"]!.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<StaticTileViewTemplate>) {
        self.texture.encodeDynamically(to: setting.fieldSettings["texture"]!)
    }
}
extension WorldSettings {
    static internal func decode(from setting: StructSetting<WorldSettings>) -> WorldSettings {
        self.init(
            tileViewTemplates: setting.fieldSettings["tileViewTemplates"]!.decodeDynamically(),
            entityViewTemplates: setting.fieldSettings["entityViewTemplates"]!.decodeDynamically(),
            tileViewFadeDurations: setting.fieldSettings["tileViewFadeDurations"]!.decodeDynamically(),
            entityViewFadeDurations: setting.fieldSettings["entityViewFadeDurations"]!.decodeDynamically(),
            entityGrabColors: setting.fieldSettings["entityGrabColors"]!.decodeDynamically(),
            tileDescriptions: setting.fieldSettings["tileDescriptions"]!.decodeDynamically(),
            entityData: setting.fieldSettings["entityData"]!.decodeDynamically(),
            entitySpawnRadius: setting.fieldSettings["entitySpawnRadius"]!.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<WorldSettings>) {
        self.tileViewTemplates.encodeDynamically(to: setting.fieldSettings["tileViewTemplates"]!)
        self.entityViewTemplates.encodeDynamically(to: setting.fieldSettings["entityViewTemplates"]!)
        self.tileViewFadeDurations.encodeDynamically(to: setting.fieldSettings["tileViewFadeDurations"]!)
        self.entityViewFadeDurations.encodeDynamically(to: setting.fieldSettings["entityViewFadeDurations"]!)
        self.entityGrabColors.encodeDynamically(to: setting.fieldSettings["entityGrabColors"]!)
        self.tileDescriptions.encodeDynamically(to: setting.fieldSettings["tileDescriptions"]!)
        self.entityData.encodeDynamically(to: setting.fieldSettings["entityData"]!)
        self.entitySpawnRadius.encodeDynamically(to: setting.fieldSettings["entitySpawnRadius"]!)
    }
}
