//
//  DBHelper.swift
//  coredata_task
//
//  Created by VJ's iMAC on 23/05/20.
//  Copyright © 2020 Deuglo. All rights reserved.
//

import UIKit
import CoreData

class DBHelper: NSObject {
    func createData(obj: PhotoModel, image: UIImage){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let userEntity = NSEntityDescription.entity(forEntityName: "PhotoEntity", in: managedContext)!
        let id = self.getLastStoredId()
        if id == 0 {
            return
        }
        let imgData = image.jpegData(compressionQuality: 1)
        let user = NSManagedObject(entity: userEntity, insertInto: managedContext)
        user.setValue(obj.caption, forKeyPath: "caption")
        user.setValue(obj.comment, forKey: "comment")
        user.setValue(imgData, forKey: "image")
        user.setValue(id, forKey: "id")
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func getLastStoredId() -> Int {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return 0 }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PhotoEntity")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        do {
            let result = try managedContext.fetch(fetchRequest)
            if let lastRecordID = result.first as? NSManagedObject {
                print(lastRecordID)
                if let value = lastRecordID.value(forKey: "id") as? Int {
                    return value + 1
                } else {
                    return 1
                }
            }
        }
        catch {
            
        }
        return 1
    }
    func retrieveData() -> [PhotoModel] {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return [] }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PhotoEntity")
        do {
            var arry:[PhotoModel] = []
            let result = try managedContext.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                let obj = PhotoModel()
                obj.caption = data.value(forKey: "caption") as! String
                obj.comment = data.value(forKey: "comment") as! String
                if let imageData = data.value(forKey: "image") as? Data {
                    if let image = UIImage(data: imageData) {
                        obj.image = image
                    }
                }
                obj.id = (data.value(forKey: "id") as! Int)
                arry.append(obj)
            }
            return arry
            
        } catch {
            
            print("Failed")
        }
        return []
    }
    
    
    func updateData(obj: PhotoModel){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "PhotoEntity")
        fetchRequest.predicate = NSPredicate(format: "id = %@", "\(obj.id!)")
        do
        {
            let test = try managedContext.fetch(fetchRequest)
            
            let objectUpdate = test[0] as! NSManagedObject
            objectUpdate.setValue(obj.caption, forKey: "caption")
            objectUpdate.setValue(obj.comment, forKey: "comment")
            let imgData = obj.image.jpegData(compressionQuality: 1)
            objectUpdate.setValue(imgData, forKey: "image")
            do{
                try managedContext.save()
            }
            catch
            {
                print(error)
            }
        }
        catch
        {
            print(error)
        }
        
    }
}
