//
//  GalleryViewController.swift
//  Camera
//
//  Created by Ahmed Allam on 2/18/19.
//  Copyright © 2019 TheD. GmbH. All rights reserved.
//


import UIKit
import MobileCoreServices
import Photos

protocol PhotoLibraryPickerProtocol {
    var delegate: PhotoLibraryPickerDelegate? {get set}
    func pickPhoto()
    func pickLatestThumbnail()
}

protocol PhotoLibraryPickerDelegate {
    func didPickImage(image: UIImage)
    func didPickVedio(url: URL)
    func latestThumbnail(image: UIImage?)
}

class PhotoLibraryPicker: NSObject, PhotoLibraryPickerProtocol {
    
    var imagePicker: UIImagePickerController!
    var viewController: UIViewController!
    var delegate: PhotoLibraryPickerDelegate?
    let photoLibraryManager = PhotoLibraryManager()

    init(viewController: UIViewController) {
        super.init()
        self.viewController = viewController
        imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        imagePicker.mediaTypes = [kUTTypeMovie as String, kUTTypeImage as String]
        imagePicker.delegate = self
    }
    
    func pickPhoto() {
        viewController.present(imagePicker, animated: true, completion: nil)
    }
    
    
    func pickLatestThumbnail(){
      photoLibraryManager.getLatestAsset { [weak self] (image, videoAsset) in
            if image != nil {
                self?.delegate?.latestThumbnail(image: image!)
            }else if videoAsset != nil{
                if let snapShot = Utiles.videoSnapshot(from: videoAsset!){
                    self?.delegate?.latestThumbnail(image: snapShot)
                }
            }
        }
    }

}

extension PhotoLibraryPicker: UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            delegate?.didPickImage(image: image)
        }else if let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL{
            self.delegate?.didPickVedio(url: videoUrl)
        }
        
        viewController.dismiss(animated: true, completion: nil)
    }
}
