//
//  MediaStore.swift
//  Symmetry
//
//  Created by Ahmed Allam on 2/9/19.
//  Copyright © 2019 Allam. All rights reserved.
//

import UIKit
import AVFoundation

class MediaStore {
    
    let appName = Constants.appName
    var libraryManager: PhotoLibraryManager!
    
    init(viewController: UIViewController) {
        libraryManager = PhotoLibraryManager()
        PhotoLibraryAuth.checkAuthorisationStatus(vc: viewController) { [weak self] granted in
            if granted{
                self?.createAppAlbum()
            }
        }
    }
    
    func savePhoto(_ image: UIImage){
        var newImage = image
        if isSquare(){
            newImage = image.squareImage()
        }
        self.libraryManager.savePhotoToAlbum(albumName: self.appName, photo: newImage){ identifier, error in
            print(identifier ?? "no identifier", error?.localizedDescription ?? "no error")
        }
    }
    
    
    
    func saveVideo(from originalUrl: URL){
        if isSquare(){
            let asset = AVURLAsset(url: originalUrl as URL)
            let duration = asset.duration.seconds
            try? VideoCrop.suqareCropVideo(seconds: duration, videoUrl: originalUrl as NSURL) { [weak self] croppedUrl in
                self?.saveVideoToLiberary(with: croppedUrl! as URL)
            }
        }else{
            saveVideoToLiberary(with: originalUrl)
        }
    }
    
    func saveVideoToLiberary(with url: URL){
        libraryManager.saveVideoToAlbum(albumName: appName, videoUrl: url) { (identifier, error) in
            print(identifier ?? "no identifier", error?.localizedDescription ?? "no error")
        }
    }
    
    func createAppAlbum(){
        if !libraryManager.containsAlbum(albumName: appName){
            libraryManager.makeAlbum(albumName: appName)
        }
    }
    
    private func isSquare() -> Bool{
        return UserDefaults.standard.bool(forKey: SettingsKeys.isSquared.rawValue)
    }
}
