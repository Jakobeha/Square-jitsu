//
// Created by Jakob Hain on 7/12/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import UIKit

class LevelPickerInDirectoryViewController: UICollectionViewController, LevelItemCollectionViewCellDelegate, UIViewControllerPreviewingDelegate {
    private static let storyboard = getDefaultStoryboard()

    private static let standardBackgroundColor: UIColor = UIColor(white: 0.125, alpha: 1)
    private static let editingBackgroundColor: UIColor = UIColor(white: 0.5, alpha: 1)
    private static let errorPreviewViewController: UIViewController = LevelPreviewViewController.new(preview: WorldFilePreview.missingOrCorrupted)

    static func new(model: LevelPickerInDirectory, state: LevelPickerState, canCancel: Bool, delegate: LevelPickerInDirectoryDelegate?) -> LevelPickerInDirectoryViewController {
        let controller = storyboard.instantiateInitialViewController() as! LevelPickerInDirectoryViewController
        controller.canCancel = canCancel
        // delegate set first in order to update cells better
        controller.delegate = delegate
        controller.state = state
        controller.model = model
        return controller
    }

    var canCancel: Bool = true {
        didSet {
            updateCancelButton()
        }
    }

    weak var delegate: LevelPickerInDirectoryDelegate? = nil {
        didSet {
            if model != nil {
                updateSelectedCells(animated: false)
            }
        }
    }

    var state: LevelPickerState = .pick {
        didSet {
            // Need to update some stuff even if model == nil,
            // and nothing will be broken in that scenario,
            // so no model != nil check
            updateIsEditing()
            updateEditButtonTitle()
            updateSelectedCells(animated: true)
            updatePasteButton()
            updateCellsInClipboard()
        }
    }

    private var urlBeingRenamed: URL? = nil {
        willSet {
            if urlBeingRenamed != nil {
                if let cell = (collectionView.visibleCells as! [LevelItemCollectionViewCell]).first(where: { cell in
                    cell.levelItem!.url == urlBeingRenamed
                }) {
                    cell.isRenaming = false
                }
            }
        }
        didSet {
            if urlBeingRenamed != nil {
                if let cell = (collectionView.visibleCells as! [LevelItemCollectionViewCell]).first(where: { cell in
                    cell.levelItem!.url == urlBeingRenamed
                }) {
                    cell.isRenaming = true
                }
            }
        }
    }

    private var model: LevelPickerInDirectory? = nil {
        didSet {
            updateTitle()
            collectionView.reloadData()
        }
    }

