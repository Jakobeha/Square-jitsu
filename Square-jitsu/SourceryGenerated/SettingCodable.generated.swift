// Generated using Sourcery 0.18.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// Modified from https://raw.githubusercontent.com/krzysztofzablocki/Sourcery/master/Templates/Templates/AutoCodable.swifttemplate
import SpriteKit
extension Diamond4TileViewTemplate {
    internal convenience init(from setting: StructSetting<Diamond4TileViewTemplate>) {
        self.init(
            textureBase: setting.usedFieldSettings["textureBase"]!.decodeDynamically(),
            adjoiningTypes: setting.usedFieldSettings["adjoiningTypes"]!.decodeDynamically(),
            semiAdjoiningTypes: setting.usedFieldSettings["semiAdjoiningTypes"]!.decodeDynamically()
        )
    }

    static internal func decode(from setting: StructSetting<Diamond4TileViewTemplate>) -> Diamond4TileViewTemplate {
        self.init(
            textureBase: setting.usedFieldSettings["textureBase"]!.decodeDynamically(),
            adjoiningTypes: setting.usedFieldSettings["adjoiningTypes"]!.decodeDynamically(),
            semiAdjoiningTypes: setting.usedFieldSettings["semiAdjoiningTypes"]!.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<Diamond4TileViewTemplate>) {
        self.textureBase.encodeDynamically(to: setting.allFieldSettings["textureBase"]!)
        self.adjoiningTypes.encodeDynamically(to: setting.allFieldSettings["adjoiningTypes"]!)
        self.semiAdjoiningTypes.encodeDynamically(to: setting.allFieldSettings["semiAdjoiningTypes"]!)
    }
}
extension Entity.Components {
    internal init(from setting: StructSetting<Entity.Components>) {
        self.init(
            locC: setting.usedFieldSettings["locC"]?.decodeDynamically(),
            lilC: setting.usedFieldSettings["lilC"]?.decodeDynamically(),
            larC: setting.usedFieldSettings["larC"]?.decodeDynamically(),
            dynC: setting.usedFieldSettings["dynC"]?.decodeDynamically(),
            imfC: setting.usedFieldSettings["imfC"]?.decodeDynamically(),
            colC: setting.usedFieldSettings["colC"]?.decodeDynamically(),
            ntlC: setting.usedFieldSettings["ntlC"]?.decodeDynamically(),
            docC: setting.usedFieldSettings["docC"]?.decodeDynamically(),
            cocC: setting.usedFieldSettings["cocC"]?.decodeDynamically(),
            matC: setting.usedFieldSettings["matC"]?.decodeDynamically(),
            griC: setting.usedFieldSettings["griC"]?.decodeDynamically(),
            graC: setting.usedFieldSettings["graC"]?.decodeDynamically(),
            helC: setting.usedFieldSettings["helC"]?.decodeDynamically(),
            toxC: setting.usedFieldSettings["toxC"]?.decodeDynamically(),
            turC: setting.usedFieldSettings["turC"]?.decodeDynamically(),
            nijC: setting.usedFieldSettings["nijC"]?.decodeDynamically()
        )
    }

