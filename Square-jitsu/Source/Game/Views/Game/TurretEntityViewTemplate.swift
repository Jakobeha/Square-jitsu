//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct TurretEntityViewTemplate: EntityViewTemplate, SingleSettingCodable {
    private static let chargingCircleName: String = "chargingCircle"

    let base: EntityViewTemplate
    let maxChargingCircleRadius: CGFloat
    let minChargingCircleRadius: CGFloat
    let chargingCircleOffset: CGPoint
    let chargingCircleColor: SKColor

    func generateNode(entity: Entity) -> SKNode {
        assert(entity.next.turC != nil, "turret entity view is only allowed on turret entities")

        let baseNode = base.generateNode(entity: entity)

        let chargingCircleNode = SKShapeNode()
        configureChargingCircle(entity: entity, chargingCircleNode: chargingCircleNode)
        baseNode.addChild(chargingCircleNode)

        updateChargingCircle(entity: entity, chargingCircleNode: chargingCircleNode)

        return baseNode
    }

    func generatePreviewNode(size: CGSize) -> SKNode {
        // Charging circle isn't in preview
        base.generatePreviewNode(size: size)
    }

    func tick(entity: Entity, node: SKNode) {
        let chargingCircleNode = node.childNode(withName: TurretEntityViewTemplate.chargingCircleName)! as! SKShapeNode
        updateChargingCircle(entity: entity, chargingCircleNode: chargingCircleNode)
    }

    private func configureChargingCircle(entity: Entity, chargingCircleNode: SKShapeNode) {
        chargingCircleNode.name = TurretEntityViewTemplate.chargingCircleName
        chargingCircleNode.position = chargingCircleOffset * entity.world!.settings.tileViewWidthHeight
        chargingCircleNode.fillColor = chargingCircleColor
        chargingCircleNode.strokeColor = SKColor.clear
    }

    private func updateChargingCircle(entity: Entity, chargingCircleNode: SKShapeNode) {
        switch entity.next.turC!.fireState {
        case .targetFoundNeedToCharge(let timeUntilFire):
            let fractionUntilFire = timeUntilFire / entity.next.turC!.delayWhenTargetFoundBeforeFire
            let chargingCircleRadius = CGFloat.lerp(start: minChargingCircleRadius, end: maxChargingCircleRadius, t: fractionUntilFire) * entity.world!.settings.tileViewWidthHeight
            chargingCircleNode.isHidden = false
            chargingCircleNode.path = CGPath.centeredCircle(radius: chargingCircleRadius)
        default:
            chargingCircleNode.isHidden = true
        }
    }

    // region encoding and decoding
    typealias AsSetting = StructSetting<TurretEntityViewTemplate>

    static func newSetting() -> StructSetting<TurretEntityViewTemplate> {
        StructSetting(requiredFields: [
            "base": DeferredSetting { EntityViewTemplateSetting() },
            "maxChargingCircleRadius": CGFloatRangeSetting(0...64),
            "minChargingCircleRadius": CGFloatRangeSetting(0...64),
            "chargingCircleOffset": CGPointRangeSetting(x: -1...1, y: -1...1),
            "chargingCircleColor": ColorSetting()
        ], optionalFields: [:], allowedExtraFields: ["type"])
    }
    // endregion
}
