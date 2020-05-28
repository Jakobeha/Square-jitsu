//
// Created by Jakob Hain on 5/18/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

class TileMenu {
    private let settings: WorldSettings
    private let selectableBigTypes: [TileBigType]
    private let generalLayout: [TileLayer:[TileBigType]]

    var selectedBigType: TileBigType {
        didSet {
            let selectableSmallTypes = settings.selectableTypes[selectedBigType]!
            if !selectableSmallTypes.contains(selectedSmallType) {
                selectedSmallType = selectableSmallTypes.first!
            }
            _didSelect.publish()
        }
    }
    var selectedSmallType: TileSmallType = TileSmallType(0) {
        didSet { _didSelect.publish() }
    }
    var selectedBigTypesPerLayer: [TileLayer:TileBigType]
    var openLayer: TileLayer? = nil {
        didSet {
            if openLayer != nil {
                // Doesn't publish explicitly because changing selected big type does
                // (and we probably only want to publish after everything is set)
                selectedBigType = selectedBigTypesPerLayer[openLayer!]!
            } else {
                _didSelect.publish()
            }
        }
    }

    var selectedTileTypesPerLayer: [TileLayer:TileType] {
        selectedBigTypesPerLayer.mapValues { bigType in TileType(bigType: bigType, smallType: selectedSmallType) }
    }
    var selectedTileType: TileType { TileType(bigType: selectedBigType, smallType: selectedSmallType) }

    var layerSubmenuLayout: [TileLayer]
    var bigSubmenuLayout: [TileLayer:[TileType]] {
        generalLayout.mapValues { bigTypes in bigTypes.map { bigType in
            TileType(bigType: bigType, smallType: selectedSmallType)
        } }
    }
    var smallSubmenuLayout: [TileBigType:[TileType]]? {
        openLayer == nil ? nil : generalLayout[openLayer!]!.associateWith { bigType in
            settings.selectableTypes[bigType]!.map { smallType in
                TileType(bigType: bigType, smallType: smallType)
            }
        }
    }

    private let _didSelect: Publisher<()> = Publisher()
    var didSelect: Observable<()> { Observable(publisher: _didSelect) }

    init(settings: WorldSettings) {
        self.settings = settings
        selectableBigTypes = TileBigType.allCases.filter { bigType in
            settings.selectableTypes.keys.contains(bigType)
        }
        generalLayout = [TileLayer:[TileBigType]](grouping: selectableBigTypes) { tileBigType in
            tileBigType.layer
        }
        layerSubmenuLayout = generalLayout.keys.sorted { lhsLayer, rhsLayer in
            lhsLayer < rhsLayer
        }
        selectedBigType = selectableBigTypes.first!
        selectedBigTypesPerLayer = generalLayout.mapValues { bigTypes in bigTypes.first! }
    }
}