    static internal func decode(from setting: StructSetting<Entity.Components>) -> Entity.Components {
        self.init(
            locC: setting.usedFieldSettings["locC"]?.decodeDynamically(),
            lilC: setting.usedFieldSettings["lilC"]?.decodeDynamically(),
            larC: setting.usedFieldSettings["larC"]?.decodeDynamically(),
            dynC: setting.usedFieldSettings["dynC"]?.decodeDynamically(),
            imfC: setting.usedFieldSettings["imfC"]?.decodeDynamically(),
            colC: setting.usedFieldSettings["colC"]?.decodeDynamically(),
            ntlC: setting.usedFieldSettings["ntlC"]?.decodeDynamically(),
            docC: setting.usedFieldSettings["docC"]?.decodeDynamically(),
            cocC: setting.usedFieldSettings["cocC"]?.decodeDynamically(),
            matC: setting.usedFieldSettings["matC"]?.decodeDynamically(),
            griC: setting.usedFieldSettings["griC"]?.decodeDynamically(),
            graC: setting.usedFieldSettings["graC"]?.decodeDynamically(),
            helC: setting.usedFieldSettings["helC"]?.decodeDynamically(),
            toxC: setting.usedFieldSettings["toxC"]?.decodeDynamically(),
            turC: setting.usedFieldSettings["turC"]?.decodeDynamically(),
            nijC: setting.usedFieldSettings["nijC"]?.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<Entity.Components>) {
        self.locC?.encodeDynamically(to: setting.allFieldSettings["locC"]!)
        self.lilC?.encodeDynamically(to: setting.allFieldSettings["lilC"]!)
        self.larC?.encodeDynamically(to: setting.allFieldSettings["larC"]!)
        self.dynC?.encodeDynamically(to: setting.allFieldSettings["dynC"]!)
        self.imfC?.encodeDynamically(to: setting.allFieldSettings["imfC"]!)
        self.colC?.encodeDynamically(to: setting.allFieldSettings["colC"]!)
        self.ntlC?.encodeDynamically(to: setting.allFieldSettings["ntlC"]!)
        self.docC?.encodeDynamically(to: setting.allFieldSettings["docC"]!)
        self.cocC?.encodeDynamically(to: setting.allFieldSettings["cocC"]!)
        self.matC?.encodeDynamically(to: setting.allFieldSettings["matC"]!)
        self.griC?.encodeDynamically(to: setting.allFieldSettings["griC"]!)
        self.graC?.encodeDynamically(to: setting.allFieldSettings["graC"]!)
        self.helC?.encodeDynamically(to: setting.allFieldSettings["helC"]!)
        self.toxC?.encodeDynamically(to: setting.allFieldSettings["toxC"]!)
        self.turC?.encodeDynamically(to: setting.allFieldSettings["turC"]!)
        self.nijC?.encodeDynamically(to: setting.allFieldSettings["nijC"]!)
    }
}
extension LaserEntityViewTemplate {
    internal init(from setting: StructSetting<LaserEntityViewTemplate>) {
        self.init(
            color: setting.usedFieldSettings["color"]!.decodeDynamically(),
            thickness: setting.usedFieldSettings["thickness"]!.decodeDynamically()
        )
    }

    static internal func decode(from setting: StructSetting<LaserEntityViewTemplate>) -> LaserEntityViewTemplate {
        self.init(
            color: setting.usedFieldSettings["color"]!.decodeDynamically(),
            thickness: setting.usedFieldSettings["thickness"]!.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<LaserEntityViewTemplate>) {
        self.color.encodeDynamically(to: setting.allFieldSettings["color"]!)
        self.thickness.encodeDynamically(to: setting.allFieldSettings["thickness"]!)
    }
}
extension MatterComponent {
    internal init(from setting: StructSetting<MatterComponent>) {
        self.init(
            mass: setting.usedFieldSettings["mass"]!.decodeDynamically()
        )
    }

    static internal func decode(from setting: StructSetting<MatterComponent>) -> MatterComponent {
        self.init(
            mass: setting.usedFieldSettings["mass"]!.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<MatterComponent>) {
        self.mass.encodeDynamically(to: setting.allFieldSettings["mass"]!)
    }
}
extension MovingComponent {
    internal init(from setting: StructSetting<MovingComponent>) {
        self.init(
            dynamicKnockbackMultiplier: setting.usedFieldSettings["dynamicKnockbackMultiplier"]!.decodeDynamically()
        )
    }

    static internal func decode(from setting: StructSetting<MovingComponent>) -> MovingComponent {
        self.init(
            dynamicKnockbackMultiplier: setting.usedFieldSettings["dynamicKnockbackMultiplier"]!.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<MovingComponent>) {
        self.dynamicKnockbackMultiplier.encodeDynamically(to: setting.allFieldSettings["dynamicKnockbackMultiplier"]!)
    }
}
extension Square4DeterminedByOrientationTileViewTemplate {
    internal convenience init(from setting: StructSetting<Square4DeterminedByOrientationTileViewTemplate>) {
        self.init(
            textureBase: setting.usedFieldSettings["textureBase"]!.decodeDynamically()
        )
    }

