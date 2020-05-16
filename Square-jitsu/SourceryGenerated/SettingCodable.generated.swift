// Generated using Sourcery 0.18.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// Modified from https://raw.githubusercontent.com/krzysztofzablocki/Sourcery/master/Templates/Templates/AutoCodable.swifttemplate
import SpriteKit
extension Adjacent4TileViewTemplate {
    static internal func decode(from setting: StructSetting<Adjacent4TileViewTemplate>) -> Adjacent4TileViewTemplate {
        self.init(
            textureBase: setting.usedFieldSettings["textureBase"]!.decodeDynamically(),
            adjoiningTypes: setting.usedFieldSettings["adjoiningTypes"]!.decodeDynamically(),
            semiAdjoiningTypes: setting.usedFieldSettings["semiAdjoiningTypes"]!.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<Adjacent4TileViewTemplate>) {
        self.textureBase.encodeDynamically(to: setting.allFieldSettings["textureBase"]!)
        self.adjoiningTypes.encodeDynamically(to: setting.allFieldSettings["adjoiningTypes"]!)
        self.semiAdjoiningTypes.encodeDynamically(to: setting.allFieldSettings["semiAdjoiningTypes"]!)
    }
}
extension Adjacent8TileViewTemplate {
    static internal func decode(from setting: StructSetting<Adjacent8TileViewTemplate>) -> Adjacent8TileViewTemplate {
        self.init(
            textureBase: setting.usedFieldSettings["textureBase"]!.decodeDynamically(),
            adjoiningTypes: setting.usedFieldSettings["adjoiningTypes"]!.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<Adjacent8TileViewTemplate>) {
        self.textureBase.encodeDynamically(to: setting.allFieldSettings["textureBase"]!)
        self.adjoiningTypes.encodeDynamically(to: setting.allFieldSettings["adjoiningTypes"]!)
    }
}
extension Entity.Components {
    static internal func decode(from setting: StructSetting<Entity.Components>) -> Entity.Components {
        self.init(
            locC: setting.usedFieldSettings["locC"]?.decodeDynamically(),
            larC: setting.usedFieldSettings["larC"]?.decodeDynamically(),
            dynC: setting.usedFieldSettings["dynC"]?.decodeDynamically(),
            imfC: setting.usedFieldSettings["imfC"]?.decodeDynamically(),
            docC: setting.usedFieldSettings["docC"]?.decodeDynamically(),
            phyC: setting.usedFieldSettings["phyC"]?.decodeDynamically(),
            ntlC: setting.usedFieldSettings["ntlC"]?.decodeDynamically(),
            griC: setting.usedFieldSettings["griC"]?.decodeDynamically(),
            graC: setting.usedFieldSettings["graC"]?.decodeDynamically(),
            helC: setting.usedFieldSettings["helC"]?.decodeDynamically(),
            toxC: setting.usedFieldSettings["toxC"]?.decodeDynamically(),
            nijC: setting.usedFieldSettings["nijC"]?.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<Entity.Components>) {
        self.locC?.encodeDynamically(to: setting.allFieldSettings["locC"]!)
        self.larC?.encodeDynamically(to: setting.allFieldSettings["larC"]!)
        self.dynC?.encodeDynamically(to: setting.allFieldSettings["dynC"]!)
        self.imfC?.encodeDynamically(to: setting.allFieldSettings["imfC"]!)
        self.docC?.encodeDynamically(to: setting.allFieldSettings["docC"]!)
        self.phyC?.encodeDynamically(to: setting.allFieldSettings["phyC"]!)
        self.ntlC?.encodeDynamically(to: setting.allFieldSettings["ntlC"]!)
        self.griC?.encodeDynamically(to: setting.allFieldSettings["griC"]!)
        self.graC?.encodeDynamically(to: setting.allFieldSettings["graC"]!)
        self.helC?.encodeDynamically(to: setting.allFieldSettings["helC"]!)
        self.toxC?.encodeDynamically(to: setting.allFieldSettings["toxC"]!)
        self.nijC?.encodeDynamically(to: setting.allFieldSettings["nijC"]!)
    }
}
extension StaticEntityViewTemplate {
    static internal func decode(from setting: StructSetting<StaticEntityViewTemplate>) -> StaticEntityViewTemplate {
        self.init(
            texture: setting.usedFieldSettings["texture"]!.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<StaticEntityViewTemplate>) {
        self.texture.encodeDynamically(to: setting.allFieldSettings["texture"]!)
    }
}
extension StaticTileViewTemplate {
    static internal func decode(from setting: StructSetting<StaticTileViewTemplate>) -> StaticTileViewTemplate {
        self.init(
            texture: setting.usedFieldSettings["texture"]!.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<StaticTileViewTemplate>) {
        self.texture.encodeDynamically(to: setting.allFieldSettings["texture"]!)
    }
}
extension WorldSettings {
    static internal func decode(from setting: StructSetting<WorldSettings>) -> WorldSettings {
        self.init(
            tileViewTemplates: setting.usedFieldSettings["tileViewTemplates"]!.decodeDynamically(),
            entityViewTemplates: setting.usedFieldSettings["entityViewTemplates"]!.decodeDynamically(),
            tileViewFadeDurations: setting.usedFieldSettings["tileViewFadeDurations"]!.decodeDynamically(),
            entityViewFadeDurations: setting.usedFieldSettings["entityViewFadeDurations"]!.decodeDynamically(),
            entityGrabColors: setting.usedFieldSettings["entityGrabColors"]!.decodeDynamically(),
            tileDescriptions: setting.usedFieldSettings["tileDescriptions"]!.decodeDynamically(),
            entityData: setting.usedFieldSettings["entityData"]!.decodeDynamically(),
            entitySpawnRadius: setting.usedFieldSettings["entitySpawnRadius"]!.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<WorldSettings>) {
        self.tileViewTemplates.encodeDynamically(to: setting.allFieldSettings["tileViewTemplates"]!)
        self.entityViewTemplates.encodeDynamically(to: setting.allFieldSettings["entityViewTemplates"]!)
        self.tileViewFadeDurations.encodeDynamically(to: setting.allFieldSettings["tileViewFadeDurations"]!)
        self.entityViewFadeDurations.encodeDynamically(to: setting.allFieldSettings["entityViewFadeDurations"]!)
        self.entityGrabColors.encodeDynamically(to: setting.allFieldSettings["entityGrabColors"]!)
        self.tileDescriptions.encodeDynamically(to: setting.allFieldSettings["tileDescriptions"]!)
        self.entityData.encodeDynamically(to: setting.allFieldSettings["entityData"]!)
        self.entitySpawnRadius.encodeDynamically(to: setting.allFieldSettings["entitySpawnRadius"]!)
    }
}
