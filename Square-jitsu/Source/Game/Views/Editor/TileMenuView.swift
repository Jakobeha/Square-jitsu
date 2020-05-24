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
        super.init()

        tileMenu.didSelect.subscribe(observer: self) {
            self.regenerateBody()
        }
    }

    override func newBody() -> UXView {
        tileMenu.openLayer != nil ? VStack([
            newLayerView(),
            newBigTypeView(openLayer: tileMenu.openLayer!),
            newSmallTypeView(openLayer: tileMenu.openLayer!)
        ], height: ButtonSize.tile.sideLength) : newLayerView()
    }

    private func newLayerView() -> UXView {
        HStack(tileMenu.layerSubmenuLayout.map { layer in
            let tileType = tileMenu.selectedTileTypesPerLayer[layer]!
            return TileButton(tileType: tileType, settings: settings, isSelected: tileMenu.openLayer == layer) {
                self.tileMenu.openLayer = layer
            }
        })
    }

    private func newBigTypeView(openLayer: TileLayer) -> UXView {
        let types = tileMenu.bigSubmenuLayout[openLayer]!
        let xOffsetInTiles = xOffsetInTilesForBigTypeMenu(openLayer: openLayer)
        let xOffsetInPoints = CGFloat(xOffsetInTiles) * ButtonSize.tile.sideLength
        return RePosition(
            HStack(types.map { tileType in
                TileButton(tileType: tileType, settings: settings, isSelected: tileMenu.selectedBigType == tileType.bigType) {
                    self.tileMenu.selectedBigType = tileType.bigType
                }
            }),
            left: xOffsetInPoints
        )
    }

    private func newSmallTypeView(openLayer: TileLayer) -> UXView {
        let types = tileMenu.smallSubmenuLayout![tileMenu.selectedBigType]!
        let xOffsetInTiles = xOffsetInTilesForSmallTypeMenu(openLayer: openLayer)
        let xOffsetInPoints = CGFloat(xOffsetInTiles) * ButtonSize.tile.sideLength
        return RePosition(
            HStack(types.map { tileType in
                TileButton(tileType: tileType, settings: settings, isSelected: tileMenu.selectedSmallType == tileType.smallType ) {
                    self.tileMenu.selectedSmallType = tileType.smallType
                }
            }),
            left: xOffsetInPoints
        )
    }

    private func xOffsetInTilesForBigTypeMenu(openLayer: TileLayer) -> Int {
        let types = tileMenu.bigSubmenuLayout[openLayer]!
        let bigTypeIndex = [TileLayer](tileMenu.selectedTileTypesPerLayer.keys).firstIndex(of: openLayer)!
        return min(0, bigTypeIndex - types.count)
    }

    private func xOffsetInTilesForSmallTypeMenu(openLayer: TileLayer) -> Int {
        let smallTypes = tileMenu.smallSubmenuLayout![tileMenu.selectedBigType]!
        let bigTypes = tileMenu.bigSubmenuLayout[openLayer]!
        let bigTypeIndex = bigTypes.firstIndex(of: tileMenu.selectedTileType)!
        return min(0, bigTypeIndex - smallTypes.count)
    }
}