    static internal func decode(from setting: StructSetting<Square4DeterminedByOrientationTileViewTemplate>) -> Square4DeterminedByOrientationTileViewTemplate {
        self.init(
            textureBase: setting.usedFieldSettings["textureBase"]!.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<Square4DeterminedByOrientationTileViewTemplate>) {
        self.textureBase.encodeDynamically(to: setting.allFieldSettings["textureBase"]!)
    }
}
extension Square8TileViewTemplate {
    internal convenience init(from setting: StructSetting<Square8TileViewTemplate>) {
        self.init(
            textureBase: setting.usedFieldSettings["textureBase"]!.decodeDynamically(),
            adjoiningTypes: setting.usedFieldSettings["adjoiningTypes"]!.decodeDynamically()
        )
    }

    static internal func decode(from setting: StructSetting<Square8TileViewTemplate>) -> Square8TileViewTemplate {
        self.init(
            textureBase: setting.usedFieldSettings["textureBase"]!.decodeDynamically(),
            adjoiningTypes: setting.usedFieldSettings["adjoiningTypes"]!.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<Square8TileViewTemplate>) {
        self.textureBase.encodeDynamically(to: setting.allFieldSettings["textureBase"]!)
        self.adjoiningTypes.encodeDynamically(to: setting.allFieldSettings["adjoiningTypes"]!)
    }
}
extension StaticEntityViewTemplate {
    internal init(from setting: StructSetting<StaticEntityViewTemplate>) {
        self.init(
            texture: setting.usedFieldSettings["texture"]!.decodeDynamically()
        )
    }

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
    internal init(from setting: StructSetting<StaticTileViewTemplate>) {
        self.init(
            texture: setting.usedFieldSettings["texture"]!.decodeDynamically()
        )
    }

    static internal func decode(from setting: StructSetting<StaticTileViewTemplate>) -> StaticTileViewTemplate {
        self.init(
            texture: setting.usedFieldSettings["texture"]!.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<StaticTileViewTemplate>) {
        self.texture.encodeDynamically(to: setting.allFieldSettings["texture"]!)
    }
}
extension ToxicComponent {
    internal init(from setting: StructSetting<ToxicComponent>) {
        self.init(
            damage: setting.usedFieldSettings["damage"]!.decodeDynamically(),
            safeTypes: setting.usedFieldSettings["safeTypes"]!.decodeDynamically()
        )
    }

    static internal func decode(from setting: StructSetting<ToxicComponent>) -> ToxicComponent {
        self.init(
            damage: setting.usedFieldSettings["damage"]!.decodeDynamically(),
            safeTypes: setting.usedFieldSettings["safeTypes"]!.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<ToxicComponent>) {
        self.damage.encodeDynamically(to: setting.allFieldSettings["damage"]!)
        self.safeTypes.encodeDynamically(to: setting.allFieldSettings["safeTypes"]!)
    }
}
extension TurretComponent {
    internal init(from setting: StructSetting<TurretComponent>) {
        self.init(
            rotationPattern: setting.usedFieldSettings["rotationPattern"]!.decodeDynamically(),
            whoToTarget: setting.usedFieldSettings["whoToTarget"]!.decodeDynamically(),
            whenToFire: setting.usedFieldSettings["whenToFire"]!.decodeDynamically(),
            howToFire: setting.usedFieldSettings["howToFire"]!.decodeDynamically(),
            whatToFire: setting.usedFieldSettings["whatToFire"]!.decodeDynamically(),
            delayWhenTargetFoundBeforeFire: setting.usedFieldSettings["delayWhenTargetFoundBeforeFire"]!.decodeDynamically()
        )
    }

