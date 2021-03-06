//
//  PhotosViewController.swift
//  Photorama
//
//  Created by Németh Bendegúz on 2018. 12. 29..
//  Copyright © 2018. Németh Bendegúz. All rights reserved.
//

import UIKit

class PhotosViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet var collectionView: UICollectionView!
    
    var store: PhotoStore!
    let photoDataSource = PhotoDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = photoDataSource
        collectionView.delegate = self
        
        updateDataSource()

        store.fetchInterestingPhotos { (photosResult) -> Void in
            self.updateDataSource()
        }
    }
    
    @IBAction func onSegmentedControlClick(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            photoDataSource.shouldUseFavoritePhotos = false
            updateDataSource()
        case 1:
            photoDataSource.shouldUseFavoritePhotos = true
            updateDataSource()
        default:
            print("Unexpected segmented control state")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let photo = photoDataSource.photosOfInterest[indexPath.row]
        
        store.fetchImage(for: photo) { (result) -> Void in
            
            guard let photoIndex = self.photoDataSource.photosOfInterest.index(of: photo), case let .success(image) = result else {
                return
            }
            
            let photoIndexPath = IndexPath(item: photoIndex, section: 0)
            
            if let cell = self.collectionView.cellForItem(at: photoIndexPath) as? PhotoCollectionViewCell {
                cell.update(with: image)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let widthHeight = collectionView.bounds.width / 4 - 2.5
        return CGSize(width: widthHeight, height: widthHeight)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showPhoto":
            if let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first {
                
                let photo = photoDataSource.photosOfInterest[selectedIndexPath.row]
                
                if let destinationVC = segue.destination as? PhotoInfoViewController {
                    destinationVC.photo = photo
                    destinationVC.store = store
                }
            }
        default:
            preconditionFailure("Unexpected segue identifier.")
        }
    }
    
    private func updateDataSource() {
        store.fetchAllPhotos { (photosResult) in
            switch photosResult {
            case let .success(photos):
                self.photoDataSource.photos = photos
            case .failure:
                self.photoDataSource.photos.removeAll()
            }
            self.collectionView.reloadSections(IndexSet(integer: 0))
        }
    }
    
}
