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
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editMeme(_:)))

        if let memeIndex = memeIndex, memeIndex < appDelegate.memes.count {
            self.meme = appDelegate.memes[memeIndex]
            self.memePhotoView.image = meme?.finalMeme
        }
    }
    
    // MARK: UI & Navigation
    
    // shareMeme
    // Shares the current edit as an image.
    @IBAction func shareMeme(_ sender: Any) {
        let shareViewController = UIActivityViewController(activityItems: [ self.meme as Any ], applicationActivities: nil)
        present(shareViewController, animated: true, completion: nil)
    }
    
    // editMeme
    // Trigger a transition to meme edit screen.
    @objc func editMeme(_ sender: Any) {
        performSegue(withIdentifier: "editMemeSegue", sender: sender)
    }
    
    // Prepare for navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // If it's due to the edit button being pressed, set the Edit ViewController's memeIndex to the current meme's index.
        if segue.identifier == "editMemeSegue" {
            let editMemeVC = segue.destination as! MemeEditViewController
            editMemeVC.memeIndex = self.memeIndex
        }
    }
}
