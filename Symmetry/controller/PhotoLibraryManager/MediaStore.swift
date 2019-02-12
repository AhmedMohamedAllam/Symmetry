//
//  MediaStore.swift
//  Symmetry
//
//  Created by Ahmed Allam on 2/9/19.
//  Copyright © 2019 Allam. All rights reserved.
//

import UIKit

class MediaStore {
    
    let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as! String
    var libraryManager: PhotoLibraryManager!
    init(viewController: UIViewController) {
        libraryManager = PhotoLibraryManager()
        libraryManager.checkAuthorisationStatus(vc: viewController) { [weak self] granted in
            if granted{
                self?.createAppAlbum()
            }
        }
    }
    
    func savePhoto(_ image: UIImage){
        self.libraryManager.savePhotoToAlbum(albumName: self.appName, photo: image){ identifier, error in
            print(identifier ?? "no identifier", error?.localizedDescription ?? "no error")
        }
    }
    
    func saveVideo(with url: URL){
        libraryManager.saveVideoToAlbum(albumName: appName, videoUrl: url) { (identifier, error) in
            print(identifier ?? "no identifier", error?.localizedDescription ?? "no error")
        }
    }
    func createAppAlbum(){
        if !libraryManager.containsAlbum(albumName: appName){
            libraryManager.makeAlbum(albumName: appName)
        }
    }
}
