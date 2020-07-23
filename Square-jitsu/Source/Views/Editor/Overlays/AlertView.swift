//
// Created by Jakob Hain on 7/10/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class AlertView: UXView, OverlayView {
    typealias MyOverlay = Alert

    private static let size: CGSize = CGSize(width: 256, height: 256)
    private static let backgroundTexture: SKTexture = SKTexture(imageNamed: "UI/AlertBackground")
    private static let backgroundCenterRect: CGRect = CGRect(origin: CGPoint(x: 0.5, y: 0.5), size: CGSize.zero)
    private static let labelPadding: CGFloat = 8
    private static let labelSpacing: CGFloat = 8
    private static let fontName: String = Label.fontName
    private static let fontSize: CGFloat = Label.fontSize
    private static let fontColor: SKColor = Label.fontColor

    private static func configure(labelNode: SKLabelNode, isSubtext: Bool) {
        labelNode.fontSize = fontSize
        labelNode.fontColor = fontColor
        labelNode.horizontalAlignmentMode = .center
        labelNode.preferredMaxLayoutWidth = size.width - (labelPadding * 2)
        labelNode.numberOfLines = 0
        if isSubtext {
            labelNode.fontName = fontName
            labelNode.verticalAlignmentMode = .top
            labelNode.position = CGPoint(x: 0, y: -labelSpacing)
        } else {
            labelNode.fontName = "\(fontName)-Bold"
            labelNode.verticalAlignmentMode = .bottom
            labelNode.position = CGPoint(x: 0, y: labelSpacing)
        }
    }

    private let alert: Alert

    let node: SKNode

    var size: CGSize {
        AlertView.size
    }

    required init(overlay: Overlay) {
        alert = overlay as! Alert

        node = SKNode()
        // Note: We don't use UX coords to position elements in the alert view.
        // node is centered in the scene so it isn't necessary
        let backgroundNode = SKSpriteNode(texture: AlertView.backgroundTexture, size: AlertView.size)
        backgroundNode.centerRect = AlertView.backgroundCenterRect
        backgroundNode.zPosition = 0
        let messageNode = SKLabelNode(text: alert.message)
        AlertView.configure(labelNode: messageNode, isSubtext: false)
        messageNode.zPosition = 1
        let subtextNode: SKNode? = {
            if let subtext = self.alert.subtext {
                let subtextNode = SKLabelNode(text: subtext)
                AlertView.configure(labelNode: subtextNode, isSubtext: true)
                subtextNode.zPosition = 1
                return subtextNode
            } else {
                return nil
            }
        }()
        let optionContainerNode = SKNode()
        // The option nodes follow UX coords,
        // so the container node's position is at the top left of its bounds
        optionContainerNode.position = CGPoint(
            x: -AlertView.size.width / 2,
            y: (-AlertView.size.height / 2) + TextButton.height
        )
        let optionNodeWidth = AlertView.size.width / CGFloat(alert.options.count)
        for (index, option) in alert.options.enumerated() {
            let optionPositionFraction = CGFloat(index) / CGFloat(alert.options.count)
            let optionPositionX = optionPositionFraction * AlertView.size.width

            let optionButton = TextButton(
                owner: self,
                text: option.description,
                width: optionNodeWidth
            ) { (self) in
                self.alert.selectOption(index: index)
            }

            optionButton.node.position = CGPoint(x: optionPositionX, y: 0)
            optionButton.node.zPosition = 1
            optionContainerNode.addChild(optionButton.node)
        }
        optionContainerNode.zPosition = 1

        node.addChild(backgroundNode)
        node.addChild(messageNode)
        if let subtextNode = subtextNode {
            node.addChild(subtextNode)
        }
        node.addChild(optionContainerNode)
    }

    func set(scene: SJScene) {
        node.position = ConvertToUXCoords(size: scene.size / 2).toPoint
    }
}