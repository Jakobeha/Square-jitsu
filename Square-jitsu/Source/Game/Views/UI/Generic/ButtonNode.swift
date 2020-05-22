//
// Created by Jakob Hain on 5/20/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

/// Forwards touch events for a button control
class ButtonNode: SKNode {
    private static let touchCaptureRectOutset: CGFloat = 32

    var size: CGSize

    var onTouchDown: (() -> ())?
    var onTouchUp: (() -> ())?
    private let action: () -> ()

    private var isPressed: Bool = false

    var touchCaptureRect: CGRect {
        CGRect(origin: CGPoint.zero, size: size).insetBy(sideLength: -ButtonNode.touchCaptureRectOutset)
    }

    init(size: CGSize, action: @escaping () -> ()) {
        self.size = size
        self.action = action
        super.init()
        isUserInteractionEnabled = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented in ButtonNode")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        touchesMaybePressed()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        touchesMaybePressed()
        touchesMaybeReleased(event: event!, wouldBeCancel: true)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        touchesMaybeReleased(event: event!, wouldBeCancel: false)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        touchesMaybeReleased(event: event!, wouldBeCancel: true)
    }

    private func touchesMaybePressed() {
        if !isPressed {
            isPressed = true
            onTouchDown?()
        }
    }

    private func touchesMaybeReleased(event: UIEvent, wouldBeCancel: Bool) {
        let capturesATouch = event.allTouches!.contains(where: captures)
        if !capturesATouch {
            isPressed = false
            onTouchUp?()
            if !wouldBeCancel {
                action()
            }
        }
    }

    private func captures(touch: UITouch) -> Bool {
        !touch.isEndedOrExited && touchCaptureRect.contains(touch.location(in: self))
    }
}
