//
//  GameScene.swift
//  Square-jitsu
//
//  Created by Jakob Hain on 5/2/20.
//  Copyright © 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class EditorController: WorldConduit {
    struct EditorModelView {
        let editor: Editor
        let editorView: EditorView

        var world: World { editor.editableWorld.world }
        var worldUrl: URL { editor.editableWorld.worldUrl }
    }

    private static let testWorldFileName: String = "test"
    private static let testWorldUrl: URL = WorldFile.localUrl(baseName: testWorldFileName)

    private let userSettings: UserSettings
    private let parent: SJScene
    private let updater: FixedUpdater = FixedUpdater()
    private(set) var loaded: EditorModelView? = nil

    init(userSettings: UserSettings, parent: SJScene) {
        self.userSettings = userSettings
        self.parent = parent
        updater.onTick = tick
    }

    func loadTestWorld() {
        // try! FileManager.default.removeItem(at: EditorController.testWorldUrl)
        load(worldUrl: EditorController.testWorldUrl)
    }

    // region loading and unloading
    func load(worldUrl: URL) {
        let document = WorldDocument(fileURL: worldUrl)
        document.open { succeeded in
            if succeeded {
                self.load(worldDocument: document)
            } else {
                self.displayError(WorldFileSyncError(action: "reading", error: nil), context: "loading world")
            }
        }
    }

    func load(worldDocument: WorldDocument) {
        unload()

        let editor = Editor(worldDocument: worldDocument, userSettings: userSettings, conduit: self)
        let editorView = EditorView(editor: editor, scene: parent)
        editorView.placeIn(parent: parent)
        loaded = EditorModelView(editor: editor, editorView: editorView)

        let world = loaded!.world
        updater.fixedDeltaTime = world.settings.fixedDeltaTime / world.speed
        world.didChangeSpeed.subscribe(observer: self, priority: .model) {
            self.updater.fixedDeltaTime = world.settings.fixedDeltaTime / world.speed
            self.parent.speed = world.speed
        }
    }

    func unload() {
        loaded?.editorView.removeFromParent()
        loaded?.world.didChangeSpeed.unsubscribe(observer: self)

        loaded = nil
    }
    // endregion

    // region updating
    /// Even if paused we still need to update to prevent accumulated ticks
    func update(_ currentTime: TimeInterval) {
        updater.update(currentTime)
    }

    private func tick() {
        loaded?.editor.tick()
    }
    // endregion

    private func displayError(_ error: Error, context: String) {
        Logger.warn("Editor controller got error while \(context): \(error)")
        loaded?.editor.overlays.present(Alert(message: "Editor controller got error while \(context)", subtext: error.localizedDescription, options: [ContinueAlertOption.continue]) { _ in })
    }

    // region conduit actions
    func teleportTo(relativePath: String) {
        if let loaded = loaded {
            loaded.editor.overlays.present(Alert(message: "Open \(relativePath)?", subtext: "The current level will be saved", options: [StandardAlertOption.ok, .cancel]) { selectedOption in
                switch selectedOption {
                case .cancel:
                    break
                case .ok:
                    let destinationUrl = loaded.worldUrl.appending(relativePath: relativePath)
                    self.load(worldUrl: destinationUrl)
                }
            })
        } else {
            Logger.warn("Tried to teleport but no world is loaded")
        }
    }

    func perform(buttonAction: TileButtonAction) {
        Logger.warn("TODO: Implement button actions in EditorController, tried to perform '\(buttonAction)'")
    }
    // endregion
}
