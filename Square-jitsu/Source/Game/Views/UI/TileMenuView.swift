//
// Created by Jakob Hain on 5/20/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class TileMenuView: UXCompoundView {
    private let tileMenu: TileMenu
    private let settings: WorldSettings

    init(tileMenu: TileMenu, settings: WorldSettings) {
        self.tileMenu = tileMenu
        self.settings = settings
    }

    override func newBody() -> UXView {
        tileMenu.openLayer != nil ? VStack([
            newBigTypeView(),
            newSmallTypeView(openLayer: tileMenu.openLayer!)
        ], height: ButtonSize.tile.sideLength) : newBigTypeView()
    }

    private func newBigTypeView() -> UXView {
        HStack(tileMenu.selectedTilesPerLayer.values.map { tileType in
            TileButton(tileType: tileType, settings: settings) { print("TODO") }
        })
    }

    private func newSmallTypeView(openLayer: TileLayer) -> UXView {
        let smallTypes = tileMenu.menuLayout[openLayer]!
        let xOffsetInTiles = [TileLayer](tileMenu.selectedTilesPerLayer.keys).firstIndex(of: openLayer)! - smallTypes.count
        let xOffsetInPoints = CGFloat(xOffsetInTiles) * ButtonSize.tile.sideLength
        return RePosition(
            HStack(smallTypes.map { tileType in
                TileButton(tileType: tileType, settings: settings) { print("TODO") }
            }),
            left: xOffsetInPoints
        )
    }
}
