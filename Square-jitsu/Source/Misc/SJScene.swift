//
// Created by Jakob Hain on 7/12/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

/// Has access to its view's controller so it can present other view controllers like alerts
class SJScene: SKScene {
    weak var viewController: UIViewController? = nil
}
