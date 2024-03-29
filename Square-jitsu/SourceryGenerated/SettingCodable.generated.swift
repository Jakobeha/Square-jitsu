// Generated using Sourcery 0.18.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// Modified from https://raw.githubusercontent.com/krzysztofzablocki/Sourcery/master/Templates/Templates/AutoCodable.swifttemplate
import SpriteKit
extension AINinjaComponent {
    internal init(from setting: StructSetting<AINinjaComponent>) {
        self.init(
            incomingTargetDistanceBeforeFirstJump: setting.usedFieldSettings["incomingTargetDistanceBeforeFirstJump"]!.decodeDynamically(),
            firstJumpAngle: setting.usedFieldSettings["firstJumpAngle"]!.decodeDynamically(),
            distanceBeforeConsecutiveJumps: setting.usedFieldSettings["distanceBeforeConsecutiveJumps"]!.decodeDynamically(),
            distanceBeforeTargetLost: setting.usedFieldSettings["distanceBeforeTargetLost"]!.decodeDynamically(),
            minSpeedToNotWantStateChange: setting.usedFieldSettings["minSpeedToNotWantStateChange"]!.decodeDynamically(),
            minAngularSpeedToNotWantStateChange: setting.usedFieldSettings["minAngularSpeedToNotWantStateChange"]!.decodeDynamically(),
            targetTypes: setting.usedFieldSettings["targetTypes"]!.decodeDynamically()
        )
    }

    static internal func decode(from setting: StructSetting<AINinjaComponent>) -> AINinjaComponent {
        self.init(
            incomingTargetDistanceBeforeFirstJump: setting.usedFieldSettings["incomingTargetDistanceBeforeFirstJump"]!.decodeDynamically(),
            firstJumpAngle: setting.usedFieldSettings["firstJumpAngle"]!.decodeDynamically(),
            distanceBeforeConsecutiveJumps: setting.usedFieldSettings["distanceBeforeConsecutiveJumps"]!.decodeDynamically(),
            distanceBeforeTargetLost: setting.usedFieldSettings["distanceBeforeTargetLost"]!.decodeDynamically(),
            minSpeedToNotWantStateChange: setting.usedFieldSettings["minSpeedToNotWantStateChange"]!.decodeDynamically(),
            minAngularSpeedToNotWantStateChange: setting.usedFieldSettings["minAngularSpeedToNotWantStateChange"]!.decodeDynamically(),
            targetTypes: setting.usedFieldSettings["targetTypes"]!.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<AINinjaComponent>) {
        self.incomingTargetDistanceBeforeFirstJump.encodeDynamically(to: setting.allFieldSettings["incomingTargetDistanceBeforeFirstJump"]!)
        self.firstJumpAngle.encodeDynamically(to: setting.allFieldSettings["firstJumpAngle"]!)
        self.distanceBeforeConsecutiveJumps.encodeDynamically(to: setting.allFieldSettings["distanceBeforeConsecutiveJumps"]!)
        self.distanceBeforeTargetLost.encodeDynamically(to: setting.allFieldSettings["distanceBeforeTargetLost"]!)
        self.minSpeedToNotWantStateChange.encodeDynamically(to: setting.allFieldSettings["minSpeedToNotWantStateChange"]!)
        self.minAngularSpeedToNotWantStateChange.encodeDynamically(to: setting.allFieldSettings["minAngularSpeedToNotWantStateChange"]!)
        self.targetTypes.encodeDynamically(to: setting.allFieldSettings["targetTypes"]!)
    }
}
extension Acceleration3Component {
    internal init(from setting: StructSetting<Acceleration3Component>) {
        self.init(
            jerk: setting.usedFieldSettings["jerk"]!.decodeDynamically()
        )
    }

    static internal func decode(from setting: StructSetting<Acceleration3Component>) -> Acceleration3Component {
        self.init(
            jerk: setting.usedFieldSettings["jerk"]!.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<Acceleration3Component>) {
        self.jerk.encodeDynamically(to: setting.allFieldSettings["jerk"]!)
    }
}
extension AccelerationComponent {
    internal init(from setting: StructSetting<AccelerationComponent>) {
        self.init(
            acceleration: setting.usedFieldSettings["acceleration"]!.decodeDynamically()
        )
    }

    static internal func decode(from setting: StructSetting<AccelerationComponent>) -> AccelerationComponent {
        self.init(
            acceleration: setting.usedFieldSettings["acceleration"]!.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<AccelerationComponent>) {
        self.acceleration.encodeDynamically(to: setting.allFieldSettings["acceleration"]!)
    }
}
extension AnimatedByLifetimeEntityViewTemplate {
    internal convenience init(from setting: StructSetting<AnimatedByLifetimeEntityViewTemplate>) {
        self.init(
            textureBase: setting.usedFieldSettings["textureBase"]!.decodeDynamically()
        )
    }

    static internal func decode(from setting: StructSetting<AnimatedByLifetimeEntityViewTemplate>) -> AnimatedByLifetimeEntityViewTemplate {
        self.init(
            textureBase: setting.usedFieldSettings["textureBase"]!.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<AnimatedByLifetimeEntityViewTemplate>) {
        self.textureBase.encodeDynamically(to: setting.allFieldSettings["textureBase"]!)
    }
}
extension AnimatedOnDeathEntityViewTemplate {
    internal convenience init(from setting: StructSetting<AnimatedOnDeathEntityViewTemplate>) {
        self.init(
            dyingTextureBase: setting.usedFieldSettings["dyingTextureBase"]!.decodeDynamically(),
            duration: setting.usedFieldSettings["duration"]!.decodeDynamically(),
            base: setting.usedFieldSettings["base"]!.decodeDynamically()
        )
    }

    static internal func decode(from setting: StructSetting<AnimatedOnDeathEntityViewTemplate>) -> AnimatedOnDeathEntityViewTemplate {
        self.init(
            dyingTextureBase: setting.usedFieldSettings["dyingTextureBase"]!.decodeDynamically(),
            duration: setting.usedFieldSettings["duration"]!.decodeDynamically(),
            base: setting.usedFieldSettings["base"]!.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<AnimatedOnDeathEntityViewTemplate>) {
        self.dyingTextureBase.encodeDynamically(to: setting.allFieldSettings["dyingTextureBase"]!)
        self.duration.encodeDynamically(to: setting.allFieldSettings["duration"]!)
        self.base.encodeDynamically(to: setting.allFieldSettings["base"]!)
    }
}
extension CollectorComponent {
    internal init(from setting: StructSetting<CollectorComponent>) {
        self.init(
        )
    }

    static internal func decode(from setting: StructSetting<CollectorComponent>) -> CollectorComponent {
        self.init(
        )
    }

    internal func encode(to setting: StructSetting<CollectorComponent>) {
    }
}
extension CollisionComponent {
    internal init(from setting: StructSetting<CollisionComponent>) {
        self.init(
        )
    }

    static internal func decode(from setting: StructSetting<CollisionComponent>) -> CollisionComponent {
        self.init(
        )
    }

    internal func encode(to setting: StructSetting<CollisionComponent>) {
    }
}
extension ColorTileViewTemplate {
    internal convenience init(from setting: StructSetting<ColorTileViewTemplate>) {
        self.init(
            color: setting.usedFieldSettings["color"]!.decodeDynamically()
        )
    }

    static internal func decode(from setting: StructSetting<ColorTileViewTemplate>) -> ColorTileViewTemplate {
        self.init(
            color: setting.usedFieldSettings["color"]!.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<ColorTileViewTemplate>) {
        self.color.encodeDynamically(to: setting.allFieldSettings["color"]!)
    }
}
extension ContinuouslyAnimatedTileViewTemplate {
    internal convenience init(from setting: StructSetting<ContinuouslyAnimatedTileViewTemplate>) {
        self.init(
            textureBase: setting.usedFieldSettings["textureBase"]!.decodeDynamically(),
            totalDuration: setting.usedFieldSettings["totalDuration"]!.decodeDynamically()
        )
    }