    static internal func decode(from setting: StructSetting<TurretComponent>) -> TurretComponent {
        self.init(
            rotationPattern: setting.usedFieldSettings["rotationPattern"]!.decodeDynamically(),
            whoToTarget: setting.usedFieldSettings["whoToTarget"]!.decodeDynamically(),
            whenToFire: setting.usedFieldSettings["whenToFire"]!.decodeDynamically(),
            howToFire: setting.usedFieldSettings["howToFire"]!.decodeDynamically(),
            whatToFire: setting.usedFieldSettings["whatToFire"]!.decodeDynamically(),
            delayWhenTargetFoundBeforeFire: setting.usedFieldSettings["delayWhenTargetFoundBeforeFire"]!.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<TurretComponent>) {
        self.rotationPattern.encodeDynamically(to: setting.allFieldSettings["rotationPattern"]!)
        self.whoToTarget.encodeDynamically(to: setting.allFieldSettings["whoToTarget"]!)
        self.whenToFire.encodeDynamically(to: setting.allFieldSettings["whenToFire"]!)
        self.howToFire.encodeDynamically(to: setting.allFieldSettings["howToFire"]!)
        self.whatToFire.encodeDynamically(to: setting.allFieldSettings["whatToFire"]!)
        self.delayWhenTargetFoundBeforeFire.encodeDynamically(to: setting.allFieldSettings["delayWhenTargetFoundBeforeFire"]!)
    }
}
extension TurretEntityViewTemplate {
    internal init(from setting: StructSetting<TurretEntityViewTemplate>) {
        self.init(
            base: setting.usedFieldSettings["base"]!.decodeDynamically(),
            maxChargingCircleRadius: setting.usedFieldSettings["maxChargingCircleRadius"]!.decodeDynamically(),
            minChargingCircleRadius: setting.usedFieldSettings["minChargingCircleRadius"]!.decodeDynamically(),
            chargingCircleOffset: setting.usedFieldSettings["chargingCircleOffset"]!.decodeDynamically(),
            chargingCircleColor: setting.usedFieldSettings["chargingCircleColor"]!.decodeDynamically()
        )
    }

    static internal func decode(from setting: StructSetting<TurretEntityViewTemplate>) -> TurretEntityViewTemplate {
        self.init(
            base: setting.usedFieldSettings["base"]!.decodeDynamically(),
            maxChargingCircleRadius: setting.usedFieldSettings["maxChargingCircleRadius"]!.decodeDynamically(),
            minChargingCircleRadius: setting.usedFieldSettings["minChargingCircleRadius"]!.decodeDynamically(),
            chargingCircleOffset: setting.usedFieldSettings["chargingCircleOffset"]!.decodeDynamically(),
            chargingCircleColor: setting.usedFieldSettings["chargingCircleColor"]!.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<TurretEntityViewTemplate>) {
        self.base.encodeDynamically(to: setting.allFieldSettings["base"]!)
        self.maxChargingCircleRadius.encodeDynamically(to: setting.allFieldSettings["maxChargingCircleRadius"]!)
        self.minChargingCircleRadius.encodeDynamically(to: setting.allFieldSettings["minChargingCircleRadius"]!)
        self.chargingCircleOffset.encodeDynamically(to: setting.allFieldSettings["chargingCircleOffset"]!)
        self.chargingCircleColor.encodeDynamically(to: setting.allFieldSettings["chargingCircleColor"]!)
    }
}
extension TurretMetadata {
    internal init(from setting: StructSetting<TurretMetadata>) {
        self.init(
            initialTurretDirectionRelativeToAnchor: setting.usedFieldSettings["initialTurretDirectionRelativeToAnchor"]!.decodeDynamically()
        )
    }

    static internal func decode(from setting: StructSetting<TurretMetadata>) -> TurretMetadata {
        self.init(
            initialTurretDirectionRelativeToAnchor: setting.usedFieldSettings["initialTurretDirectionRelativeToAnchor"]!.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<TurretMetadata>) {
        self.initialTurretDirectionRelativeToAnchor.encodeDynamically(to: setting.allFieldSettings["initialTurretDirectionRelativeToAnchor"]!)
    }
}
extension TurretTileViewTemplate {
    internal init(from setting: StructSetting<TurretTileViewTemplate>) {
        self.init(
            base: setting.usedFieldSettings["base"]!.decodeDynamically(),
            turretTexture: setting.usedFieldSettings["turretTexture"]!.decodeDynamically()
        )
    }

