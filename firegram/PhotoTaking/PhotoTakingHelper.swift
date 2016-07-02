//
//  PhotoTakingHelper.swift
//  Makestagram
//
//  Created by Brian Hans on 6/22/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import UIKit

typealias PhotoTakingHelperCallback = (UIImage?, [String: AnyObject]? )-> Void

class PhotoTakingHelper: NSObject {
    
    weak var viewController: UIViewController!
    var callback: PhotoTakingHelperCallback
    var imagePickerController: UIImagePickerController?
    
    init(viewController: UIViewController, callback: PhotoTakingHelperCallback){
        self.viewController = viewController
        self.callback = callback
        
        super.init()
        
        //opens the file selection dialogue at the end of the constructor
        showPhotoSourceSelection()
    }
    
    func showPhotoSourceSelection(){
        //Let user pick source
        let alertController = UIAlertController(title: nil, message: "Where do you want to get your picture from?", preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let photoLibraryAction = UIAlertAction(title: "Camera Roll", style: .Default, handler: {(action) in
            //opens camera roll
            self.showImagePickerController(.PhotoLibrary)
        })
        
        
        alertController.addAction(photoLibraryAction)
        
        let signOutAction = UIAlertAction(title: "Sign Out", style: .Default){(action) in
            FirebaseHelper.signOut(){() in
                self.viewController.performSegueWithIdentifier(Constants.Segues.homeToSignIn, sender: nil)
            }
        }
        
        alertController.addAction(signOutAction)
        
        if(UIImagePickerController.isCameraDeviceAvailable(.Rear)){
            let cameraAction = UIAlertAction(title: "Camera", style: .Default, handler: {(action) in
                //open camera
                self.showImagePickerController(.Camera)
            })
            
            alertController.addAction(cameraAction)
        }
        
        viewController.presentViewController(alertController, animated: true, completion: nil)
        
        
    }
    
    func showImagePickerController(sourceType: UIImagePickerControllerSourceType){
        imagePickerController = UIImagePickerController()
        imagePickerController?.sourceType = sourceType
        imagePickerController?.delegate = self
        
        viewController.presentViewController(imagePickerController!, animated: true, completion: nil)
    }
    
    
}

//Handles the user selected image
extension PhotoTakingHelper: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        
        //runs the method from timelineviewcontroller which uploads the image to parse
        callback(image, editingInfo)
        viewController.dismissViewControllerAnimated(false, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        viewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
