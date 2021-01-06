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

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

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
        let cellImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 64, height: 64))
        PHImageManager.default().requestImage(for: availableImages[indexPath.item], targetSize: CGSize(width: 64, height: 64), contentMode: .default, options: nil, resultHandler: { (image, info) in
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
