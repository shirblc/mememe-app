//
//  SentMemesTableViewController.swift
//  MemeMe
//
//  Created by Shir Bar Lev on 07/01/2021.
//

import UIKit

private let reuseIdentifier = "sentMemeRow"

class SentMemesTableViewController: UITableViewController {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var selectedMeme: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register row classes
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        // Register navigation bar items
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addMeme(_:)))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(toggleEdit(_:)))
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate.memes.count
    }

    // Set up the table rows
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        let meme = appDelegate.memes[indexPath.item]
        
        // Set up the image and text
        cell.imageView?.image = meme.finalMeme
        cell.textLabel?.text = meme.topText + " " + meme.bottomText

        return cell
    }

    // Handles deleting a row (in editing mode).
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            appDelegate.memes.remove(at: indexPath.item)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    // Handle moving rows in editing mode.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let memeToMove = appDelegate.memes[fromIndexPath.item]
        appDelegate.memes.remove(at: fromIndexPath.item)
        appDelegate.memes.insert(memeToMove, at: to.item)
        tableView.reloadData()
    }
    
    // Handle row selection
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Trigger the segue to the the MemeDetail screen
        selectedMeme = indexPath.item
        performSegue(withIdentifier: "viewMemeSegue", sender: self)
    }

    // MARK: - Navigation

    // Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // If the segue is to view an existing meme, set the meme's index in the MemeDetailViewController's property
        if segue.identifier == "viewMemeSegue" {
            let detailView = segue.destination as! MemeDetailViewController
            detailView.memeIndex = selectedMeme
        }
    }
    
    // MARK: UI Actions
    
    // addMeme
    // Triggers the segue to the MemeEdit view in order to create a new meme
    @objc func addMeme(_ sender: Any) {
        selectedMeme = nil
        performSegue(withIdentifier: "addMemeSegue", sender: sender)
    }
    
    // toggleEdit
    // Start or end editing mode (depending on the user's current state).
    @objc func toggleEdit(_ sender: Any) {
        self.isEditing = !self.isEditing
        self.navigationItem.leftBarButtonItem?.title = self.isEditing ? "Done" : "Edit"
    }
}
