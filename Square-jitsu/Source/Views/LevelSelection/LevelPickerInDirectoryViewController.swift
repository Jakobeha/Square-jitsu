//
// Created by Jakob Hain on 7/12/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import UIKit

class LevelPickerInDirectoryViewController: UICollectionViewController {
    private static let storyboard = getDefaultStoryboard()

    private static let standardBackgroundColor: UIColor = UIColor(white: 0.125, alpha: 1)
    private static let editingBackgroundColor: UIColor = UIColor(white: 0.5, alpha: 1)

    static func new(model: LevelPickerInDirectory, delegate: LevelPickerInDirectoryDelegate?) -> LevelPickerInDirectoryViewController {
        let controller = storyboard.instantiateInitialViewController() as! LevelPickerInDirectoryViewController
        // delegate set first in order to update cells better
        controller.delegate = delegate
        controller.model = model
        return controller
    }

    weak var delegate: LevelPickerInDirectoryDelegate? = nil {
        didSet {
            if model != nil {
                updateSelectedCells()
            }
        }
    }

    var state: LevelPickerState = .pick {
        didSet {
            updateIsEditing()
            updateEditButtonTitle()
            updateSelectedCells()
            updatePasteButton()
            updateCellsInClipboard()
        }
    }

    private var model: LevelPickerInDirectory? = nil {
        didSet {
            updateTitle()
            collectionView.reloadData()
        }
    }

    @IBOutlet private var pasteButtonItem: UIBarButtonItem! = nil

    private func tap(levelItem: LevelItem, select: Bool) {
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
            delegate.moveUpDirectory()
        case .folder(name: _, let url):
            delegate.moveInto(levelFolder: LevelFolder(url: url))
        case .level(name: _, let url):
            if state.isEditing {
                if select {
                    delegate.select(url: url)
                } else {
                    delegate.deselect(url: url)
                }
            } else {
                delegate.pick(level: Level(url: url))
            }
        }
    }
    
    @IBAction func cancel() {
        guard let delegate = delegate else {
            Logger.warn("no delegate assigned to level selector")
            return
        }

        delegate.cancelPick()
    }

    @IBAction func paste() {
        guard let model = model else {
            fatalError("level picker in directory tried to paste without model")
        }
        guard let delegate = delegate else {
            Logger.warn("no delegate assigned to level selector")
            return
        }

        let pastedUrls = state.clipboard.urls
        delegate.pasteIn(directoryUrl: model.url)
        do {
            try model.reload()
            let insertedIndexPaths = getIndexPathsOfVisibleItemsWith(urls: pastedUrls)
            collectionView.insertItems(at: insertedIndexPaths)
        } catch {
            Logger.warn("level picker in directory failed to reload data, silently ignoring: \(error.localizedDescription)")
        }
    }

    func didDelete(urls: Set<URL>) {
        guard let model = model else {
            fatalError("level picker in directory tried to paste without model")
        }

        do {
            try model.reload()
            let deletedIndexPaths = getIndexPathsOfVisibleItemsWith(urls: urls)
            collectionView.deleteItems(at: deletedIndexPaths)
        } catch {
            Logger.warn("level picker in directory failed to reload data, silently ignoring: \(error.localizedDescription)")
        }
    }

    /// Returns the index paths of all cells which are visible and whose items' urls are contained in the given set
    private func getIndexPathsOfVisibleItemsWith(urls: Set<URL>) -> [IndexPath] {
        collectionView.indexPathsForVisibleItems.filter { indexPath in
            let cell = self.collectionView.cellForItem(at: indexPath) as! LevelItemCollectionViewCell
            let levelItem = cell.levelItem!
            if let indexPathUrl = levelItem.url {
                return urls.contains(indexPathUrl)
            } else {
                return false
            }
        }
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

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItems = [editButtonItem]
        editButtonItem.possibleTitles = ["Select", "Edit", "Done"]
        editButtonItem.action = #selector(toggleEditing)
        updateEditButtonTitle()
    }

    private func updateTitle() {
        navigationItem.title = model?.url.lastPathComponent ?? "Loading..."
    }

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
        if isLevelItemSelected(levelItem) {
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        }
        cell.clipboardState = state.clipboard.getStateOf(levelItem: levelItem)
        return cell
    }
    // endregion

    // region collection view delegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! LevelItemCollectionViewCell
        let levelItem = cell.levelItem!
        tap(levelItem: levelItem, select: true)

        cell.isHighlighted = false
        if !isLevelItemSelected(levelItem) {
            collectionView.deselectItem(at: indexPath, animated: true)
        }
    }

    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! LevelItemCollectionViewCell
        let levelItem = cell.levelItem!
        tap(levelItem: levelItem, select: false)

        cell.isHighlighted = false
        if isLevelItemSelected(levelItem) {
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
        }
    }
    // endregion

    // region editing
    @objc private func toggleEditing() {
        guard let delegate = delegate else {
            Logger.warn("level picker in directory can't toggle editing because it doesn't have a delegate")
            return
        }

        if !state.isEditing {
            delegate.startEditing()
        } else {
            delegate.completeEditing()
        }
    }

    private func updateIsEditing() {
        if isEditing != state.isEditing {
            setEditing(state.isEditing, animated: true)
            collectionView.allowsMultipleSelection = state.isEditing
        }
    }

    private func updateEditButtonTitle() {
        if isEditing {
            // If there are no selected urls then when we complete editing we will cancel.
            // Otherwise we might perform an edit action
            editButtonItem.title = state.selectedUrls.isEmpty ? "Done" : "Edit"
        } else {
            editButtonItem.title = "Select"
        }
    }

    override func setEditing(_ newIsEditing: Bool, animated: Bool) {
        let valueChanged = isEditing != newIsEditing
        super.setEditing(newIsEditing, animated: animated)

        if valueChanged {
            func animation() {
                // We change the background so it's clearer to the user whether or not they're in edit mode
                let backgroundColor = newIsEditing ?
                        LevelPickerInDirectoryViewController.editingBackgroundColor :
                        LevelPickerInDirectoryViewController.standardBackgroundColor
                collectionView.backgroundColor = backgroundColor
            }
            if animated {
                UIView.animate(
                    withDuration: UIView.defaultAnimationDuration,
                    delay: 0,
                    options: [.allowUserInteraction],
                    animations: animation
                )
            } else {
                animation()
            }
        }
    }

    private func updateSelectedCells() {
        for indexPath in collectionView.indexPathsForVisibleItems {
            if let cell = collectionView.cellForItem(at: indexPath) as! LevelItemCollectionViewCell? {
                let levelItem = cell.levelItem!
                let shouldBeSelected = isLevelItemSelected(levelItem)
                if shouldBeSelected && !cell.isSelected {
                    collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
                } else if !shouldBeSelected && cell.isSelected {
                    collectionView.deselectItem(at: indexPath, animated: true)
                }
            }
        }
    }

    private func isLevelItemSelected(_ levelItem: LevelItem) -> Bool {
        levelItem.url != nil && state.selectedUrls.contains(levelItem.url!)
    }

    // region clipboard
    private func updatePasteButton() {
        navigationItem.rightBarButtonItems =
                state.clipboard.isEmpty ?
                [editButtonItem] :
                [editButtonItem, pasteButtonItem]
    }

    private func updateCellsInClipboard() {
        for cell in collectionView.visibleCells as! [LevelItemCollectionViewCell] {
            let levelItem = cell.levelItem!
            cell.clipboardState = state.clipboard.getStateOf(levelItem: levelItem)
        }
    }
    // endregion
    // endregion
}
