//
// Created by Jakob Hain on 7/12/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import UIKit

class LevelSelectorInDirectoryViewController: UICollectionViewController {
    private static let storyboard = getDefaultStoryboard()

    static func new(model: LevelSelectorInDirectory, delegate: LevelSelectorInDirectoryDelegate?) -> LevelSelectorInDirectoryViewController {
        let controller = storyboard.instantiateInitialViewController() as! LevelSelectorInDirectoryViewController
        controller.model = model
        controller.delegate = delegate
        return controller
    }

    weak var delegate: LevelSelectorInDirectoryDelegate? = nil

    private var model: LevelSelectorInDirectory? = nil {
        didSet { collectionView.reloadData() }
    }

    private func select(levelItem: LevelItem) {
        guard let delegate = delegate else {
            Logger.warn("no delegate assigned to level selector")
            return
        }

        switch levelItem {
        case .newFolder:
            initiateCreateNewLevelFolder()
        case .newLevel:
            initiateCreateNewLevel()
        case .upDirectory:
            delegate.selectUpDirectory()
        case .folder(name: _, let url):
            delegate.select(levelFolder: LevelFolder(url: url))
        case .level(name: _, let url):
            delegate.select(level: Level(url: url))
        }
    }
    
    @IBAction func cancel() {
        guard let delegate = delegate else {
            Logger.warn("no delegate assigned to level selector")
            return
        }

        delegate.cancelSelection()
    }

    // region local actions
    private func initiateCreateNewLevelFolder() {
        initiateCreateNewLevelItem(itemTypeDescription: "folder", isLevelFolder: true, contextMessage: nil, createNewLevelFolderAt)
    }

    private func initiateCreateNewLevel() {
        initiateCreateNewLevelItem(itemTypeDescription: "level", isLevelFolder: false, contextMessage: nil, createNewLevelAt)
    }

    private func initiateCreateNewLevelItem(itemTypeDescription: String, isLevelFolder: Bool, contextMessage: String?, _ doCreate: @escaping (URL) throws -> ()) {
        func retryWith(contextMessage newContextMessage: String) {
            initiateCreateNewLevelItem(itemTypeDescription: itemTypeDescription, isLevelFolder: isLevelFolder, contextMessage: newContextMessage, doCreate)
        }

        let inputAlert = UIAlertController(title: "Create \(itemTypeDescription)", message: nil, preferredStyle: .alert)
        inputAlert.addTextField { textField in
            textField.placeholder = "Name"
        }
        inputAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        inputAlert.addAction(UIAlertAction(title: "Create", style: .default) { _ in
            let name = inputAlert.textFields![0].text ?? ""
            if name.isEmpty {
                retryWith(contextMessage: "Enter a name, field was empty")
                return
            }

            guard let model = self.model else {
                Logger.warn("illegal state - level selector in directory controller can't create a level item without a model")
                return
            }
            let itemUrl = isLevelFolder ?
                    model.getSubLevelFolderWith(name: name) :
                    model.getSubLevelWith(name: name)

            if FileManager.default.fileExists(atPath: itemUrl.path) {
                retryWith(contextMessage: "\(itemTypeDescription.localizedCapitalized) with name '\(name)' exists")
                return
            }

            do {
                try doCreate(itemUrl)
            } catch {
                let errorAlert = UIAlertController(title: "Couldn't create \(itemTypeDescription)", message: error.localizedDescription, preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "Continue", style: .default))
                self.present(errorAlert, animated: true)
            }
        })
        present(inputAlert, animated: true)
    }

    private func createNewLevelFolderAt(url: URL) throws {
        // Create the folder
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: false)

        // Update the model and view
        let name = LevelFolder(url: url).name
        let levelFolderIndexPath = getIndexPathOfNewLevelFolderWith(name: name)
        do {
            try model!.reload()
        } catch {
            Logger.warn("Failed to reload model after successfully creating level folder (ignoring silently)")
        }
        collectionView.insertItems(at: [levelFolderIndexPath])
        collectionView.scrollToItem(at: levelFolderIndexPath, at: [], animated: true)
    }

    private func createNewLevelAt(url: URL) throws {
        // Create the level
        // Levels can be loaded as empty files - they will be completely new levels
        try Data().write(to: url, options: [.withoutOverwriting])

        // Update the model and view
        let name = Level(url: url).name
        let levelIndexPath = getIndexPathOfNewLevelWith(name: name)
        do {
            try model!.reload()
        } catch {
            Logger.warn("Failed to reload model after successfully creating level (ignoring silently)")
        }
        collectionView.insertItems(at: [levelIndexPath])
        collectionView.scrollToItem(at: levelIndexPath, at: [], animated: true)
    }

    private func getIndexPathOfNewLevelFolderWith(name: String) -> IndexPath {
        IndexPath(item: model!.getIndexOfNewLevelFolderWith(name: name), section: 0)
    }

    private func getIndexPathOfNewLevelWith(name: String) -> IndexPath {
        IndexPath(item: model!.getIndexOfNewLevelWith(name: name), section: 0)
    }
    // endregion

    // region collection view data source
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        model != nil ? 1 : 0
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        assert(section == 0 && model != nil)
        return model!.levelItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize.square(sideLength: LevelItemCollectionViewCell.widthHeight)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        assert(indexPath.section == 0 && model != nil)
        let levelItem = model!.levelItems[indexPath.item]
        // Reuse identifier is hardcoded but it's also so in IB, so a constant wouldn't help
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LevelItem", for: indexPath) as! LevelItemCollectionViewCell
        cell.levelItem = levelItem
        return cell
    }
    // endregion

    // region collection view delegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! LevelItemCollectionViewCell
        let levelItem = cell.levelItem!
        select(levelItem: levelItem)

        cell.isHighlighted = false
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    // endregion
}