    static internal func decode(from setting: StructSetting<ContinuouslyAnimatedTileViewTemplate>) -> ContinuouslyAnimatedTileViewTemplate {
        self.init(
            textureBase: setting.usedFieldSettings["textureBase"]!.decodeDynamically(),
            totalDuration: setting.usedFieldSettings["totalDuration"]!.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<ContinuouslyAnimatedTileViewTemplate>) {
        self.textureBase.encodeDynamically(to: setting.allFieldSettings["textureBase"]!)
        self.totalDuration.encodeDynamically(to: setting.allFieldSettings["totalDuration"]!)
    }
}
extension CornerFacingTileViewTemplate {
    internal convenience init(from setting: StructSetting<CornerFacingTileViewTemplate>) {
        self.init(
            textureBase: setting.usedFieldSettings["textureBase"]!.decodeDynamically()
        )
    }

    static internal func decode(from setting: StructSetting<CornerFacingTileViewTemplate>) -> CornerFacingTileViewTemplate {
        self.init(
            textureBase: setting.usedFieldSettings["textureBase"]!.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<CornerFacingTileViewTemplate>) {
        self.textureBase.encodeDynamically(to: setting.allFieldSettings["textureBase"]!)
    }
}
extension CreateOnCollideComponent {
    internal init(from setting: StructSetting<CreateOnCollideComponent>) {
        self.init(
            createdType: setting.usedFieldSettings["createdType"]!.decodeDynamically()
        )
    }

    static internal func decode(from setting: StructSetting<CreateOnCollideComponent>) -> CreateOnCollideComponent {
        self.init(
            createdType: setting.usedFieldSettings["createdType"]!.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<CreateOnCollideComponent>) {
        self.createdType.encodeDynamically(to: setting.allFieldSettings["createdType"]!)
    }
}
extension CreateOnDestroyComponent {
    internal init(from setting: StructSetting<CreateOnDestroyComponent>) {
        self.init(
            createdType: setting.usedFieldSettings["createdType"]!.decodeDynamically()
        )
    }

    static internal func decode(from setting: StructSetting<CreateOnDestroyComponent>) -> CreateOnDestroyComponent {
        self.init(
            createdType: setting.usedFieldSettings["createdType"]!.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<CreateOnDestroyComponent>) {
        self.createdType.encodeDynamically(to: setting.allFieldSettings["createdType"]!)
    }
}
extension DestroyAfterLifetimeComponent {
    internal init(from setting: StructSetting<DestroyAfterLifetimeComponent>) {
        self.init(
            maxLifetime: setting.usedFieldSettings["maxLifetime"]!.decodeDynamically()
        )
    }

    static internal func decode(from setting: StructSetting<DestroyAfterLifetimeComponent>) -> DestroyAfterLifetimeComponent {
        self.init(
            maxLifetime: setting.usedFieldSettings["maxLifetime"]!.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<DestroyAfterLifetimeComponent>) {
        self.maxLifetime.encodeDynamically(to: setting.allFieldSettings["maxLifetime"]!)
    }
}
extension DestroyOnCollideComponent {
    internal init(from setting: StructSetting<DestroyOnCollideComponent>) {
        self.init(
            destroyOnEntityCollision: setting.usedFieldSettings["destroyOnEntityCollision"]!.decodeDynamically(),
            destroyOnSolidCollision: setting.usedFieldSettings["destroyOnSolidCollision"]!.decodeDynamically(),
            ignoredTypes: setting.usedFieldSettings["ignoredTypes"]!.decodeDynamically()
        )
    }

    static internal func decode(from setting: StructSetting<DestroyOnCollideComponent>) -> DestroyOnCollideComponent {
        self.init(
            destroyOnEntityCollision: setting.usedFieldSettings["destroyOnEntityCollision"]!.decodeDynamically(),
            destroyOnSolidCollision: setting.usedFieldSettings["destroyOnSolidCollision"]!.decodeDynamically(),
            ignoredTypes: setting.usedFieldSettings["ignoredTypes"]!.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<DestroyOnCollideComponent>) {
        self.destroyOnEntityCollision.encodeDynamically(to: setting.allFieldSettings["destroyOnEntityCollision"]!)
        self.destroyOnSolidCollision.encodeDynamically(to: setting.allFieldSettings["destroyOnSolidCollision"]!)
        self.ignoredTypes.encodeDynamically(to: setting.allFieldSettings["ignoredTypes"]!)
    }
}
extension DestructibleTileViewTemplate {
    internal convenience init(from setting: StructSetting<DestructibleTileViewTemplate>) {
        self.init(
            destructionTexture: setting.usedFieldSettings["destructionTexture"]!.decodeDynamically(),
            base: setting.usedFieldSettings["base"]?.decodeDynamically()
        )
    }

    static internal func decode(from setting: StructSetting<DestructibleTileViewTemplate>) -> DestructibleTileViewTemplate {
        self.init(
            destructionTexture: setting.usedFieldSettings["destructionTexture"]!.decodeDynamically(),
            base: setting.usedFieldSettings["base"]?.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<DestructibleTileViewTemplate>) {
        self.destructionTexture.encodeDynamically(to: setting.allFieldSettings["destructionTexture"]!)
        self.base?.encodeDynamically(to: setting.allFieldSettings["base"]!)
    }
}
extension Diamond4TileViewTemplate {
    internal convenience init(from setting: StructSetting<Diamond4TileViewTemplate>) {
        self.init(
            textureBase: setting.usedFieldSettings["textureBase"]!.decodeDynamically(),
            adjoiningTypes: setting.usedFieldSettings["adjoiningTypes"]!.decodeDynamically(),
            semiAdjoiningTypes1: setting.usedFieldSettings["semiAdjoiningTypes1"]!.decodeDynamically(),
            semiAdjoiningTypes2: setting.usedFieldSettings["semiAdjoiningTypes2"]!.decodeDynamically()
        )
    }

    static internal func decode(from setting: StructSetting<Diamond4TileViewTemplate>) -> Diamond4TileViewTemplate {
        self.init(
            textureBase: setting.usedFieldSettings["textureBase"]!.decodeDynamically(),
            adjoiningTypes: setting.usedFieldSettings["adjoiningTypes"]!.decodeDynamically(),
            semiAdjoiningTypes1: setting.usedFieldSettings["semiAdjoiningTypes1"]!.decodeDynamically(),
            semiAdjoiningTypes2: setting.usedFieldSettings["semiAdjoiningTypes2"]!.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<Diamond4TileViewTemplate>) {
        self.textureBase.encodeDynamically(to: setting.allFieldSettings["textureBase"]!)
        self.adjoiningTypes.encodeDynamically(to: setting.allFieldSettings["adjoiningTypes"]!)
        self.semiAdjoiningTypes1.encodeDynamically(to: setting.allFieldSettings["semiAdjoiningTypes1"]!)
        self.semiAdjoiningTypes2.encodeDynamically(to: setting.allFieldSettings["semiAdjoiningTypes2"]!)
    }
}
extension DontClipComponent {
    internal init(from setting: StructSetting<DontClipComponent>) {
        self.init(
        )
    }

    static internal func decode(from setting: StructSetting<DontClipComponent>) -> DontClipComponent {
        self.init(
        )
    }

    internal func encode(to setting: StructSetting<DontClipComponent>) {
    }
}
extension Edge4TileViewTemplate {
    internal convenience init(from setting: StructSetting<Edge4TileViewTemplate>) {
        self.init(
            textureBase: setting.usedFieldSettings["textureBase"]!.decodeDynamically()
        )
    }

