//
// Created by Jakob Hain on 5/29/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

/// Portal tile sub inspector view
class PortalSIV: UXCompoundView {
    private let subInspector: MacroMetadataInspector<PortalMetadata>
    private let worldUrl: URL

    init(_ subInspector: MacroMetadataInspector<PortalMetadata>, worldUrl: URL) {
        self.subInspector = subInspector
        self.worldUrl = worldUrl
    }

    override func newBody() -> UXView {
        WorldLocationSelector(
            currentWorldUrl: worldUrl,
            width: InspectorView.maxInspectorWidth,
            selectedLocation: subInspector.metadata.relativePathToDestination
        ) { newLocation in
            self.subInspector.metadata = PortalMetadata(relativePathToDestination: newLocation)
        }
    }
}
