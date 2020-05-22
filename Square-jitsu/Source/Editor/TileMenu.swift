//
// Created by Jakob Hain on 5/18/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

struct TileMenu {
    private static let selectableBigTypes: [TileBigType] = TileBigType.allCases.filter { bigType in
        bigType != TileBigType.air && bigType != TileBigType.player
    }

    private static let generalLayout: [TileLayer:[TileBigType]] = [TileLayer:[TileBigType]](grouping: selectableBigTypes) { tileBigType in
        tileBigType.layer
    }

    var selectedBigType: TileBigType = selectableBigTypes.first!
    var selectedSmallType: TileSmallType = TileSmallType(0)
    var selectedBigTypesPerLayer: [TileLayer:TileBigType] = TileMenu.generalLayout.mapValues { bigTypes in
        bigTypes.first!
    }
    var openLayer: TileLayer? = nil

    var selectedTilesPerLayer: [TileLayer:TileType] {
        selectedBigTypesPerLayer.mapValues { bigType in TileType(bigType: bigType, smallType: selectedSmallType) }
    }
    var selectedTileType: TileType { TileType(bigType: selectedBigType, smallType: selectedSmallType) }

    var menuLayout: [TileLayer:[TileType]] {
        TileMenu.generalLayout.mapValues { bigTypes in bigTypes.map { bigType in
            TileType(bigType: bigType, smallType: selectedSmallType)
        } }
    }
}
