//
// Created by Jakob Hain on 5/30/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class SliderNode: ControlNode {
    private let _didSliderFractionsChange: Publisher<[CGFloat]> = Publisher()
    var didSliderFractionsChange: Observable<[CGFloat]> { Observable(publisher: _didSliderFractionsChange) }

    override init(size: CGSize) {
        super.init(size: size)
        didTouchMove.subscribe(observer: self, priority: ObservablePriority.view) { newPositions in
            let newFractions: [CGFloat] = newPositions.map { newPosition in
                let unclampedFraction = newPosition.x / size.width
                return CGFloat.clamp(unclampedFraction, min: 0, max: 1)
            }
            self._didSliderFractionsChange.publish(newFractions)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented in SliderNode")
    }
}
