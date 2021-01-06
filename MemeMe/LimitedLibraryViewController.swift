//
//  LimitedLibraryViewController.swift
//  MemeMe
//
//  Created by Shir Bar Lev on 05/01/2021.
//

import UIKit
import PhotosUI

private let reuseIdentifier = "Cell"

// LimitedLibraryViewControllerDelegate
// Delegate for accessing the limited library.
// -------------------------------------------
protocol LimitedLibraryViewControllerDelegate {
    // userDidSelectImage - Use this method to get the image selected by the user
    func userDidSelectImage(_ controller: LimitedLibraryViewController)
    // userDidCancel - Use this method to dismiss the picker if the user decides to cancel
    func userDidCancel(_ controller: LimitedLibraryViewController, sender: Any)
}

// LimitedLibraryViewController
// Custom ViewController for a limited library access scenario (iOS14+).
// -------------------------------------------
class LimitedLibraryViewController: UICollectionViewController {
    var availableImages = PHAsset.fetchAssets(with: nil)
    var displayImages: [UIImage] = []
    var selectedImage: PHAsset?
    var selectedImagePath: IndexPath?
    var delegate: LimitedLibraryViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView!.allowsMultipleSelection = false
        self.collectionView!.allowsSelection = true
        self.collectionView!.delegate = self
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return availableImages.count
    }
    
    // Set up the header
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerView", for: indexPath)
        
        return header
    }

    // Set up the collection view cells
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Set up the cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        // Fetch the image for the cell
        let cellImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 90, height: 90))
        PHImageManager.default().requestImage(for: availableImages[indexPath.item], targetSize: CGSize(width: 90, height: 90), contentMode: .default, options: nil, resultHandler: { (image, info) in
            if let image = image {
                cellImage.image = image
                cellImage.contentMode = .center
                self.displayImages.append(image)
            }
        })
        cell.addSubview(cellImage)
    
        return cell
    }

    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Check if the user is tapping the same cell; if so, deselect it and set the screen appropriately
        if let previousPath = self.selectedImagePath, indexPath == previousPath {
            collectionView.deselectItem(at: indexPath, animated: true)
            if let cell = collectionView.cellForItem(at: indexPath) {
                cell.subviews[1].removeFromSuperview()
            }
            self.selectedImagePath = nil
            self.selectedImage = nil
            return
        }
        
        // Remove the checkmark from the previous image's cell, if there was one.
        if let selectedImagePath = selectedImagePath, let cell = collectionView.cellForItem(at: selectedImagePath) {
            cell.subviews[1].removeFromSuperview()
        }
        
        // If there's a cell in that index path, show a checkmark to let the user know it's selected.
        if let cell = collectionView.cellForItem(at: indexPath) {
            let checkedIcon = UIImage(systemName: "checkmark.circle.fill", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))
            let checkedIconView = UIImageView(image: checkedIcon?.withRenderingMode(.alwaysTemplate))
            checkedIconView.tintColor = UIColor(named: "checkmarkColour")
            checkedIconView.frame = CGRect(x: 60, y: 60, width: 30, height: 28)
            cell.addSubview(checkedIconView)
        }
        
        self.selectedImagePath = indexPath
        self.selectedImage = self.availableImages[indexPath.item]
    }

    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // MARK: UI Actions
    // createMemeFromSelected
    // Sends the selected image to the delegate.
    @IBAction func createMemeFromSelected(_ sender: Any) {
        self.delegate?.userDidSelectImage(self)
    }

    // cancelSelection
    // Alerts the delegate the user decided to cancel the action.
    @IBAction func cancelSelection(_ sender: Any) {
        self.delegate?.userDidCancel(self, sender: sender)
    }
}
