//
// Created by Jakob Hain on 5/29/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

/// Side-based orientation sub inspector view
class SideBasedOrientationSIV: UXCompoundView {
    private let subInspector: SideBasedOrientationInspector

    init(_ subInspector: SideBasedOrientationInspector) {
        self.subInspector = subInspector
    }

    override func newBody() -> UXView {
        HStack([
            Button(
                owner: self,
                textureName: "UI/ConnectTilesButton/West", 
                isEnabled: !subInspector.tilesConnectableToSide[.west].isEmpty,
                isSelected: !subInspector.tilesConnectedToSide[.west].isEmpty
            ) { (self) in
                self.subInspector.connectTilesTo(side: .west)
                self.regenerateBody()
            },
            Button(
                owner: self,
                textureName: "UI/ConnectTilesButton/South",
                isEnabled: !subInspector.tilesConnectableToSide[.south].isEmpty,
                isSelected: !subInspector.tilesConnectedToSide[.south].isEmpty
            ) { (self) in
                self.subInspector.connectTilesTo(side: .south)
                self.regenerateBody()
            },
            Button(
                owner: self,
                textureName: "UI/ConnectTilesButton/North",
                isEnabled: !subInspector.tilesConnectableToSide[.north].isEmpty,
                isSelected: !subInspector.tilesConnectedToSide[.north].isEmpty
            ) { (self) in
                self.subInspector.connectTilesTo(side: .north)
                self.regenerateBody()
            },
            Button(
                owner: self,
                textureName: "UI/ConnectTilesButton/East",
                isEnabled: !subInspector.tilesConnectableToSide[.east].isEmpty,
                isSelected: !subInspector.tilesConnectedToSide[.east].isEmpty
            ) { (self) in
                self.subInspector.connectTilesTo(side: .east)
                self.regenerateBody()
            }
        ])
    }
}
