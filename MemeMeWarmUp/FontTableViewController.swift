//
//  FontTableViewController.swift
//  MemeMeWarmUp
//
//  Created by Brian Wilson on 8/27/21.
//

protocol FontProtocol {
    func getFont(font: String)
}

import UIKit

class FontTableViewController: UITableViewController {
    
    var delegate: FontProtocol?
    let fontDict = ["American Typewriter" : "AmericanTypewriter-CondensedBold", "Avenir Next": "AvenirNext-Bold", "Chalkboard" : "ChalkboardSE-Bold", "Futura" : "Futura-CondensedExtraBold", "Hoefler Text" : "HoeflerText-Black", "Impact" : "Impact"]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fontDict.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath)
        let key = Array(fontDict)[indexPath.row].key
        cell.textLabel?.text = key
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let key = Array(fontDict)[indexPath.row].key
        if let selectedFont = fontDict[key]  {
            delegate?.getFont(font: selectedFont)
        }
        dismiss(animated: true, completion: nil)
    }

    

}
