//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

final class ContinuouslyAnimatedTileViewTemplate: EmptyTileViewTemplate, SingleSettingCodable {
    let textureBase: TextureSet
    let totalDuration: CGFloat

    // sourcery: nonSetting
    private let numTextures: Int

    var durationBetweenFrames: CGFloat { totalDuration / CGFloat(numTextures) }

    private var previewTexture: SKTexture { textureBase[0] }

    init(textureBase: TextureSet, totalDuration: CGFloat) {
        self.textureBase = textureBase
        numTextures = textureBase.count
        self.totalDuration = totalDuration
    }

    override func generateNode(world: ReadonlyWorld, pos3D: WorldTilePos3D, tileType: TileType) -> SKNode {
        let node = SKSpriteNode(texture: getCurrentTextureIn(world: world), size: CGSize.square(sideLength: world.settings.tileViewWidthHeight))
        world.didTick.subscribe(observer: self, priority: .view) { [weak node] (self) in
            node?.texture = self.getCurrentTextureIn(world: world)
        }
        return node
    }

    override func generatePreviewNodeRaw(size: CGSize, settings: WorldSettings) -> SKNode {
        let node = SKSpriteNode(texture: previewTexture, size: size)
        node.anchorPoint = UXSpriteAnchor
        return node
    }

    private func getCurrentTextureIn(world: ReadonlyWorld) -> SKTexture {
        let elapsedTime = world.elapsedTime
        let numElapsedFrames = UInt64(elapsedTime / TimeInterval(durationBetweenFrames))
        let textureIndex = Int(numElapsedFrames % UInt64(numTextures))
        return textureBase[textureIndex]
    }

    // region encoding and decoding
    typealias AsSetting = StructSetting<ContinuouslyAnimatedTileViewTemplate>

    static func newSetting() -> AsSetting {
        StructSetting(requiredFields: [
            "textureBase": TextureSetSetting(),
            "totalDuration": CGFloatRangeSetting(0...16)
        ], optionalFields: [:], allowedExtraFields: ["type"])
    }
    // endregion
}
