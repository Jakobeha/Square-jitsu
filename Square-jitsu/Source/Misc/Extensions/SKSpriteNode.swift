//
// Created by Jakob Hain on 5/16/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

extension SKSpriteNode {
    func resizeTo(size: CGSize, scaleMode: ScaleMode) {
        switch scaleMode {
        case .ignoreAspect:
            self.size = size
        case .aspectFill:
            let myAspectRatio = self.size.aspectRatioYDivX
            let sizeAspectRatio = size.aspectRatioYDivX
            if myAspectRatio > sizeAspectRatio {
                self.size = CGSize(width: size.width, height: size.height * myAspectRatio)
            } else {
                self.size = CGSize(width: size.width / myAspectRatio, height: size.height)
            }
        case .aspectFit:
            let myAspectRatio = self.size.aspectRatioYDivX
            let sizeAspectRatio = size.aspectRatioYDivX
            if myAspectRatio > sizeAspectRatio {
                self.size = CGSize(width: size.width / myAspectRatio, height: size.height)
            } else {
                self.size = CGSize(width: size.width, height: size.height * myAspectRatio)
            }
        }
    }
}