    static internal func decode(from setting: StructSetting<Edge4TileViewTemplate>) -> Edge4TileViewTemplate {
        self.init(
            textureBase: setting.usedFieldSettings["textureBase"]!.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<Edge4TileViewTemplate>) {
        self.textureBase.encodeDynamically(to: setting.allFieldSettings["textureBase"]!)
    }
}
extension Entity.Components {
    internal init(from setting: StructSetting<Entity.Components>) {
        self.init(
            locC: setting.usedFieldSettings["locC"]?.decodeDynamically(),
            lilC: setting.usedFieldSettings["lilC"]?.decodeDynamically(),
            larC: setting.usedFieldSettings["larC"]?.decodeDynamically(),
            dalC: setting.usedFieldSettings["dalC"]?.decodeDynamically(),
            codC: setting.usedFieldSettings["codC"]?.decodeDynamically(),
            dynC: setting.usedFieldSettings["dynC"]?.decodeDynamically(),
            accC: setting.usedFieldSettings["accC"]?.decodeDynamically(),
            ac3C: setting.usedFieldSettings["ac3C"]?.decodeDynamically(),
            imfC: setting.usedFieldSettings["imfC"]?.decodeDynamically(),
            colC: setting.usedFieldSettings["colC"]?.decodeDynamically(),
            ntlC: setting.usedFieldSettings["ntlC"]?.decodeDynamically(),
            docC: setting.usedFieldSettings["docC"]?.decodeDynamically(),
            cocC: setting.usedFieldSettings["cocC"]?.decodeDynamically(),
            dciC: setting.usedFieldSettings["dciC"]?.decodeDynamically(),
            ricC: setting.usedFieldSettings["ricC"]?.decodeDynamically(),
            matC: setting.usedFieldSettings["matC"]?.decodeDynamically(),
            griC: setting.usedFieldSettings["griC"]?.decodeDynamically(),
            graC: setting.usedFieldSettings["graC"]?.decodeDynamically(),
            helC: setting.usedFieldSettings["helC"]?.decodeDynamically(),
            toxC: setting.usedFieldSettings["toxC"]?.decodeDynamically(),
            turC: setting.usedFieldSettings["turC"]?.decodeDynamically(),
            ctrC: setting.usedFieldSettings["ctrC"]?.decodeDynamically(),
            nijC: setting.usedFieldSettings["nijC"]?.decodeDynamically(),
            anjC: setting.usedFieldSettings["anjC"]?.decodeDynamically()
        )
    }

    static internal func decode(from setting: StructSetting<Entity.Components>) -> Entity.Components {
        self.init(
            locC: setting.usedFieldSettings["locC"]?.decodeDynamically(),
            lilC: setting.usedFieldSettings["lilC"]?.decodeDynamically(),
            larC: setting.usedFieldSettings["larC"]?.decodeDynamically(),
            dalC: setting.usedFieldSettings["dalC"]?.decodeDynamically(),
            codC: setting.usedFieldSettings["codC"]?.decodeDynamically(),
            dynC: setting.usedFieldSettings["dynC"]?.decodeDynamically(),
            accC: setting.usedFieldSettings["accC"]?.decodeDynamically(),
            ac3C: setting.usedFieldSettings["ac3C"]?.decodeDynamically(),
            imfC: setting.usedFieldSettings["imfC"]?.decodeDynamically(),
            colC: setting.usedFieldSettings["colC"]?.decodeDynamically(),
            ntlC: setting.usedFieldSettings["ntlC"]?.decodeDynamically(),
            docC: setting.usedFieldSettings["docC"]?.decodeDynamically(),
            cocC: setting.usedFieldSettings["cocC"]?.decodeDynamically(),
            dciC: setting.usedFieldSettings["dciC"]?.decodeDynamically(),
            ricC: setting.usedFieldSettings["ricC"]?.decodeDynamically(),
            matC: setting.usedFieldSettings["matC"]?.decodeDynamically(),
            griC: setting.usedFieldSettings["griC"]?.decodeDynamically(),
            graC: setting.usedFieldSettings["graC"]?.decodeDynamically(),
            helC: setting.usedFieldSettings["helC"]?.decodeDynamically(),
            toxC: setting.usedFieldSettings["toxC"]?.decodeDynamically(),
            turC: setting.usedFieldSettings["turC"]?.decodeDynamically(),
            ctrC: setting.usedFieldSettings["ctrC"]?.decodeDynamically(),
            nijC: setting.usedFieldSettings["nijC"]?.decodeDynamically(),
            anjC: setting.usedFieldSettings["anjC"]?.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<Entity.Components>) {
        self.locC?.encodeDynamically(to: setting.allFieldSettings["locC"]!)
        self.lilC?.encodeDynamically(to: setting.allFieldSettings["lilC"]!)
        self.larC?.encodeDynamically(to: setting.allFieldSettings["larC"]!)
        self.dalC?.encodeDynamically(to: setting.allFieldSettings["dalC"]!)
        self.codC?.encodeDynamically(to: setting.allFieldSettings["codC"]!)
        self.dynC?.encodeDynamically(to: setting.allFieldSettings["dynC"]!)
        self.accC?.encodeDynamically(to: setting.allFieldSettings["accC"]!)
        self.ac3C?.encodeDynamically(to: setting.allFieldSettings["ac3C"]!)
        self.imfC?.encodeDynamically(to: setting.allFieldSettings["imfC"]!)
        self.colC?.encodeDynamically(to: setting.allFieldSettings["colC"]!)
        self.ntlC?.encodeDynamically(to: setting.allFieldSettings["ntlC"]!)
        self.docC?.encodeDynamically(to: setting.allFieldSettings["docC"]!)
        self.cocC?.encodeDynamically(to: setting.allFieldSettings["cocC"]!)
        self.dciC?.encodeDynamically(to: setting.allFieldSettings["dciC"]!)
        self.ricC?.encodeDynamically(to: setting.allFieldSettings["ricC"]!)
        self.matC?.encodeDynamically(to: setting.allFieldSettings["matC"]!)
        self.griC?.encodeDynamically(to: setting.allFieldSettings["griC"]!)
        self.graC?.encodeDynamically(to: setting.allFieldSettings["graC"]!)
        self.helC?.encodeDynamically(to: setting.allFieldSettings["helC"]!)
        self.toxC?.encodeDynamically(to: setting.allFieldSettings["toxC"]!)
        self.turC?.encodeDynamically(to: setting.allFieldSettings["turC"]!)
        self.ctrC?.encodeDynamically(to: setting.allFieldSettings["ctrC"]!)
        self.nijC?.encodeDynamically(to: setting.allFieldSettings["nijC"]!)
        self.anjC?.encodeDynamically(to: setting.allFieldSettings["anjC"]!)
    }
}
extension FadeOnDeathEntityViewTemplate {
    internal convenience init(from setting: StructSetting<FadeOnDeathEntityViewTemplate>) {
        self.init(
            duration: setting.usedFieldSettings["duration"]!.decodeDynamically(),
            base: setting.usedFieldSettings["base"]!.decodeDynamically()
        )
    }

    static internal func decode(from setting: StructSetting<FadeOnDeathEntityViewTemplate>) -> FadeOnDeathEntityViewTemplate {
        self.init(
            duration: setting.usedFieldSettings["duration"]!.decodeDynamically(),
            base: setting.usedFieldSettings["base"]!.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<FadeOnDeathEntityViewTemplate>) {
        self.duration.encodeDynamically(to: setting.allFieldSettings["duration"]!)
        self.base.encodeDynamically(to: setting.allFieldSettings["base"]!)
    }
}
extension FadeOnRemoveTileViewTemplate {
    internal convenience init(from setting: StructSetting<FadeOnRemoveTileViewTemplate>) {
        self.init(
            duration: setting.usedFieldSettings["duration"]!.decodeDynamically(),
            base: setting.usedFieldSettings["base"]?.decodeDynamically()
        )
    }

