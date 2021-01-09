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
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addMeme(_:)))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(systemItem: .edit)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate.memes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        let meme = appDelegate.memes[indexPath.item]
        
        cell.imageView?.image = meme.finalMeme
        cell.textLabel?.text = meme.topText + " " + meme.bottomText

        return cell
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    
    // Handle row selection
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedMeme = indexPath.item
        performSegue(withIdentifier: "viewMemeSegue", sender: self)
    }

    // MARK: - Navigation

    // Prepare for segue to MemeViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // If the segue is to view/edit an existing meme, set the meme's index in the MemeViewController's property
        if segue.identifier == "viewMemeSegue" {
            let detailView = segue.destination as! MemeDetailViewController
            detailView.memeIndex = selectedMeme
        }
    }
    
    // MARK: UI Actions
    
    @objc func addMeme(_ sender: Any) {
        selectedMeme = nil
        performSegue(withIdentifier: "addMemeSegue", sender: sender)
    }
}