    static internal func decode(from setting: StructSetting<TurretTileViewTemplate>) -> TurretTileViewTemplate {
        self.init(
            base: setting.usedFieldSettings["base"]!.decodeDynamically(),
            turretTexture: setting.usedFieldSettings["turretTexture"]!.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<TurretTileViewTemplate>) {
        self.base.encodeDynamically(to: setting.allFieldSettings["base"]!)
        self.turretTexture.encodeDynamically(to: setting.allFieldSettings["turretTexture"]!)
    }
}
extension WorldSettings {
    internal convenience init(from setting: StructSetting<WorldSettings>) {
        self.init(
            tileViewTemplates: setting.usedFieldSettings["tileViewTemplates"]!.decodeDynamically(),
            entityViewTemplates: setting.usedFieldSettings["entityViewTemplates"]!.decodeDynamically(),
            entityZPositions: setting.usedFieldSettings["entityZPositions"]!.decodeDynamically(),
            rotateTileViewBasedOnOrientation: setting.usedFieldSettings["rotateTileViewBasedOnOrientation"]!.decodeDynamically(),
            entityViewScaleModes: setting.usedFieldSettings["entityViewScaleModes"]!.decodeDynamically(),
            tileViewFadeDurations: setting.usedFieldSettings["tileViewFadeDurations"]!.decodeDynamically(),
            entityViewFadeDurations: setting.usedFieldSettings["entityViewFadeDurations"]!.decodeDynamically(),
            entityGrabColors: setting.usedFieldSettings["entityGrabColors"]!.decodeDynamically(),
            tileDescriptions: setting.usedFieldSettings["tileDescriptions"]!.decodeDynamically(),
            tileDamage: setting.usedFieldSettings["tileDamage"]!.decodeDynamically(),
            knockback: setting.usedFieldSettings["knockback"]!.decodeDynamically(),
            entityData: setting.usedFieldSettings["entityData"]!.decodeDynamically(),
            entitySpawnRadius: setting.usedFieldSettings["entitySpawnRadius"]!.decodeDynamically(),
            defaultTileMetadatas: setting.usedFieldSettings["defaultTileMetadatas"]!.decodeDynamically(),
            tileOrientationMeanings: setting.usedFieldSettings["tileOrientationMeanings"]!.decodeDynamically(),
            selectableTypes: setting.usedFieldSettings["selectableTypes"]!.decodeDynamically()
        )
    }

    static internal func decode(from setting: StructSetting<WorldSettings>) -> WorldSettings {
        self.init(
            tileViewTemplates: setting.usedFieldSettings["tileViewTemplates"]!.decodeDynamically(),
            entityViewTemplates: setting.usedFieldSettings["entityViewTemplates"]!.decodeDynamically(),
            entityZPositions: setting.usedFieldSettings["entityZPositions"]!.decodeDynamically(),
            rotateTileViewBasedOnOrientation: setting.usedFieldSettings["rotateTileViewBasedOnOrientation"]!.decodeDynamically(),
            entityViewScaleModes: setting.usedFieldSettings["entityViewScaleModes"]!.decodeDynamically(),
            tileViewFadeDurations: setting.usedFieldSettings["tileViewFadeDurations"]!.decodeDynamically(),
            entityViewFadeDurations: setting.usedFieldSettings["entityViewFadeDurations"]!.decodeDynamically(),
            entityGrabColors: setting.usedFieldSettings["entityGrabColors"]!.decodeDynamically(),
            tileDescriptions: setting.usedFieldSettings["tileDescriptions"]!.decodeDynamically(),
            tileDamage: setting.usedFieldSettings["tileDamage"]!.decodeDynamically(),
            knockback: setting.usedFieldSettings["knockback"]!.decodeDynamically(),
            entityData: setting.usedFieldSettings["entityData"]!.decodeDynamically(),
            entitySpawnRadius: setting.usedFieldSettings["entitySpawnRadius"]!.decodeDynamically(),
            defaultTileMetadatas: setting.usedFieldSettings["defaultTileMetadatas"]!.decodeDynamically(),
            tileOrientationMeanings: setting.usedFieldSettings["tileOrientationMeanings"]!.decodeDynamically(),
            selectableTypes: setting.usedFieldSettings["selectableTypes"]!.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<WorldSettings>) {
        self.tileViewTemplates.encodeDynamically(to: setting.allFieldSettings["tileViewTemplates"]!)
        self.entityViewTemplates.encodeDynamically(to: setting.allFieldSettings["entityViewTemplates"]!)
        self.entityZPositions.encodeDynamically(to: setting.allFieldSettings["entityZPositions"]!)
        self.rotateTileViewBasedOnOrientation.encodeDynamically(to: setting.allFieldSettings["rotateTileViewBasedOnOrientation"]!)
        self.entityViewScaleModes.encodeDynamically(to: setting.allFieldSettings["entityViewScaleModes"]!)
        self.tileViewFadeDurations.encodeDynamically(to: setting.allFieldSettings["tileViewFadeDurations"]!)
        self.entityViewFadeDurations.encodeDynamically(to: setting.allFieldSettings["entityViewFadeDurations"]!)
        self.entityGrabColors.encodeDynamically(to: setting.allFieldSettings["entityGrabColors"]!)
        self.tileDescriptions.encodeDynamically(to: setting.allFieldSettings["tileDescriptions"]!)
        self.tileDamage.encodeDynamically(to: setting.allFieldSettings["tileDamage"]!)
        self.knockback.encodeDynamically(to: setting.allFieldSettings["knockback"]!)
        self.entityData.encodeDynamically(to: setting.allFieldSettings["entityData"]!)
        self.entitySpawnRadius.encodeDynamically(to: setting.allFieldSettings["entitySpawnRadius"]!)
        self.defaultTileMetadatas.encodeDynamically(to: setting.allFieldSettings["defaultTileMetadatas"]!)
        self.tileOrientationMeanings.encodeDynamically(to: setting.allFieldSettings["tileOrientationMeanings"]!)
        self.selectableTypes.encodeDynamically(to: setting.allFieldSettings["selectableTypes"]!)
    }
}
extension TurretComponent.HowToFire {
    static internal func decode(from setting: ComplexEnumSetting<TurretComponent.HowToFire>) -> TurretComponent.HowToFire {
        switch setting.selectedCase {
        case "consistent":
            return TurretComponent.HowToFire.consistent(
                projectileSpeed: setting.selectedCaseFieldSettings["projectileSpeed"]!.decodeDynamically(),
                delay: setting.selectedCaseFieldSettings["delay"]!.decodeDynamically()
            )
        case "burst":
            return TurretComponent.HowToFire.burst(
                projectileSpeed: setting.selectedCaseFieldSettings["projectileSpeed"]!.decodeDynamically(),
                delayBetweenBursts: setting.selectedCaseFieldSettings["delayBetweenBursts"]!.decodeDynamically(),
                numShotsInBurst: setting.selectedCaseFieldSettings["numShotsInBurst"]!.decodeDynamically(),
                delayInBurst: setting.selectedCaseFieldSettings["delayInBurst"]!.decodeDynamically()
            )
        case "continuous":
            return TurretComponent.HowToFire.continuous
        default:
            fatalError("Can't decode case with name because it doesn't exist: \(setting.selectedCase)")
        }
    }