    static internal func decode(from setting: StructSetting<FadeOnRemoveTileViewTemplate>) -> FadeOnRemoveTileViewTemplate {
        self.init(
            duration: setting.usedFieldSettings["duration"]!.decodeDynamically(),
            base: setting.usedFieldSettings["base"]?.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<FadeOnRemoveTileViewTemplate>) {
        self.duration.encodeDynamically(to: setting.allFieldSettings["duration"]!)
        self.base?.encodeDynamically(to: setting.allFieldSettings["base"]!)
    }
}
extension FillerTileViewTemplate {
    internal convenience init(from setting: StructSetting<FillerTileViewTemplate>) {
        self.init(
            texture: setting.usedFieldSettings["texture"]!.decodeDynamically()
        )
    }

    static internal func decode(from setting: StructSetting<FillerTileViewTemplate>) -> FillerTileViewTemplate {
        self.init(
            texture: setting.usedFieldSettings["texture"]!.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<FillerTileViewTemplate>) {
        self.texture.encodeDynamically(to: setting.allFieldSettings["texture"]!)
    }
}
extension Free4TileViewTemplate {
    internal convenience init(from setting: StructSetting<Free4TileViewTemplate>) {
        self.init(
            textureBase: setting.usedFieldSettings["textureBase"]!.decodeDynamically()
        )
    }

    static internal func decode(from setting: StructSetting<Free4TileViewTemplate>) -> Free4TileViewTemplate {
        self.init(
            textureBase: setting.usedFieldSettings["textureBase"]!.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<Free4TileViewTemplate>) {
        self.textureBase.encodeDynamically(to: setting.allFieldSettings["textureBase"]!)
    }
}
extension FreeCornerFacingTileViewTemplate {
    internal convenience init(from setting: StructSetting<FreeCornerFacingTileViewTemplate>) {
        self.init(
            textureBase: setting.usedFieldSettings["textureBase"]!.decodeDynamically()
        )
    }

    static internal func decode(from setting: StructSetting<FreeCornerFacingTileViewTemplate>) -> FreeCornerFacingTileViewTemplate {
        self.init(
            textureBase: setting.usedFieldSettings["textureBase"]!.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<FreeCornerFacingTileViewTemplate>) {
        self.textureBase.encodeDynamically(to: setting.allFieldSettings["textureBase"]!)
    }
}
extension FreeOptionalSideFacingTileViewTemplate {
    internal convenience init(from setting: StructSetting<FreeOptionalSideFacingTileViewTemplate>) {
        self.init(
            textureBase: setting.usedFieldSettings["textureBase"]!.decodeDynamically()
        )
    }

    static internal func decode(from setting: StructSetting<FreeOptionalSideFacingTileViewTemplate>) -> FreeOptionalSideFacingTileViewTemplate {
        self.init(
            textureBase: setting.usedFieldSettings["textureBase"]!.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<FreeOptionalSideFacingTileViewTemplate>) {
        self.textureBase.encodeDynamically(to: setting.allFieldSettings["textureBase"]!)
    }
}
extension FreeSideFacingTileViewTemplate {
    internal convenience init(from setting: StructSetting<FreeSideFacingTileViewTemplate>) {
        self.init(
            textureBase: setting.usedFieldSettings["textureBase"]!.decodeDynamically()
        )
    }

    static internal func decode(from setting: StructSetting<FreeSideFacingTileViewTemplate>) -> FreeSideFacingTileViewTemplate {
        self.init(
            textureBase: setting.usedFieldSettings["textureBase"]!.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<FreeSideFacingTileViewTemplate>) {
        self.textureBase.encodeDynamically(to: setting.allFieldSettings["textureBase"]!)
    }
}
extension GlossyTileViewTemplate {
    internal convenience init(from setting: StructSetting<GlossyTileViewTemplate>) {
        self.init(
            explicitGlossTemplate: setting.usedFieldSettings["explicitGlossTemplate"]?.decodeDynamically(),
            base: setting.usedFieldSettings["base"]?.decodeDynamically()
        )
    }

    static internal func decode(from setting: StructSetting<GlossyTileViewTemplate>) -> GlossyTileViewTemplate {
        self.init(
            explicitGlossTemplate: setting.usedFieldSettings["explicitGlossTemplate"]?.decodeDynamically(),
            base: setting.usedFieldSettings["base"]?.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<GlossyTileViewTemplate>) {
        self.explicitGlossTemplate?.encodeDynamically(to: setting.allFieldSettings["explicitGlossTemplate"]!)
        self.base?.encodeDynamically(to: setting.allFieldSettings["base"]!)
    }
}
extension GrabbableComponent {
    internal init(from setting: StructSetting<GrabbableComponent>) {
        self.init(
            thrownSpeedMultiplier: setting.usedFieldSettings["thrownSpeedMultiplier"]!.decodeDynamically()
        )
    }

    static internal func decode(from setting: StructSetting<GrabbableComponent>) -> GrabbableComponent {
        self.init(
            thrownSpeedMultiplier: setting.usedFieldSettings["thrownSpeedMultiplier"]!.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<GrabbableComponent>) {
        self.thrownSpeedMultiplier.encodeDynamically(to: setting.allFieldSettings["thrownSpeedMultiplier"]!)
    }
}
extension GrabbingComponent {
    internal init(from setting: StructSetting<GrabbingComponent>) {
        self.init(
            grabbableTypes: setting.usedFieldSettings["grabbableTypes"]!.decodeDynamically(),
            grabOffset: setting.usedFieldSettings["grabOffset"]!.decodeDynamically(),
            throwSpeed: setting.usedFieldSettings["throwSpeed"]!.decodeDynamically(),
            throwAngularSpeed: setting.usedFieldSettings["throwAngularSpeed"]!.decodeDynamically()
        )
    }

    static internal func decode(from setting: StructSetting<GrabbingComponent>) -> GrabbingComponent {
        self.init(
            grabbableTypes: setting.usedFieldSettings["grabbableTypes"]!.decodeDynamically(),
            grabOffset: setting.usedFieldSettings["grabOffset"]!.decodeDynamically(),
            throwSpeed: setting.usedFieldSettings["throwSpeed"]!.decodeDynamically(),
            throwAngularSpeed: setting.usedFieldSettings["throwAngularSpeed"]!.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<GrabbingComponent>) {
        self.grabbableTypes.encodeDynamically(to: setting.allFieldSettings["grabbableTypes"]!)
        self.grabOffset.encodeDynamically(to: setting.allFieldSettings["grabOffset"]!)
        self.throwSpeed.encodeDynamically(to: setting.allFieldSettings["throwSpeed"]!)
        self.throwAngularSpeed.encodeDynamically(to: setting.allFieldSettings["throwAngularSpeed"]!)
    }
}
extension HealthComponent {
    internal init(from setting: StructSetting<HealthComponent>) {
        self.init(
            maxHealth: setting.usedFieldSettings["maxHealth"]!.decodeDynamically()
        )
    }

    static internal func decode(from setting: StructSetting<HealthComponent>) -> HealthComponent {
        self.init(
            maxHealth: setting.usedFieldSettings["maxHealth"]!.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<HealthComponent>) {
        self.maxHealth.encodeDynamically(to: setting.allFieldSettings["maxHealth"]!)
    }
}
extension ImageMetadata {
    internal init(from setting: StructSetting<ImageMetadata>) {
        self.init(
            imageTexture: setting.usedFieldSettings["imageTexture"]!.decodeDynamically(),
            sizeInTiles: setting.usedFieldSettings["sizeInTiles"]!.decodeDynamically()
        )
    }

