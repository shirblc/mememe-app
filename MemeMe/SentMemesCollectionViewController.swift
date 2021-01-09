//
//  SentMemesCollectionViewController.swift
//  MemeMe
//
//  Created by Shir Bar Lev on 07/01/2021.
//

import UIKit

private let reuseIdentifier = "sentMemeCell"

class SentMemesCollectionViewController: UICollectionViewController {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var selectedMeme: Int?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addMeme(_:)))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(systemItem: .edit)
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return appDelegate.memes.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        let memeView = UIImageView(frame: CGRect(x: 0, y: 0, width: 90, height: 90))
        memeView.image = appDelegate.memes[indexPath.item].finalMeme
        memeView.contentMode = .scaleAspectFit
        cell.addSubview(memeView)
        
        return cell
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Handles meme selection
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedMeme = indexPath.item
        performSegue(withIdentifier: "addMemeSegue", sender: self)
    }
    
    // MARK: - Navigation

    // Prepare for segue to MemeViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // If the segue is to view/edit an existing meme, set the meme's index in the MemeViewController's property
        if let selectedMeme = selectedMeme {
            let detailView = segue.destination as! MemeViewController
            detailView.memeIndex = selectedMeme
        }
    }
    
    // MARK: UI Actions
    
    @objc func addMeme(_ sender: Any) {
        selectedMeme = nil
        performSegue(withIdentifier: "addMemeSegue", sender: sender)
    }
}
