//
//  PhotosViewController.swift
//  coredata_task
//
//  Created by VJ's iMAC on 23/05/20.
//  Copyright © 2020 Deuglo. All rights reserved.
//

import UIKit
import Photos
import iOSPhotoEditor
class PhotosViewController: UIViewController {

    var allPhotos : [PhotoModel] = []
    var tempPhotosAry: [PhotoModel] = []
    var selectedPhotos : [PHAsset] = []
    var arrSelectedIndex: [IndexPath] = []
    let photoHelper = PhotoHelper()
    var editingId:Int? = nil
    
    @IBOutlet weak var tableView: UITableView!
    private let photoCellIdentifier = "photoCell"
    private let finalPhotoCellIdentifier = "finalPhotoCell"
    var screenFlag = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        
        self.tableView.register(UINib(nibName: PhotoTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: photoCellIdentifier)
        self.tableView.register(UINib(nibName: FinalPhotoTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: finalPhotoCellIdentifier)
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        self.tableView.delegate = self
        self.tableView.dataSource = self
//        self.hideKeyboardWhenTappedAround()
        self.registerForKeyboardDidShowNotification(scrollView: self.tableView)
        self.registerForKeyboardWillHideNotification(scrollView: self.tableView)
        self.loadNavigation(flag: true)
    }

    // MARK:- Add photos from gallery
    @IBAction func addPhotosFromGallery(_ sender: UIButton) {
        if let controller = self.storyboard?.instantiateViewController(identifier: "PhotoPickerViewController") as? PhotoPickerViewController {
            controller.delegate = self
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func loadNavigation(flag: Bool) {
        self.screenFlag = flag
        if flag {
            let data = DBHelper()
             self.allPhotos = data.retrieveData()
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addPhotosFromGallery(_:)))
            self.navigationItem.leftBarButtonItem = nil
            self.navigationItem.title = "Photos"
            self.tableView.allowsSelection = true
            self.tableView.isUserInteractionEnabled = true
            
        } else {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(self.saveImage(_:)))
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: #selector(self.cancelPhotos(_:)))
            self.navigationItem.title = "Enter Captions and Comments"
            self.tableView.allowsSelection = false
            self.tableView.isUserInteractionEnabled = true
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @IBAction func saveImage(_ sender: UIButton) {
        
        for item in self.tempPhotosAry {
            
            guard item.caption != "" else {return alert(message: "Please fill caption")}
            guard item.comment != "" else {return alert(message: "Please fill comment")}

        }
        
        for item in self.tempPhotosAry {
            self.photoHelper.getImageFromPHAsset(asset: item.asset) { (image, _) in
                let db = DBHelper()
                db.createData(obj: item, image: image)
            }
        }
        self.tempPhotosAry.removeAll()
        
//        self.allPhotos.append(contentsOf: self.tempPhotosAry)
        self.selectedPhotos.removeAll()
        self.arrSelectedIndex.removeAll()
        self.loadNavigation(flag: true)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @IBAction func cancelPhotos(_ sender: UIButton) {
        if let controller = self.storyboard?.instantiateViewController(identifier: "PhotoPickerViewController") as? PhotoPickerViewController {
            controller.delegate = self
            controller.arrSelectedData = self.selectedPhotos
            controller.arrSelectedIndex = self.arrSelectedIndex
            self.navigationController?.pushViewController(controller, animated: false)
        }
    }
}


extension PhotosViewController: PhotoPickerDelegate {
    func getAllSelectedPhotoFromLibrary(photos: [PHAsset], arrSelectedIndex: [IndexPath]) {
        self.tempPhotosAry = []
        for item in photos {
            let obj = PhotoModel()
            obj.asset = item
            self.tempPhotosAry.append(obj)
        }
        self.selectedPhotos = photos
        self.arrSelectedIndex = arrSelectedIndex
        self.loadNavigation(flag: false)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension PhotosViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.screenFlag {
            return self.allPhotos.count
        } else {
            return self.tempPhotosAry.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return getPhotoCell(tableView, cellForRowAt: indexPath)
    }
    
    func getPhotoCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.screenFlag {
            let cell = tableView.dequeueReusableCell(withIdentifier: self.finalPhotoCellIdentifier, for: indexPath) as! FinalPhotoTableViewCell
            let obj = self.allPhotos[indexPath.row]
            cell.captionLbl.text = obj.caption
            cell.commentLbl.text = obj.comment
            cell.setCustomImage(image: obj.image)
            return cell
        } else {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.photoCellIdentifier, for: indexPath) as! PhotoTableViewCell
            let obj = self.tempPhotosAry[indexPath.row]
            self.photoHelper.getImageFromPHAsset(asset: obj.asset, index: indexPath, width: 700, height: 700) { (image, _) in
                cell.setCustomImage(image: image)
            }
            cell.captionTextField.text = obj.caption
            cell.captionTextField.bind(callback: { (value) in
                obj.caption = value
            })
            cell.commentTextField.text = obj.comment
            cell.commentTextField.bind(callback: { (value) in
                obj.comment = value
            })
            return cell
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.screenFlag {
            let obj = self.allPhotos[indexPath.row]
            editingId = indexPath.row
        let photoEditor = PhotoEditorViewController(nibName:"PhotoEditorViewController",bundle: Bundle(for: PhotoEditorViewController.self))

        //PhotoEditorDelegate
        photoEditor.photoEditorDelegate = self

        //The image to be edited
        photoEditor.image = obj.image

        //Stickers that the user will choose from to add on the image
//        photoEditor.stickers.append(UIImage(named: "sticker" )!)

        //Optional: To hide controls - array of enum control
        photoEditor.hiddenControls = [ .share, .save]

        //Optional: Colors for drawing and Text, If not set default values will be used
        photoEditor.colors = [.red,.blue,.green]

        //Present the View Controller
        present(photoEditor, animated: true, completion: nil)
        }
    }
}

extension PhotosViewController: PhotoEditorDelegate {
    func doneEditing(image: UIImage) {
        let item = self.allPhotos[editingId!]
        item.image = image
        let db = DBHelper()
        db.updateData(obj: item)
        self.editingId = nil
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func canceledEditing() {
        self.editingId = nil
    }
}