    static internal func decode(from setting: StructSetting<ImageMetadata>) -> ImageMetadata {
        self.init(
            imageTexture: setting.usedFieldSettings["imageTexture"]!.decodeDynamically(),
            sizeInTiles: setting.usedFieldSettings["sizeInTiles"]!.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<ImageMetadata>) {
        self.imageTexture.encodeDynamically(to: setting.allFieldSettings["imageTexture"]!)
        self.sizeInTiles.encodeDynamically(to: setting.allFieldSettings["sizeInTiles"]!)
    }
}
extension ImplicitForcesComponent {
    internal init(from setting: StructSetting<ImplicitForcesComponent>) {
        self.init(
            gravity: setting.usedFieldSettings["gravity"]!.decodeDynamically(),
            minSpeedOnIce: setting.usedFieldSettings["minSpeedOnIce"]!.decodeDynamically(),
            solidFriction: setting.usedFieldSettings["solidFriction"]!.decodeDynamically(),
            aerialAngularFriction: setting.usedFieldSettings["aerialAngularFriction"]!.decodeDynamically()
        )
    }

    static internal func decode(from setting: StructSetting<ImplicitForcesComponent>) -> ImplicitForcesComponent {
        self.init(
            gravity: setting.usedFieldSettings["gravity"]!.decodeDynamically(),
            minSpeedOnIce: setting.usedFieldSettings["minSpeedOnIce"]!.decodeDynamically(),
            solidFriction: setting.usedFieldSettings["solidFriction"]!.decodeDynamically(),
            aerialAngularFriction: setting.usedFieldSettings["aerialAngularFriction"]!.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<ImplicitForcesComponent>) {
        self.gravity.encodeDynamically(to: setting.allFieldSettings["gravity"]!)
        self.minSpeedOnIce.encodeDynamically(to: setting.allFieldSettings["minSpeedOnIce"]!)
        self.solidFriction.encodeDynamically(to: setting.allFieldSettings["solidFriction"]!)
        self.aerialAngularFriction.encodeDynamically(to: setting.allFieldSettings["aerialAngularFriction"]!)
    }
}
extension IndicatedInEditorTileViewTemplate {
    internal convenience init(from setting: StructSetting<IndicatedInEditorTileViewTemplate>) {
        self.init(
            editorIndicator: setting.usedFieldSettings["editorIndicator"]!.decodeDynamically(),
            base: setting.usedFieldSettings["base"]?.decodeDynamically()
        )
    }

