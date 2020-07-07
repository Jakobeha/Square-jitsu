//
// Created by Jakob Hain on 5/29/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

/// Corner-based orientation sub inspector view
class CornerBasedOrientationSIV: UXCompoundView {
    private let subInspector: CornerBasedOrientationInspector

    init(_ subInspector: CornerBasedOrientationInspector) {
        self.subInspector = subInspector
    }

    override func newBody() -> UXView {
        VStack([
            HStack([
                Button(
                    textureName: "UI/ConnectTilesButton/West", 
                    isEnabled: !subInspector.tilesConnectableToCorner[.west].isEmpty,
                    isSelected: !subInspector.tilesConnectedToCorner[.west].isEmpty
                ) {
                    self.subInspector.connectTilesTo(corner: .west)
                    self.regenerateBody()
                },
                Button(
                    textureName: "UI/ConnectTilesButton/South",
                    isEnabled: !subInspector.tilesConnectableToCorner[.south].isEmpty,
                    isSelected: !subInspector.tilesConnectedToCorner[.south].isEmpty
                ) {
                    self.subInspector.connectTilesTo(corner: .south)
                    self.regenerateBody()
                },
                Button(
                    textureName: "UI/ConnectTilesButton/North",
                    isEnabled: !subInspector.tilesConnectableToCorner[.north].isEmpty,
                    isSelected: !subInspector.tilesConnectedToCorner[.north].isEmpty
                ) {
                    self.subInspector.connectTilesTo(corner: .north)
                    self.regenerateBody()
                },
                Button(
                    textureName: "UI/ConnectTilesButton/East",
                    isEnabled: !subInspector.tilesConnectableToCorner[.east].isEmpty,
                    isSelected: !subInspector.tilesConnectedToCorner[.east].isEmpty
                ) {
                    self.subInspector.connectTilesTo(corner: .east)
                    self.regenerateBody()
                }
            ]),
            HStack([
                Button(
                        textureName: "UI/ConnectTilesButton/SouthWest",
                        isEnabled: !subInspector.tilesConnectableToCorner[.southWest].isEmpty,
                        isSelected: !subInspector.tilesConnectedToCorner[.southWest].isEmpty
                ) {
                    self.subInspector.connectTilesTo(corner: .southWest)
                    self.regenerateBody()
                },
                Button(
                        textureName: "UI/ConnectTilesButton/SouthEast",
                        isEnabled: !subInspector.tilesConnectableToCorner[.southEast].isEmpty,
                        isSelected: !subInspector.tilesConnectedToCorner[.southEast].isEmpty
                ) {
                    self.subInspector.connectTilesTo(corner: .southEast)
                    self.regenerateBody()
                },
                Button(
                        textureName: "UI/ConnectTilesButton/NorthWest",
                        isEnabled: !subInspector.tilesConnectableToCorner[.northWest].isEmpty,
                        isSelected: !subInspector.tilesConnectedToCorner[.northWest].isEmpty
                ) {
                    self.subInspector.connectTilesTo(corner: .northWest)
                    self.regenerateBody()
                },
                Button(
                        textureName: "UI/ConnectTilesButton/NorthEast",
                        isEnabled: !subInspector.tilesConnectableToCorner[.northEast].isEmpty,
                        isSelected: !subInspector.tilesConnectedToCorner[.northEast].isEmpty
                ) {
                    self.subInspector.connectTilesTo(corner: .northEast)
                    self.regenerateBody()
                }
            ])
        ])
    }
}
