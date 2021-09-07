//
//  DetailViewController.swift
//  MemeMeWarmUp
//
//  Created by Brian Wilson on 9/4/21.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailImageView: UIImageView?
    var currentMeme: Meme?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //Used to send data back to the main editor
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MemeEditorID" {
            let destinationVC = segue.destination as! MemeEditorViewController
            destinationVC.loadViewIfNeeded()
            destinationVC.imagePickerView.image = currentMeme?.image
            destinationVC.upperText.text = currentMeme?.upperText
            destinationVC.lowerText.text = currentMeme?.lowerText   
        }
    }
    
    @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "MemeEditorID", sender: self)
    }
}
