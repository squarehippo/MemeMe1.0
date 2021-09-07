//
//  SentMemesTableViewController.swift
//  MemeMeWarmUp
//
//  Created by Brian Wilson on 9/2/21.
//

import UIKit

class MemeTableViewCell: UITableViewCell {
    @IBOutlet weak var memeCellImageView: UIImageView!
    @IBOutlet weak var memeCellUpperText: UILabel!
    @IBOutlet weak var memeCellLowerText: UILabel!
}


class SentMemesTableViewController: UITableViewController {

    let appDelegte = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TableToDetailID" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let selectedRow = indexPath.row
                let destinationVC = segue.destination as! DetailViewController
                destinationVC.loadViewIfNeeded()
                destinationVC.currentMeme = appDelegte.memes[selectedRow]
                destinationVC.detailImageView?.image = appDelegte.memes[selectedRow].memedImage
            }
        } else {
            let destination = segue.destination as! MemeEditorViewController
            destination.dismissHandler = {
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegte.memes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SentItemsTableCellID", for: indexPath) as! MemeTableViewCell
        let memes = appDelegte.memes
        cell.memeCellImageView.image = memes[indexPath.row].image
        cell.memeCellUpperText.text = memes[indexPath.row].upperText.lowercased()
        cell.memeCellLowerText.text = memes[indexPath.row].lowerText.lowercased()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            appDelegte.memes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "TableToDetailID", sender: self)
    }
}
