//
//  PhotoHelper.swift
//  coredata_task
//
//  Created by VJ's iMAC on 23/05/20.
//  Copyright © 2020 Deuglo. All rights reserved.
//

import UIKit
import Photos

protocol PhotoHelperDelegate {
    func photoFinishedLoading(result: PHFetchResult<PHAsset>?)
}

class PhotoHelper {
    var delegate: PhotoHelperDelegate?
    let manager = PHImageManager.default()
    let requestOptions = PHImageRequestOptions()
    
    func requestPhotosFromGallery() {
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status {
            case .authorized:
                print("Good to proceed")
                self.getPhotos()
            case .denied, .restricted:
                print("Not allowed")
            case .notDetermined:
                print("Not determined yet")
            @unknown default:
                print("default")
            }
        }
    }
    
    fileprivate func getPhotos() {
        
        // .highQualityFormat will return better quality photos
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let results: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        if let delegate = self.delegate {
            delegate.photoFinishedLoading(result: results)
        }
        //        if results.count > 0 {
        //            for i in 0..<results.count {
        //                let asset = results.object(at: i)
        //
        //            }
        //        } else {
        //            print("no photos to display")
        //        }
    }
    
    func getImageFromPHAsset (asset: PHAsset, index: IndexPath? = nil, width: Double? = 100, height: Double? = 100, completionHandler: @escaping ((UIImage, IndexPath?) -> Void)) {
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .opportunistic
        requestOptions.resizeMode = .exact
        
        let size = CGSize(width: width!, height: height!)

        manager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: requestOptions) { (image, _) in
            if let image = image {
                completionHandler(image, index)
            } else {
                print("error asset to image")
            }
        }
    }
}
