//
// Created by Jakob Hain on 5/29/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

/// Connected side sub inspector view
class ConnectedSideSIV: UXCompoundView {
    private let subInspector: AdjacentToSolidInspector

    init(_ subInspector: AdjacentToSolidInspector) {
        self.subInspector = subInspector
    }

    override func newBody() -> UXView {
        HStack([
            Button(
                textureName: "UI/ConnectTilesButton/West", 
                isEnabled: !subInspector.tilesConnectableToSide[.west].isEmpty,
                isSelected: !subInspector.tilesConnectedToSide[.west].isEmpty
            ) {
                self.subInspector.connectTilesTo(side: .west)
                self.regenerateBody()
            },
            Button(
                textureName: "UI/ConnectTilesButton/South",
                isEnabled: !subInspector.tilesConnectableToSide[.south].isEmpty,
                isSelected: !subInspector.tilesConnectedToSide[.south].isEmpty
            ) {
                self.subInspector.connectTilesTo(side: .south)
                self.regenerateBody()
            },
            Button(
                textureName: "UI/ConnectTilesButton/North",
                isEnabled: !subInspector.tilesConnectableToSide[.north].isEmpty,
                isSelected: !subInspector.tilesConnectedToSide[.north].isEmpty
            ) {
                self.subInspector.connectTilesTo(side: .north)
                self.regenerateBody()
            },
            Button(
                textureName: "UI/ConnectTilesButton/East",
                isEnabled: !subInspector.tilesConnectableToSide[.east].isEmpty,
                isSelected: !subInspector.tilesConnectedToSide[.east].isEmpty
            ) {
                self.subInspector.connectTilesTo(side: .east)
                self.regenerateBody()
            }
        ])
    }
}
