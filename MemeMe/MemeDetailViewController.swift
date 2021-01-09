//
//  MemeDetailViewController.swift
//  MemeMe
//
//  Created by Shir Bar Lev on 09/01/2021.
//

import UIKit

class MemeDetailViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet var memePhotoView: UIImageView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var memeIndex: Int?
    var meme: Meme?

    // MARK: View
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let memeIndex = memeIndex, memeIndex < appDelegate.memes.count {
            self.meme = appDelegate.memes[memeIndex]
            self.memePhotoView.image = meme?.finalMeme
        }
    }
    
    // MARK: UI
    
    // shareMeme
    // Shares the current edit as an image.
    @IBAction func shareMeme(_ sender: Any) {
        let shareViewController = UIActivityViewController(activityItems: [ self.meme as Any ], applicationActivities: nil)
        present(shareViewController, animated: true, completion: nil)
    }
}