    @IBOutlet private var cancelButton: UIBarButtonItem! = nil
    @IBOutlet private var pasteButton: UIBarButtonItem! = nil

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
            delegate.moveUpDirectory(animated: true)
        case .folder(name: _, let url):
            if state.isEditing {
                if select {
                    delegate.select(url: url)
                } else {
                    delegate.deselect(url: url)
                    delegate.moveInto(levelFolder: LevelFolder(url: url), animated: true)
                }
            } else {
                delegate.moveInto(levelFolder: LevelFolder(url: url), animated: true)
            }
        case .level(name: _, let url):
            if state.isEditing {
                if select {
                    delegate.select(url: url)
                } else {
                    delegate.deselect(url: url)
                }
            } else {
                delegate.pick(level: Level(url: url), animated: true)
            }
        }
    }

    private func forceTap(levelItem: LevelItem, animated: Bool) {
        guard let delegate = delegate else {
            Logger.warn("no delegate assigned to level selector")
            return
        }

        switch levelItem {
        case .newFolder, .newLevel:
            fatalError("can't force-tap new folder or new level actions because they don't create a 3d touch preview")
        case .upDirectory:
            delegate.moveUpDirectory(animated: animated)
        case .folder(name: _, let url):
            delegate.moveInto(levelFolder: LevelFolder(url: url), animated: animated)
        case .level(name: _, let url):
            delegate.pick(level: Level(url: url), animated: animated)
        }
    }

    @IBAction func cancel() {
        guard let delegate = delegate else {
            Logger.warn("no delegate assigned to level selector")
            return
        }

        delegate.cancelPick(animated: true)
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

        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: collectionView)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Reload the model just in case it changed from last appearance
        // (sometimes, but not always, happens)
        do {
            try model?.reload()
        } catch {
            Logger.warn("level picker failed to reload model")
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // There's a bug where if we don't call this,
        // cells which should be selected won't be until we scroll
        updateSelectedCells(animated: false)
    }

    private func updateTitle() {
        navigationItem.title = model?.url.lastPathComponent ?? "Loading..."
    }

    private func updateCancelButton() {
        navigationItem.leftBarButtonItem = canCancel ? cancelButton : nil
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
        cell.delegate = self
        cell.levelItem = levelItem
        if isLevelItemSelected(levelItem) {
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        }
        cell.clipboardState = state.clipboard.getStateOf(levelItem: levelItem)
        cell.isRenaming = urlBeingRenamed != nil && urlBeingRenamed == levelItem.url
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
    
    // region collection view cell delegate
    func startRenaming(levelItem: LevelItem) {
        assert(levelItem.canBeRenamed)
        urlBeingRenamed = levelItem.url!
    }

    func rename(cell: LevelItemCollectionViewCell, newName: String) {
        urlBeingRenamed = nil

        let oldLevelItem = cell.levelItem!
        if oldLevelItem.label != newName {
            do {
                let newLevelItem = oldLevelItem.renamedTo(newName: newName)

                let oldUrl = oldLevelItem.url!
                let newUrl = newLevelItem.url!

                // Actually rename in the file system
                try FileManager.default.moveItem(at: oldUrl, to: newUrl)

                // Update the cell's name
                cell.levelItem = newLevelItem
            } catch {
                let errorAlert = UIAlertController(title: "Error renaming \(oldLevelItem.label) to \(newName)", message: error.localizedDescription, preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "Continue", style: .default))
                present(errorAlert, animated: true)
            }
        }
    }
    // endregion

    // region 3d touch previewing
    // Derived from https://stackoverflow.com/questions/51781903/3d-touch-registerforpreviewing-in-uicollectionviewcell
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let indexPath = collectionView.indexPathForItem(at: location),
           let cell = collectionView.cellForItem(at: indexPath) as! LevelItemCollectionViewCell?,
           hasPreviewFor(levelItem: cell.levelItem!) {
            let levelItem = cell.levelItem!
            let previewContentViewController = getPreviewViewControllerFor(levelItem: levelItem)
            let previewViewController = LevelItemPreviewViewController.new(content: previewContentViewController, levelItem: levelItem)
            previewViewController.previewActionItems = getPreviewActionItemsFor(levelItem: levelItem)
            previewingContext.sourceRect = cell.frame
            return previewViewController
        } else {
            return nil
        }
    }

    private func hasPreviewFor(levelItem: LevelItem) -> Bool {
        switch levelItem {
        case .newFolder, .newLevel:
            return false
        case .upDirectory, .folder(name: _, url: _), .level(name: _, url: _):
            return true
        }
    }

    private func getPreviewViewControllerFor(levelItem: LevelItem) -> UIViewController {
        guard let model = model else {
            fatalError("level picker in directory tried to preview without model")
        }

        do {
            switch levelItem {
            case .newFolder, .newLevel:
                fatalError("level item's type doesn't have a preview: \(levelItem)")
            case .upDirectory:
                let levelPickerInUpDirectory = try LevelPickerInDirectory(url: model.url.deletingLastPathComponent())
                return LevelPickerInDirectoryViewController.new(model: levelPickerInUpDirectory, state: state, canCancel: canCancel, delegate: delegate)
            case .folder(name: _, let url):
                let levelPickerInFolder = try LevelPickerInDirectory(url: url)
                return LevelPickerInDirectoryViewController.new(model: levelPickerInFolder, state: state, canCancel: canCancel, delegate: delegate)
            case .level(name: _, let url):
                let preview: UIImage
                do {
                    preview = try WorldFilePreview.readPreviewAt(url: url)
                } catch {
                    Logger.warn("failed to get preview for level at url '\(url)': \(error.localizedDescription)")
                    preview = WorldFilePreview.missingOrCorrupted
                }
                return LevelPreviewViewController.new(preview: preview)
            }
        } catch {
            Logger.warn("level picker in directory couldn't fetch data to preview \(levelItem): \(error.localizedDescription)")
            return LevelPickerInDirectoryViewController.errorPreviewViewController
        }
    }

    private func getPreviewActionItemsFor(levelItem: LevelItem) -> [UIPreviewActionItem] {
        switch levelItem {
        case .newFolder, .newLevel:
            fatalError("level item's type doesn't have a preview: \(levelItem)")
        case .upDirectory:
            return [
                UIPreviewAction(title: "Go Up", style: .selected) { _, _ in
                    self.forceTap(levelItem: levelItem, animated: true)
                }
            ]
        case .folder(name: _, let url):
            return getPreviewActionItemsFor(levelItem: levelItem, url: url)
        case .level(name: _, let url):
            return getPreviewActionItemsFor(levelItem: levelItem, url: url)
        }
    }

    private func getPreviewActionItemsFor(levelItem: LevelItem, url: URL) -> [UIPreviewActionItem] {
        guard let delegate = delegate else {
            Logger.warn("level picker in directory tried to get preview actions but it doesn't have a delegate, so it can't really perform any")
            return []
        }

        return [
            UIPreviewAction(title: "Open", style: .default) { _, _ in
                self.forceTap(levelItem: levelItem, animated: true)
            },
            UIPreviewAction(title: "Rename", style: .default) { _, _ in
                self.setupRenameFor(url: url)
            },
            UIPreviewAction(title: "Delete", style: .destructive) { _, _ in
                delegate.delete(url: url)
            }
        ]
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        let previewViewController = viewControllerToCommit as! LevelItemPreviewViewController
        let levelItem = previewViewController.levelItem
        forceTap(levelItem: levelItem, animated: false)
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

    private func updateSelectedCells(animated: Bool) {
        for indexPath in collectionView.indexPathsForVisibleItems {
            if let cell = collectionView.cellForItem(at: indexPath) as! LevelItemCollectionViewCell? {
                let levelItem = cell.levelItem!
                let shouldBeSelected = isLevelItemSelected(levelItem)
                if shouldBeSelected && !cell.isSelected {
                    collectionView.selectItem(at: indexPath, animated: animated, scrollPosition: [])
                } else if !shouldBeSelected && cell.isSelected {
                    collectionView.deselectItem(at: indexPath, animated: animated)
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
                [editButtonItem, pasteButton]
    }

    private func updateCellsInClipboard() {
        for cell in collectionView.visibleCells as! [LevelItemCollectionViewCell] {
            let levelItem = cell.levelItem!
            cell.clipboardState = state.clipboard.getStateOf(levelItem: levelItem)
        }
    }
    // endregion

    // region renaming
    func setupRenameFor(url: URL) {
        urlBeingRenamed = url
    }
    // endregion
    // endregion
}
