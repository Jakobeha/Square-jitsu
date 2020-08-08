//
// Created by Jakob Hain on 5/29/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

/// Custom image tile sub inspector view
class ImageSIV: UXCompoundView {
    private let subInspector: MacroMetadataInspector<ImageMetadata>
    private let settings: WorldSettings

    init(_ subInspector: MacroMetadataInspector<ImageMetadata>, settings: WorldSettings) {
        self.subInspector = subInspector
        self.settings = settings
    }

    override func newBody() -> UXView {
        ImageLocationSelector(
            width: InspectorView.maxInspectorWidth,
            selectedLocation: subInspector.metadata.imageTexture
        ) { newLocation in
            let newTexture = newLocation.texture
            let newSizeInTiles = self.settings.convertViewToTile(size: newTexture.size())
            self.subInspector.metadata = ImageMetadata(
                imageTexture: newLocation,
                sizeInTiles: newSizeInTiles
            )

            self.regenerateBody()
        }
    }
}
