//
// Created by Jakob Hain on 7/12/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import UIKit

class LevelPickerViewController: UINavigationController, LevelPickerInDirectoryDelegate {
    private static let storyboard = getDefaultStoryboard()

    static func new(initialUrl: URL, onSelect: @escaping (URL) -> ()) throws -> LevelPickerViewController {
        let controller = storyboard.instantiateInitialViewController() as! LevelPickerViewController
        try controller.set(url: initialUrl)
        controller.onPick = onSelect
        return controller
    }

    var onPick: ((URL) -> ())? = nil

    private var state: LevelPickerState = .pick {
        didSet {
            for viewController in viewControllers {
                if let levelPickerInDirectoryViewController = viewController as? LevelPickerInDirectoryViewController {
                    levelPickerInDirectoryViewController.state = state
                }
            }
        }
    }

    func set(url: URL) throws {
        let viewControllers = try getViewControllersFor(url: url)
        setViewControllers(viewControllers, animated: false)
    }

    private func getViewControllersFor(url: URL) throws -> [LevelPickerInDirectoryViewController] {
        try LevelPickerInDirectory.listFromRootUntil(url: url).map { levelSelectorInDirectory in
            let viewController = LevelPickerInDirectoryViewController.new(model: levelSelectorInDirectory, delegate: self)
            viewController.state = state
            return viewController
        }
    }

    // region level selector in directory delegate
    func cancelPick() {
        dismiss(animated: true)
    }
    
    func moveUpDirectory() {
        popViewController(animated: true)
    }

    func moveInto(levelFolder: LevelFolder) {
        do {
            let levelFolderPicker = try LevelPickerInDirectory(url: levelFolder.url)
            let levelFolderViewController = LevelPickerInDirectoryViewController.new(model: levelFolderPicker, delegate: self)
            levelFolderViewController.state = state
            pushViewController(levelFolderViewController, animated: true)
        } catch {
            let errorAlert = UIAlertController(title: "Error opening folder '\(levelFolder.name)", message: error.localizedDescription, preferredStyle: .alert)
            errorAlert.addAction(UIAlertAction(title: "Continue", style: .default))
            present(errorAlert, animated: true)
        }
    }

    func pick(level: Level) {
        onPick?(level.url)
        dismiss(animated: true)
    }

    // region edit toggle
    func startEditing() {
        assert(!state.isEditing)
        state = .edit(selectedUrls: [], clipboard: .empty)
    }

    func select(url: URL) {
        assert(state.isEditing)
        state.selectedUrls.insert(url)
    }

    func deselect(url: URL) {
        assert(state.isEditing && state.selectedUrls.contains(url))
        state.selectedUrls.remove(url)
    }
    // endregion

    // region edit actions
    func completeEditing() {
        assert(state.isEditing)
        let selectedUrls = state.selectedUrls

        if selectedUrls.isEmpty {
            state = .pick
        } else {
            state = .edit(selectedUrls: [], clipboard: state.clipboard)

            let actionSheet = UIAlertController(title: "On Edited Items", message: nil, preferredStyle: .actionSheet)
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            actionSheet.addAction(UIAlertAction(title: "Copy", style: .default) { _ in
                self.copy(urls: selectedUrls)
            })
            actionSheet.addAction(UIAlertAction(title: "Cut", style: .default) { _ in
                self.cut(urls: selectedUrls)
            })
            actionSheet.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
                self.delete(urls: selectedUrls)
            })
            present(actionSheet, animated: true)
        }
    }

    private func copy(urls: Set<URL>) {
        state = .edit(selectedUrls: [], clipboard: .copy(urls: urls))
    }

    private func cut(urls: Set<URL>) {
        state = .edit(selectedUrls: [], clipboard: .cut(urls: urls))
    }

    private func delete(urls: Set<URL>) {
        state.clipboard.urls.subtract(urls)
        let fileManager = FileManager.default
        do {
            for url in urls {
                try fileManager.removeItem(at: url)
            }
            (viewControllers.last! as! LevelPickerInDirectoryViewController).didDelete(urls: urls)
        } catch {
            let errorAlert = UIAlertController(title: "Failed to remove all files", message: error.localizedDescription, preferredStyle: .alert)
            errorAlert.addAction(UIAlertAction(title: "Continue", style: .default))
            present(errorAlert, animated: true)
        }
    }

    func pasteIn(directoryUrl: URL) {
        assert(!state.clipboard.urls.isEmpty, "illegal state - tried to paste when clipboard is empty")
        do {
            for sourceUrl in state.clipboard.urls {
                let destinationUrl = directoryUrl.appendingPathComponent(sourceUrl.lastPathComponent, isDirectory: sourceUrl.hasDirectoryPath)
                if sourceUrl != destinationUrl {
                    let realDestinationUrl = FileManager.default.changeUrlToAvoidConflicts(url: destinationUrl)
                    if destinationUrl != realDestinationUrl {
                        Logger.warn("pasted item changed to avoid conflicting with an existing item, from \(destinationUrl.lastPathComponent) to \(realDestinationUrl.lastPathComponent)")
                    }
                    switch state.clipboard.itemState {
                    case .none:
                        fatalError("very illegal state - tried to paste when clipboard is empty")
                    case .beingCut:
                        try FileManager.default.moveItem(at: sourceUrl, to: destinationUrl)
                    case .beingCopied:
                        try FileManager.default.copyItem(at: sourceUrl, to: destinationUrl)
                    }
                }
            }
        } catch {
            let errorAlert = UIAlertController(title: "Failed to paste all files", message: error.localizedDescription, preferredStyle: .alert)
            errorAlert.addAction(UIAlertAction(title: "Continue", style: .default))
            present(errorAlert, animated: true)
        }
        state.clipboard = .empty
    }

    private func stopEditing() {
        assert(state.isEditing)
        state = .pick
    }
    // endregion
}