    internal func encode(to setting: ComplexEnumSetting<TurretComponent.HowToFire>) {
        switch self {
        case .consistent(let projectileSpeed,let delay):
            projectileSpeed.encodeDynamically(to: setting.selectedCaseFieldSettings["projectileSpeed"]!)
            delay.encodeDynamically(to: setting.selectedCaseFieldSettings["delay"]!)
        case .burst(let projectileSpeed,let delayBetweenBursts,let numShotsInBurst,let delayInBurst):
            projectileSpeed.encodeDynamically(to: setting.selectedCaseFieldSettings["projectileSpeed"]!)
            delayBetweenBursts.encodeDynamically(to: setting.selectedCaseFieldSettings["delayBetweenBursts"]!)
            numShotsInBurst.encodeDynamically(to: setting.selectedCaseFieldSettings["numShotsInBurst"]!)
            delayInBurst.encodeDynamically(to: setting.selectedCaseFieldSettings["delayInBurst"]!)
        case .continuous:
            break
        }
    }
}
extension TurretComponent.RotationPattern {
    static internal func decode(from setting: ComplexEnumSetting<TurretComponent.RotationPattern>) -> TurretComponent.RotationPattern {
        switch setting.selectedCase {
        case "neverRotate":
            return TurretComponent.RotationPattern.neverRotate
        case "rotateAtSpeed":
            return TurretComponent.RotationPattern.rotateAtSpeed(
                speed: setting.selectedCaseFieldSettings["speed"]!.decodeDynamically()
            )
        case "rotateInstantly":
            return TurretComponent.RotationPattern.rotateInstantly
        default:
            fatalError("Can't decode case with name because it doesn't exist: \(setting.selectedCase)")
        }
    }

    internal func encode(to setting: ComplexEnumSetting<TurretComponent.RotationPattern>) {
        switch self {
        case .neverRotate:
            break
        case .rotateAtSpeed(let speed):
            speed.encodeDynamically(to: setting.selectedCaseFieldSettings["speed"]!)
        case .rotateInstantly:
            break
        }
    }
}
