//
// Created by Jakob Hain on 7/12/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

fileprivate let LocationSelectorHeight: CGFloat = 48
fileprivate let LocationSelectorBackgroundTexture: SKTexture = SKTexture(imageNamed: "UI/LocationSelectorBackground")
fileprivate let LocationSelectorPressedBackgroundTexture: SKTexture = SKTexture(imageNamed: "UI/LocationSelectorBackgroundPressed")
fileprivate let LocationSelectorBackgroundCenterRect: CGRect = CGRect(origin: CGPoint(x: 0.25, y: 0.5), size: CGSize.zero)
fileprivate let LocationSelectorPadding: CGFloat = 15
fileprivate let LocationSelectorFontName: String = Label.fontName
fileprivate let LocationSelectorFontSize: CGFloat = 18
fileprivate let LocationSelectorFontColor: SKColor = Label.fontColor

class LocationSelector<Location: CustomStringConvertible>: UXView {
    struct SelectionOption {
        let label: String
        let chooseLocation: (@escaping (Location) -> (), UIViewController) -> ()
    }

    private static func backgroundTexture(isPressed: Bool) -> SKTexture {
        isPressed ? LocationSelectorPressedBackgroundTexture : LocationSelectorBackgroundTexture
    }

    private var isPressed: Bool = false {
        didSet { backgroundNode.texture = LocationSelector.backgroundTexture(isPressed: isPressed) }
    }

    private let selectAction: (Location) -> ()
    private let selectionOptions: [SelectionOption]

    private let buttonNode: ButtonNode
    private let backgroundNode: SKSpriteNode
    private let selectedTextNode: SKLabelNode
    var node: SKNode { buttonNode }

    private weak var parentController: UIViewController?

    private let width: CGFloat
    var size: CGSize { CGSize(width: width, height: LocationSelectorHeight) }

    init(
        width: CGFloat,
        selectedLocation: Location?,
        selectionOptions: [SelectionOption],
        selectAction: @escaping (Location) -> ()
    ) {
        self.width = width
        self.selectionOptions = selectionOptions
        self.selectAction = selectAction

        let size = CGSize(width: width, height: LocationSelectorHeight)

        backgroundNode = SKSpriteNode(texture: LocationSelector.backgroundTexture(isPressed: false), size: size)
        backgroundNode.centerRect = LocationSelectorBackgroundCenterRect
        backgroundNode.anchorPoint = UXSpriteAnchor
        backgroundNode.zPosition = 0
        selectedTextNode = SKLabelNode(text: selectedLocation?.description ?? "")
        selectedTextNode.fontName = LocationSelectorFontName
        selectedTextNode.fontSize = LocationSelectorFontSize
        selectedTextNode.fontColor = LocationSelectorFontColor
        selectedTextNode.position = ConvertToUXCoords(point: CGPoint(x: LocationSelectorPadding, y: LocationSelectorPadding))
        selectedTextNode.horizontalAlignmentMode = .left
        selectedTextNode.verticalAlignmentMode = .top
        selectedTextNode.zPosition = 1
        buttonNode = ButtonNode(size: size)
        buttonNode.didPress.subscribe(observer: self, priority: .view) { (self) in
            self.openLocationSelector()
        }
        buttonNode.addChild(backgroundNode)
        buttonNode.addChild(selectedTextNode)
        buttonNode.didTouchDown.subscribe(observer: self, priority: .view) { (self) in
            self.isPressed = true 
        }
        buttonNode.didTouchUp.subscribe(observer: self, priority: .view) { (self) in
            self.isPressed = false
        }
    }

    private func openLocationSelector() {
        guard let parentController = parentController else {
            Logger.warn("can't present location picker because the location selector isn't assigned a scene with a view controller")
            return
        }

        switch selectionOptions.count {
        case 0:
            fatalError("location selector must have at least one selection option")
        case 1:
            let selectionOption = selectionOptions[0]
            selectionOption.chooseLocation(self.selectAction, parentController)
        default:
            openLocationPicker(parentController: parentController)
        }
    }

    private func openLocationPicker(parentController: UIViewController) {
        let locationPickerAlert = UIAlertController(title: "Select Location", message: nil, preferredStyle: .actionSheet)
        for selectionOption in selectionOptions {
            locationPickerAlert.addAction(UIAlertAction(title: selectionOption.label, style: .default) { _ in
                selectionOption.chooseLocation(self.selectAction, parentController)
            })
        }
        locationPickerAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        parentController.present(locationPickerAlert, animated: true)
    }

    func set(scene: SJScene) {
        self.parentController = scene.viewController
    }
}
