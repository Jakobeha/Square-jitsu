//
// Created by Jakob Hain on 5/29/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

private let SliderSize: CGSize = CGSize(width: 256, height: 32)
private let SliderBackgroundTexture: SKTexture = SKTexture(imageNamed: "UI/SliderBackground")
private let SliderBackgroundSizeRatio: CGSize = CGSize(width: 1, height: 0.5)
private let SliderBackgroundCenterRect: CGRect = CGRect(center: CGPoint(x: 0.5, y: 0.5), size: CGSize(width: 0.5, height: 1))
private let SliderKnobTexture: SKTexture = SKTexture(imageNamed: "UI/SliderKnob")
private let SliderKnobCenterRect: CGRect = CGRect(center: CGPoint(x: 0.5, y: 0.5), size: CGSize.square(sideLength: 0.5))

class Slider<Number: SliderNumber>: UXView {
    private let range: ClosedRange<Number>
    private var values: [Number] {
        didSet { knobNodes = values.map(createKnobNode) }
    }

    var value: Number {
        get { values.first! }
        set {
            values = [newValue]
            didValueChange(value)
        }
    }
    private let didValueChange: (Number) -> ()

    var size: CGSize { SliderSize }
    private var backgroundSize: CGSize { SliderSize * SliderBackgroundSizeRatio }
    private var knobSize: CGSize { CGSize.square(sideLength: min(size.width, size.height)) }
    private var knobEdgeOffset: CGFloat { backgroundSize.height / 2 }

    private let sliderNode: SliderNode
    var node: SKNode { sliderNode }
    private let backgroundNode: SKSpriteNode
    private var knobNodes: [SKSpriteNode] {
        willSet {
            for knobNode in knobNodes {
                knobNode.removeFromParent()
            }
        }
    }

    init(range: ClosedRange<Number>, values: [Number], _ didValueChange: @escaping (Number) -> ()) {
        self.range = range
        self.values = values
        self.didValueChange = didValueChange

        sliderNode = SliderNode(size: SliderSize)

        backgroundNode = SKSpriteNode(texture: SliderBackgroundTexture)
        backgroundNode.size = SliderSize * SliderBackgroundSizeRatio
        // Center the background
        backgroundNode.position = ConvertToUXCoords(point: (SliderSize * (CGSize.unit - SliderBackgroundSizeRatio) / 2).toPoint)
        backgroundNode.centerRect = SliderBackgroundCenterRect
        backgroundNode.anchorPoint = UXSpriteAnchor
        backgroundNode.zPosition = 0
        sliderNode.addChild(backgroundNode)

        knobNodes = []
        knobNodes = values.map(createKnobNode)

        sliderNode.didSliderFractionsChange.subscribe(observer: self, priority: .view) { (self, fractions) in
            self.setSliderValueFromControl(fractions: fractions)
        }
    }

    private func createKnobNode(value: Number) -> SKSpriteNode {
        let fraction = getFractionOf(value: value)
        let knobPositionX = CGFloat.lerp(start: knobEdgeOffset, end: size.width - knobEdgeOffset, t: fraction)
        let knobPosition = CGPoint(x: knobPositionX, y: 0)

        let knobNode = SKSpriteNode(texture: SliderKnobTexture, size: knobSize)
        knobNode.position = knobPosition
        knobNode.anchorPoint = CGPoint(x: 0.5, y: UXSpriteAnchor.y)
        knobNode.zPosition = 1
        // Would put in didSet,
        // but for some reason the first didSet doesn't fire in the initializer
        // even though we set `knobNodes` twice
        sliderNode.addChild(knobNode)

        return knobNode
    }

    private func setSliderValueFromControl(fractions: [CGFloat]) {
        if fractions.count == 1 {
            let fraction = fractions.first!
            value = getValueOf(fraction: fraction)
        }
    }

    private func getFractionOf(value: Number) -> CGFloat {
        let fraction = CGFloat.reverseLerp(start: range.lowerBound.toFloat, end: range.upperBound.toFloat, value: value.toFloat)
        assert(fraction >= -CGFloat.epsilon && fraction <= 1 + CGFloat.epsilon)
        return fraction
    }

    private func getValueOf(fraction: CGFloat) -> Number {
        assert(fraction >= -CGFloat.epsilon && fraction <= 1 + CGFloat.epsilon)
        return Number.round(CGFloat.lerp(start: range.lowerBound.toFloat, end: range.upperBound.toFloat, t: fraction))
    }

    func set(scene: SJScene) {}
}
