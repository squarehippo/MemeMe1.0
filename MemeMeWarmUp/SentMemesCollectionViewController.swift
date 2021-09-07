//
//  SentMemesCollectionViewController.swift
//  MemeMeWarmUp
//
//  Created by Brian Wilson on 9/2/21.
//

import UIKit

class MemeCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var memeCollectionViewCellImage: UIImageView!
}


class SentMemesCollectionViewController: UICollectionViewController {
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    let appDelegte = UIApplication.shared.delegate as! AppDelegate
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        collectionView.reloadData()
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let space: CGFloat = 3.0
        
        let dimension = (view.frame.size.width - (2 * space)) / space
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.estimatedItemSize = CGSize(width: dimension, height: dimension + 20)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CollectionToDetailID" {
            if let indexPath = collectionView.indexPathsForSelectedItems?.first {
                let selectedRow = indexPath.row
                let destinationVC = segue.destination as! DetailViewController
                destinationVC.loadViewIfNeeded()
                destinationVC.currentMeme = appDelegte.memes[selectedRow]
                destinationVC.detailImageView?.image = appDelegte.memes[selectedRow].memedImage
            }
        } else {
            let destination = segue.destination as! MemeEditorViewController
            destination.dismissHandler = {
                self.collectionView.reloadData()
            }
        }
    }


    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return appDelegte.memes.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SentItemsCollectionViewID", for: indexPath) as! MemeCollectionViewCell
        
        cell.memeCollectionViewCellImage.image = appDelegte.memes[indexPath.row].image
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "CollectionToDetailID", sender: self)
    }
    
}