    static internal func decode(from setting: StructSetting<IndicatedInEditorTileViewTemplate>) -> IndicatedInEditorTileViewTemplate {
        self.init(
            editorIndicator: setting.usedFieldSettings["editorIndicator"]!.decodeDynamically(),
            base: setting.usedFieldSettings["base"]?.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<IndicatedInEditorTileViewTemplate>) {
        self.editorIndicator.encodeDynamically(to: setting.allFieldSettings["editorIndicator"]!)
        self.base?.encodeDynamically(to: setting.allFieldSettings["base"]!)
    }
}
extension LaserEntityViewTemplate {
    internal convenience init(from setting: StructSetting<LaserEntityViewTemplate>) {
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
extension LineLocationComponent {
    internal init(from setting: StructSetting<LineLocationComponent>) {
        self.init(
            thickness: setting.usedFieldSettings["thickness"]!.decodeDynamically()
        )
    }

    static internal func decode(from setting: StructSetting<LineLocationComponent>) -> LineLocationComponent {
        self.init(
            thickness: setting.usedFieldSettings["thickness"]!.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<LineLocationComponent>) {
        self.thickness.encodeDynamically(to: setting.allFieldSettings["thickness"]!)
    }
}
extension LoadAroundComponent {
    internal init(from setting: StructSetting<LoadAroundComponent>) {
        self.init(
        )
    }

    static internal func decode(from setting: StructSetting<LoadAroundComponent>) -> LoadAroundComponent {
        self.init(
        )
    }

    internal func encode(to setting: StructSetting<LoadAroundComponent>) {
    }
}
extension LocationComponent {
    internal init(from setting: StructSetting<LocationComponent>) {
        self.init(
            radius: setting.usedFieldSettings["radius"]!.decodeDynamically()
        )
    }

    static internal func decode(from setting: StructSetting<LocationComponent>) -> LocationComponent {
        self.init(
            radius: setting.usedFieldSettings["radius"]!.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<LocationComponent>) {
        self.radius.encodeDynamically(to: setting.allFieldSettings["radius"]!)
    }
}
extension MacroButtonTileViewTemplate {
    internal convenience init(from setting: StructSetting<MacroButtonTileViewTemplate>) {
        self.init(
            foregroundTexture: setting.usedFieldSettings["foregroundTexture"]!.decodeDynamically()
        )
    }

    static internal func decode(from setting: StructSetting<MacroButtonTileViewTemplate>) -> MacroButtonTileViewTemplate {
        self.init(
            foregroundTexture: setting.usedFieldSettings["foregroundTexture"]!.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<MacroButtonTileViewTemplate>) {
        self.foregroundTexture.encodeDynamically(to: setting.allFieldSettings["foregroundTexture"]!)
    }
}
extension MacroImageTileViewTemplate {
    internal convenience init(from setting: StructSetting<MacroImageTileViewTemplate>) {
        self.init(
        )
    }

    static internal func decode(from setting: StructSetting<MacroImageTileViewTemplate>) -> MacroImageTileViewTemplate {
        self.init(
        )
    }

    internal func encode(to setting: StructSetting<MacroImageTileViewTemplate>) {
    }
}
extension MacroTileViewTemplate {
    internal convenience init(from setting: StructSetting<MacroTileViewTemplate>) {
        self.init(
            texture: setting.usedFieldSettings["texture"]!.decodeDynamically()
        )
    }

    static internal func decode(from setting: StructSetting<MacroTileViewTemplate>) -> MacroTileViewTemplate {
        self.init(
            texture: setting.usedFieldSettings["texture"]!.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<MacroTileViewTemplate>) {
        self.texture.encodeDynamically(to: setting.allFieldSettings["texture"]!)
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
extension NearTileComponent {
    internal init(from setting: StructSetting<NearTileComponent>) {
        self.init(
            nearRadiusExtra: setting.usedFieldSettings["nearRadiusExtra"]!.decodeDynamically()
        )
    }

    static internal func decode(from setting: StructSetting<NearTileComponent>) -> NearTileComponent {
        self.init(
            nearRadiusExtra: setting.usedFieldSettings["nearRadiusExtra"]!.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<NearTileComponent>) {
        self.nearRadiusExtra.encodeDynamically(to: setting.allFieldSettings["nearRadiusExtra"]!)
    }
}
extension NinjaComponent {
    internal init(from setting: StructSetting<NinjaComponent>) {
        self.init(
            jumpSpeed: setting.usedFieldSettings["jumpSpeed"]!.decodeDynamically(),
            jumpAngularSpeed: setting.usedFieldSettings["jumpAngularSpeed"]!.decodeDynamically(),
            minNumJumpsWithoutBackground: setting.usedFieldSettings["minNumJumpsWithoutBackground"]!.decodeDynamically()
        )
    }

    static internal func decode(from setting: StructSetting<NinjaComponent>) -> NinjaComponent {
        self.init(
            jumpSpeed: setting.usedFieldSettings["jumpSpeed"]!.decodeDynamically(),
            jumpAngularSpeed: setting.usedFieldSettings["jumpAngularSpeed"]!.decodeDynamically(),
            minNumJumpsWithoutBackground: setting.usedFieldSettings["minNumJumpsWithoutBackground"]!.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<NinjaComponent>) {
        self.jumpSpeed.encodeDynamically(to: setting.allFieldSettings["jumpSpeed"]!)
        self.jumpAngularSpeed.encodeDynamically(to: setting.allFieldSettings["jumpAngularSpeed"]!)
        self.minNumJumpsWithoutBackground.encodeDynamically(to: setting.allFieldSettings["minNumJumpsWithoutBackground"]!)
    }
}
extension OptionalSideFacingTileViewTemplate {
    internal convenience init(from setting: StructSetting<OptionalSideFacingTileViewTemplate>) {
        self.init(
            sideTexture: setting.usedFieldSettings["sideTexture"]!.decodeDynamically(),
            noneTexture: setting.usedFieldSettings["noneTexture"]!.decodeDynamically()
        )
    }

    static internal func decode(from setting: StructSetting<OptionalSideFacingTileViewTemplate>) -> OptionalSideFacingTileViewTemplate {
        self.init(
            sideTexture: setting.usedFieldSettings["sideTexture"]!.decodeDynamically(),
            noneTexture: setting.usedFieldSettings["noneTexture"]!.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<OptionalSideFacingTileViewTemplate>) {
        self.sideTexture.encodeDynamically(to: setting.allFieldSettings["sideTexture"]!)
        self.noneTexture.encodeDynamically(to: setting.allFieldSettings["noneTexture"]!)
    }
}
extension PersonEntityViewTemplate {
    internal convenience init(from setting: StructSetting<PersonEntityViewTemplate>) {
        self.init(
            textureBase: setting.usedFieldSettings["textureBase"]!.decodeDynamically()
        )
    }

    static internal func decode(from setting: StructSetting<PersonEntityViewTemplate>) -> PersonEntityViewTemplate {
        self.init(
            textureBase: setting.usedFieldSettings["textureBase"]!.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<PersonEntityViewTemplate>) {
        self.textureBase.encodeDynamically(to: setting.allFieldSettings["textureBase"]!)
    }
}
extension PortalMetadata {
    internal init(from setting: StructSetting<PortalMetadata>) {
        self.init(
            relativePathToDestination: setting.usedFieldSettings["relativePathToDestination"]!.decodeDynamically()
        )
    }

    static internal func decode(from setting: StructSetting<PortalMetadata>) -> PortalMetadata {
        self.init(
            relativePathToDestination: setting.usedFieldSettings["relativePathToDestination"]!.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<PortalMetadata>) {
        self.relativePathToDestination.encodeDynamically(to: setting.allFieldSettings["relativePathToDestination"]!)
    }
}
extension RicochetComponent {
    internal init(from setting: StructSetting<RicochetComponent>) {
        self.init(
            bounceMultiplier: setting.usedFieldSettings["bounceMultiplier"]!.decodeDynamically(),
            numBouncesBeforeDestroy: setting.usedFieldSettings["numBouncesBeforeDestroy"]!.decodeDynamically()
        )
    }

    static internal func decode(from setting: StructSetting<RicochetComponent>) -> RicochetComponent {
        self.init(
            bounceMultiplier: setting.usedFieldSettings["bounceMultiplier"]!.decodeDynamically(),
            numBouncesBeforeDestroy: setting.usedFieldSettings["numBouncesBeforeDestroy"]!.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<RicochetComponent>) {
        self.bounceMultiplier.encodeDynamically(to: setting.allFieldSettings["bounceMultiplier"]!)
        self.numBouncesBeforeDestroy.encodeDynamically(to: setting.allFieldSettings["numBouncesBeforeDestroy"]!)
    }
}
extension SideFacingTileViewTemplate {
    internal convenience init(from setting: StructSetting<SideFacingTileViewTemplate>) {
        self.init(
            texture: setting.usedFieldSettings["texture"]!.decodeDynamically()
        )
    }

    static internal func decode(from setting: StructSetting<SideFacingTileViewTemplate>) -> SideFacingTileViewTemplate {
        self.init(
            texture: setting.usedFieldSettings["texture"]!.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<SideFacingTileViewTemplate>) {
        self.texture.encodeDynamically(to: setting.allFieldSettings["texture"]!)
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
    internal convenience init(from setting: StructSetting<StaticEntityViewTemplate>) {
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
    internal convenience init(from setting: StructSetting<StaticTileViewTemplate>) {
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
extension TileMovementMetadata {
    internal init(from setting: StructSetting<TileMovementMetadata>) {
        self.init(
            offset: setting.usedFieldSettings["offset"]!.decodeDynamically(),
            repeatMode: setting.usedFieldSettings["repeatMode"]!.decodeDynamically()
        )
    }

    static internal func decode(from setting: StructSetting<TileMovementMetadata>) -> TileMovementMetadata {
        self.init(
            offset: setting.usedFieldSettings["offset"]!.decodeDynamically(),
            repeatMode: setting.usedFieldSettings["repeatMode"]!.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<TileMovementMetadata>) {
        self.offset.encodeDynamically(to: setting.allFieldSettings["offset"]!)
        self.repeatMode.encodeDynamically(to: setting.allFieldSettings["repeatMode"]!)
    }
}
extension ToxicComponent {
    internal init(from setting: StructSetting<ToxicComponent>) {
        self.init(
            damage: setting.usedFieldSettings["damage"]!.decodeDynamically(),
            safeTypes: setting.usedFieldSettings["safeTypes"]!.decodeDynamically(),
            affectsDestructibleTiles: setting.usedFieldSettings["affectsDestructibleTiles"]!.decodeDynamically()
        )
    }

    static internal func decode(from setting: StructSetting<ToxicComponent>) -> ToxicComponent {
        self.init(
            damage: setting.usedFieldSettings["damage"]!.decodeDynamically(),
            safeTypes: setting.usedFieldSettings["safeTypes"]!.decodeDynamically(),
            affectsDestructibleTiles: setting.usedFieldSettings["affectsDestructibleTiles"]!.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<ToxicComponent>) {
        self.damage.encodeDynamically(to: setting.allFieldSettings["damage"]!)
        self.safeTypes.encodeDynamically(to: setting.allFieldSettings["safeTypes"]!)
        self.affectsDestructibleTiles.encodeDynamically(to: setting.allFieldSettings["affectsDestructibleTiles"]!)
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
            delayWhenTargetFoundBeforeFire: setting.usedFieldSettings["delayWhenTargetFoundBeforeFire"]!.decodeDynamically(),
            spreadPattern: setting.usedFieldSettings["spreadPattern"]!.decodeDynamically()
        )
    }

    static internal func decode(from setting: StructSetting<TurretComponent>) -> TurretComponent {
        self.init(
            rotationPattern: setting.usedFieldSettings["rotationPattern"]!.decodeDynamically(),
            whoToTarget: setting.usedFieldSettings["whoToTarget"]!.decodeDynamically(),
            whenToFire: setting.usedFieldSettings["whenToFire"]!.decodeDynamically(),
            howToFire: setting.usedFieldSettings["howToFire"]!.decodeDynamically(),
            whatToFire: setting.usedFieldSettings["whatToFire"]!.decodeDynamically(),
            delayWhenTargetFoundBeforeFire: setting.usedFieldSettings["delayWhenTargetFoundBeforeFire"]!.decodeDynamically(),
            spreadPattern: setting.usedFieldSettings["spreadPattern"]!.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<TurretComponent>) {
        self.rotationPattern.encodeDynamically(to: setting.allFieldSettings["rotationPattern"]!)
        self.whoToTarget.encodeDynamically(to: setting.allFieldSettings["whoToTarget"]!)
        self.whenToFire.encodeDynamically(to: setting.allFieldSettings["whenToFire"]!)
        self.howToFire.encodeDynamically(to: setting.allFieldSettings["howToFire"]!)
        self.whatToFire.encodeDynamically(to: setting.allFieldSettings["whatToFire"]!)
        self.delayWhenTargetFoundBeforeFire.encodeDynamically(to: setting.allFieldSettings["delayWhenTargetFoundBeforeFire"]!)
        self.spreadPattern.encodeDynamically(to: setting.allFieldSettings["spreadPattern"]!)
    }
}
extension TurretEntityViewTemplate {
    internal convenience init(from setting: StructSetting<TurretEntityViewTemplate>) {
        self.init(
            maxChargingCircleRadius: setting.usedFieldSettings["maxChargingCircleRadius"]!.decodeDynamically(),
            minChargingCircleRadius: setting.usedFieldSettings["minChargingCircleRadius"]!.decodeDynamically(),
            chargingCircleOffset: setting.usedFieldSettings["chargingCircleOffset"]!.decodeDynamically(),
            chargingCircleColor: setting.usedFieldSettings["chargingCircleColor"]!.decodeDynamically(),
            base: setting.usedFieldSettings["base"]!.decodeDynamically()
        )
    }

    static internal func decode(from setting: StructSetting<TurretEntityViewTemplate>) -> TurretEntityViewTemplate {
        self.init(
            maxChargingCircleRadius: setting.usedFieldSettings["maxChargingCircleRadius"]!.decodeDynamically(),
            minChargingCircleRadius: setting.usedFieldSettings["minChargingCircleRadius"]!.decodeDynamically(),
            chargingCircleOffset: setting.usedFieldSettings["chargingCircleOffset"]!.decodeDynamically(),
            chargingCircleColor: setting.usedFieldSettings["chargingCircleColor"]!.decodeDynamically(),
            base: setting.usedFieldSettings["base"]!.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<TurretEntityViewTemplate>) {
        self.maxChargingCircleRadius.encodeDynamically(to: setting.allFieldSettings["maxChargingCircleRadius"]!)
        self.minChargingCircleRadius.encodeDynamically(to: setting.allFieldSettings["minChargingCircleRadius"]!)
        self.chargingCircleOffset.encodeDynamically(to: setting.allFieldSettings["chargingCircleOffset"]!)
        self.chargingCircleColor.encodeDynamically(to: setting.allFieldSettings["chargingCircleColor"]!)
        self.base.encodeDynamically(to: setting.allFieldSettings["base"]!)
    }
}
extension TurretMetadata {
    internal init(from setting: StructSetting<TurretMetadata>) {
        self.init(
            initialTurretDirectionRelativeToAnchor: setting.usedFieldSettings["initialTurretDirectionRelativeToAnchor"]!.decodeDynamically(),
            rotatesClockwise: setting.usedFieldSettings["rotatesClockwise"]?.decodeDynamically()
        )
    }

    static internal func decode(from setting: StructSetting<TurretMetadata>) -> TurretMetadata {
        self.init(
            initialTurretDirectionRelativeToAnchor: setting.usedFieldSettings["initialTurretDirectionRelativeToAnchor"]!.decodeDynamically(),
            rotatesClockwise: setting.usedFieldSettings["rotatesClockwise"]?.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<TurretMetadata>) {
        self.initialTurretDirectionRelativeToAnchor.encodeDynamically(to: setting.allFieldSettings["initialTurretDirectionRelativeToAnchor"]!)
        self.rotatesClockwise?.encodeDynamically(to: setting.allFieldSettings["rotatesClockwise"]!)
    }
}
extension TurretTileViewTemplate {
    internal convenience init(from setting: StructSetting<TurretTileViewTemplate>) {
        self.init(
            turretTexture: setting.usedFieldSettings["turretTexture"]!.decodeDynamically(),
            base: setting.usedFieldSettings["base"]?.decodeDynamically()
        )
    }

    static internal func decode(from setting: StructSetting<TurretTileViewTemplate>) -> TurretTileViewTemplate {
        self.init(
            turretTexture: setting.usedFieldSettings["turretTexture"]!.decodeDynamically(),
            base: setting.usedFieldSettings["base"]?.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<TurretTileViewTemplate>) {
        self.turretTexture.encodeDynamically(to: setting.allFieldSettings["turretTexture"]!)
        self.base?.encodeDynamically(to: setting.allFieldSettings["base"]!)
    }
}
extension WithAlternatePreviewTileViewTemplate {
    internal convenience init(from setting: StructSetting<WithAlternatePreviewTileViewTemplate>) {
        self.init(
            preview: setting.usedFieldSettings["preview"]!.decodeDynamically(),
            base: setting.usedFieldSettings["base"]?.decodeDynamically()
        )
    }

    static internal func decode(from setting: StructSetting<WithAlternatePreviewTileViewTemplate>) -> WithAlternatePreviewTileViewTemplate {
        self.init(
            preview: setting.usedFieldSettings["preview"]!.decodeDynamically(),
            base: setting.usedFieldSettings["base"]?.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<WithAlternatePreviewTileViewTemplate>) {
        self.preview.encodeDynamically(to: setting.allFieldSettings["preview"]!)
        self.base?.encodeDynamically(to: setting.allFieldSettings["base"]!)
    }
}
extension WorldSettings {
    internal convenience init(from setting: StructSetting<WorldSettings>) {
        self.init(
            tileViewWidthHeight: setting.usedFieldSettings["tileViewWidthHeight"]!.decodeDynamically(),
            tileViewTemplates: setting.usedFieldSettings["tileViewTemplates"]!.decodeDynamically(),
            entityViewTemplates: setting.usedFieldSettings["entityViewTemplates"]!.decodeDynamically(),
            edgeMaskTextureBase: setting.usedFieldSettings["edgeMaskTextureBase"]!.decodeDynamically(),
            glossTexture: setting.usedFieldSettings["glossTexture"]!.decodeDynamically(),
            imagePlaceholderTexture: setting.usedFieldSettings["imagePlaceholderTexture"]!.decodeDynamically(),
            entityZPositions: setting.usedFieldSettings["entityZPositions"]!.decodeDynamically(),
            rotateTileViewBasedOnOrientation: setting.usedFieldSettings["rotateTileViewBasedOnOrientation"]!.decodeDynamically(),
            entityViewScaleModes: setting.usedFieldSettings["entityViewScaleModes"]!.decodeDynamically(),
            entityGrabColors: setting.usedFieldSettings["entityGrabColors"]!.decodeDynamically(),
            amountScreenShakesWhenEntityCollides: setting.usedFieldSettings["amountScreenShakesWhenEntityCollides"]!.decodeDynamically(),
            tileDescriptions: setting.usedFieldSettings["tileDescriptions"]!.decodeDynamically(),
            playerInputSpeedMultiplier: setting.usedFieldSettings["playerInputSpeedMultiplier"]!.decodeDynamically(),
            playerInputSpeedFractionChangePerSecond: setting.usedFieldSettings["playerInputSpeedFractionChangePerSecond"]!.decodeDynamically(),
            tileDamage: setting.usedFieldSettings["tileDamage"]!.decodeDynamically(),
            knockback: setting.usedFieldSettings["knockback"]!.decodeDynamically(),
            entityData: setting.usedFieldSettings["entityData"]!.decodeDynamically(),
            entitySpawnRadius: setting.usedFieldSettings["entitySpawnRadius"]!.decodeDynamically(),
            destructibleSolidInitialHealth: setting.usedFieldSettings["destructibleSolidInitialHealth"]!.decodeDynamically(),
            dashEdgeBoostSpeed: setting.usedFieldSettings["dashEdgeBoostSpeed"]!.decodeDynamically(),
            springEdgeBounceMultiplier: setting.usedFieldSettings["springEdgeBounceMultiplier"]!.decodeDynamically(),
            macroTileSizes: setting.usedFieldSettings["macroTileSizes"]!.decodeDynamically(),
            defaultTileMetadatas: setting.usedFieldSettings["defaultTileMetadatas"]!.decodeDynamically(),
            tileOrientationMeanings: setting.usedFieldSettings["tileOrientationMeanings"]!.decodeDynamically(),
            selectableTypes: setting.usedFieldSettings["selectableTypes"]!.decodeDynamically()
        )
    }

    static internal func decode(from setting: StructSetting<WorldSettings>) -> WorldSettings {
        self.init(
            tileViewWidthHeight: setting.usedFieldSettings["tileViewWidthHeight"]!.decodeDynamically(),
            tileViewTemplates: setting.usedFieldSettings["tileViewTemplates"]!.decodeDynamically(),
            entityViewTemplates: setting.usedFieldSettings["entityViewTemplates"]!.decodeDynamically(),
            edgeMaskTextureBase: setting.usedFieldSettings["edgeMaskTextureBase"]!.decodeDynamically(),
            glossTexture: setting.usedFieldSettings["glossTexture"]!.decodeDynamically(),
            imagePlaceholderTexture: setting.usedFieldSettings["imagePlaceholderTexture"]!.decodeDynamically(),
            entityZPositions: setting.usedFieldSettings["entityZPositions"]!.decodeDynamically(),
            rotateTileViewBasedOnOrientation: setting.usedFieldSettings["rotateTileViewBasedOnOrientation"]!.decodeDynamically(),
            entityViewScaleModes: setting.usedFieldSettings["entityViewScaleModes"]!.decodeDynamically(),
            entityGrabColors: setting.usedFieldSettings["entityGrabColors"]!.decodeDynamically(),
            amountScreenShakesWhenEntityCollides: setting.usedFieldSettings["amountScreenShakesWhenEntityCollides"]!.decodeDynamically(),
            tileDescriptions: setting.usedFieldSettings["tileDescriptions"]!.decodeDynamically(),
            playerInputSpeedMultiplier: setting.usedFieldSettings["playerInputSpeedMultiplier"]!.decodeDynamically(),
            playerInputSpeedFractionChangePerSecond: setting.usedFieldSettings["playerInputSpeedFractionChangePerSecond"]!.decodeDynamically(),
            tileDamage: setting.usedFieldSettings["tileDamage"]!.decodeDynamically(),
            knockback: setting.usedFieldSettings["knockback"]!.decodeDynamically(),
            entityData: setting.usedFieldSettings["entityData"]!.decodeDynamically(),
            entitySpawnRadius: setting.usedFieldSettings["entitySpawnRadius"]!.decodeDynamically(),
            destructibleSolidInitialHealth: setting.usedFieldSettings["destructibleSolidInitialHealth"]!.decodeDynamically(),
            dashEdgeBoostSpeed: setting.usedFieldSettings["dashEdgeBoostSpeed"]!.decodeDynamically(),
            springEdgeBounceMultiplier: setting.usedFieldSettings["springEdgeBounceMultiplier"]!.decodeDynamically(),
            macroTileSizes: setting.usedFieldSettings["macroTileSizes"]!.decodeDynamically(),
            defaultTileMetadatas: setting.usedFieldSettings["defaultTileMetadatas"]!.decodeDynamically(),
            tileOrientationMeanings: setting.usedFieldSettings["tileOrientationMeanings"]!.decodeDynamically(),
            selectableTypes: setting.usedFieldSettings["selectableTypes"]!.decodeDynamically()
        )
    }

    internal func encode(to setting: StructSetting<WorldSettings>) {
        self.tileViewWidthHeight.encodeDynamically(to: setting.allFieldSettings["tileViewWidthHeight"]!)
        self.tileViewTemplates.encodeDynamically(to: setting.allFieldSettings["tileViewTemplates"]!)
        self.entityViewTemplates.encodeDynamically(to: setting.allFieldSettings["entityViewTemplates"]!)
        self.edgeMaskTextureBase.encodeDynamically(to: setting.allFieldSettings["edgeMaskTextureBase"]!)
        self.glossTexture.encodeDynamically(to: setting.allFieldSettings["glossTexture"]!)
        self.imagePlaceholderTexture.encodeDynamically(to: setting.allFieldSettings["imagePlaceholderTexture"]!)
        self.entityZPositions.encodeDynamically(to: setting.allFieldSettings["entityZPositions"]!)
        self.rotateTileViewBasedOnOrientation.encodeDynamically(to: setting.allFieldSettings["rotateTileViewBasedOnOrientation"]!)
        self.entityViewScaleModes.encodeDynamically(to: setting.allFieldSettings["entityViewScaleModes"]!)
        self.entityGrabColors.encodeDynamically(to: setting.allFieldSettings["entityGrabColors"]!)
        self.amountScreenShakesWhenEntityCollides.encodeDynamically(to: setting.allFieldSettings["amountScreenShakesWhenEntityCollides"]!)
        self.tileDescriptions.encodeDynamically(to: setting.allFieldSettings["tileDescriptions"]!)
        self.playerInputSpeedMultiplier.encodeDynamically(to: setting.allFieldSettings["playerInputSpeedMultiplier"]!)
        self.playerInputSpeedFractionChangePerSecond.encodeDynamically(to: setting.allFieldSettings["playerInputSpeedFractionChangePerSecond"]!)
        self.tileDamage.encodeDynamically(to: setting.allFieldSettings["tileDamage"]!)
        self.knockback.encodeDynamically(to: setting.allFieldSettings["knockback"]!)
        self.entityData.encodeDynamically(to: setting.allFieldSettings["entityData"]!)
        self.entitySpawnRadius.encodeDynamically(to: setting.allFieldSettings["entitySpawnRadius"]!)
        self.destructibleSolidInitialHealth.encodeDynamically(to: setting.allFieldSettings["destructibleSolidInitialHealth"]!)
        self.dashEdgeBoostSpeed.encodeDynamically(to: setting.allFieldSettings["dashEdgeBoostSpeed"]!)
        self.springEdgeBounceMultiplier.encodeDynamically(to: setting.allFieldSettings["springEdgeBounceMultiplier"]!)
        self.macroTileSizes.encodeDynamically(to: setting.allFieldSettings["macroTileSizes"]!)
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
            return TurretComponent.HowToFire.continuous(
                projectileEndTiles: setting.selectedCaseFieldSettings["projectileEndTiles"]!.decodeDynamically()
            )
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
        case .continuous(let projectileEndTiles):
            projectileEndTiles.encodeDynamically(to: setting.selectedCaseFieldSettings["projectileEndTiles"]!)
        }
    }
}
extension TurretComponent.RotationPattern {
    static internal func decode(from setting: ComplexEnumSetting<TurretComponent.RotationPattern>) -> TurretComponent.RotationPattern {
        switch setting.selectedCase {
        case "neverRotate":
            return TurretComponent.RotationPattern.neverRotate
        case "rotateContinuously":
            return TurretComponent.RotationPattern.rotateContinuously(
                speed: setting.selectedCaseFieldSettings["speed"]!.decodeDynamically()
            )
        case "rotateToTarget":
            return TurretComponent.RotationPattern.rotateToTarget(
                speed: setting.selectedCaseFieldSettings["speed"]!.decodeDynamically()
            )
        case "rotateToTargetInstantly":
            return TurretComponent.RotationPattern.rotateToTargetInstantly
        default:
            fatalError("Can't decode case with name because it doesn't exist: \(setting.selectedCase)")
        }
    }

    internal func encode(to setting: ComplexEnumSetting<TurretComponent.RotationPattern>) {
        switch self {
        case .neverRotate:
            break
        case .rotateContinuously(let speed):
            speed.encodeDynamically(to: setting.selectedCaseFieldSettings["speed"]!)
        case .rotateToTarget(let speed):
            speed.encodeDynamically(to: setting.selectedCaseFieldSettings["speed"]!)
        case .rotateToTargetInstantly:
            break
        }
    }
}
extension TurretComponent.SpreadPattern {
    static internal func decode(from setting: ComplexEnumSetting<TurretComponent.SpreadPattern>) -> TurretComponent.SpreadPattern {
        switch setting.selectedCase {
        case "fireStraight":
            return TurretComponent.SpreadPattern.fireStraight
        case "fireAround":
            return TurretComponent.SpreadPattern.fireAround(
                totalNumProjectiles: setting.selectedCaseFieldSettings["totalNumProjectiles"]!.decodeDynamically()
            )
        default:
            fatalError("Can't decode case with name because it doesn't exist: \(setting.selectedCase)")
        }
    }

    internal func encode(to setting: ComplexEnumSetting<TurretComponent.SpreadPattern>) {
        switch self {
        case .fireStraight:
            break
        case .fireAround(let totalNumProjectiles):
            totalNumProjectiles.encodeDynamically(to: setting.selectedCaseFieldSettings["totalNumProjectiles"]!)
        }
    }
}
