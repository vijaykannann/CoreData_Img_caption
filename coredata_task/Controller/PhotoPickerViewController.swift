//
//  PhotoPickerViewController.swift
//  coredata_task
//
//  Created by VJ's iMAC on 23/05/20.
//  Copyright © 2020 Deuglo. All rights reserved.
//

import UIKit
import Photos

protocol PhotoPickerDelegate {
    func getAllSelectedPhotoFromLibrary(photos: [PHAsset], arrSelectedIndex: [IndexPath])
}

class PhotoPickerViewController: UICollectionViewController {
    
    var delegate: PhotoPickerDelegate?
    var allPhotos : PHFetchResult<PHAsset>? = nil
    let photoHelper = PhotoHelper()
    var arrSelectedIndex = [IndexPath]() // This is selected cell Index array
    var arrSelectedData = [PHAsset]()
    
    private let imageCellIdentifier = "imageCell"
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: true);
        
        self.photoHelper.delegate = self
        self.photoHelper.requestPhotosFromGallery()
        self.collectionView.register(UINib(nibName: PhotoCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: self.imageCellIdentifier)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.navigationItem.title = "Selected Images \(self.arrSelectedData.count)"
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(self.saveImage(_:)))
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancelPhotos(_:)))
    }
    
    @IBAction func saveImage(_ sender: UIButton) {
        if self.arrSelectedData.count != 0 {
        if let delegate = self.delegate {
            delegate.getAllSelectedPhotoFromLibrary(photos: self.arrSelectedData, arrSelectedIndex: self.arrSelectedIndex)
        }
        self.navigationController?.popViewController(animated: true)
        } else {
            self.alert(message: "Please select atleast one image.")
        }
    }
    
    @IBAction func cancelPhotos(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }
}

extension PhotoPickerViewController: PhotoHelperDelegate {
    func photoFinishedLoading(result: PHFetchResult<PHAsset>?) {
        self.allPhotos = result
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
}

extension PhotoPickerViewController: UICollectionViewDelegateFlowLayout {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        if let _ = self.allPhotos {
            return 1
        }
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.allPhotos!.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: self.imageCellIdentifier, for: indexPath) as? PhotoCollectionViewCell {
            let asset = self.allPhotos![indexPath.row]
            
            cell.photoImgView.image = UIImage(named: "bg_image.png")
            self.photoHelper.getImageFromPHAsset(asset: asset, index: indexPath) { (image, index) in
                cell.photoImgView.image = image
            }
            
            if arrSelectedIndex.contains(indexPath) {
                cell.contentHolder.backgroundColor = UIColor.red
            }
            else {
                cell.contentHolder.backgroundColor = UIColor.white
            }
            
            cell.layoutSubviews()
            
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width/3, height: self.view.frame.width/3)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let strData = self.allPhotos![indexPath.item]
        
        
        if arrSelectedIndex.contains(indexPath) {
            arrSelectedIndex = arrSelectedIndex.filter { $0 != indexPath}
            arrSelectedData = arrSelectedData.filter { $0 != strData}
        }
        else {
            if self.arrSelectedIndex.count != 100 {
                arrSelectedIndex.append(indexPath)
                arrSelectedData.append(strData)
            } else {
                self.alert(message: "Can select only 100 images.")
            }
        }
        if self.arrSelectedIndex.count != 100 {
            collectionView.reloadItems(at: [indexPath])
            self.navigationItem.title = "Selected Images \(self.arrSelectedData.count)"
        }
    }
}


