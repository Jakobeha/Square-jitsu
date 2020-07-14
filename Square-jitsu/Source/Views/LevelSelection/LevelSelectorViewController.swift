//
// Created by Jakob Hain on 7/12/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import UIKit

class LevelSelectorViewController: UINavigationController, LevelSelectorInDirectoryDelegate {
    private static let storyboard = getDefaultStoryboard()

    static func new(initialUrl: URL, onSelect: @escaping (URL) -> ()) throws -> LevelSelectorViewController {
        let controller = storyboard.instantiateInitialViewController() as! LevelSelectorViewController
        try controller.set(url: initialUrl)
        controller.onSelect = onSelect
        return controller
    }

    var onSelect: ((URL) -> ())? = nil

    func set(url: URL) throws {
        let viewControllers = try getViewControllersFor(url: url)
        setViewControllers(viewControllers, animated: false)
    }

    private func getViewControllersFor(url: URL) throws -> [LevelSelectorInDirectoryViewController] {
        try LevelSelectorInDirectory.listFromRootUntil(url: url).map { levelSelectorInDirectory in
            LevelSelectorInDirectoryViewController.new(model: levelSelectorInDirectory, delegate: self)
        }
    }

    // region level selector in directory delegate
    func cancelSelection() {
        dismiss(animated: true)
    }
    
    func selectUpDirectory() {
        popViewController(animated: true)
    }

    func select(levelFolder: LevelFolder) {
        do {
            let levelFolderSelector = try LevelSelectorInDirectory(url: levelFolder.url)
            let levelFolderViewController = LevelSelectorInDirectoryViewController.new(model: levelFolderSelector, delegate: self)
            pushViewController(levelFolderViewController, animated: true)
        } catch {
            let errorAlert = UIAlertController(title: "Error opening folder '\(levelFolder.name)", message: error.localizedDescription, preferredStyle: .alert)
            errorAlert.addAction(UIAlertAction(title: "Continue", style: .default))
            present(errorAlert, animated: true)
        }
    }

    func select(level: Level) {
        onSelect?(level.url)
        dismiss(animated: true)
    }
    // endregion
}
