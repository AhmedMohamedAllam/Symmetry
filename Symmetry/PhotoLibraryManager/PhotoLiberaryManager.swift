//
//  PhotoLibraryManager.swift
//  Symmetry
//
//  Created by Ahmed Allam on 2/9/19.
//  Copyright © 2019 Allam. All rights reserved.
//
import Foundation
import Photos

class PhotoLibraryManager: NSObject {
    fileprivate weak var currentVC: UIViewController?
    
    public func checkAuthorisationStatus(vc: UIViewController?, completion: @escaping ((Bool) -> Void)) {
        currentVC = vc
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            completion(true)
        case .denied:
            completion(false)
            self.settingsAlert(title: Constants.caution, message: Constants.photoLibraryMessage)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ (status) in
                if status == PHAuthorizationStatus.authorized{
                    completion(true)
                }else{
                    completion(false)
                    self.settingsAlert(title: Constants.caution, message: Constants.photoLibraryMessage)
                }
            })
        case .restricted:
            completion(false)
            self.settingsAlert(title: Constants.caution, message: Constants.photoLibraryMessage)
        }
    }
    
    public func containsAlbum(albumName: String) -> Bool {
       let fetchResult = createAlbumFetchResult(albumName)
        return fetchResult.count > 0
    }
    
    
    //MARK: - Create folder, save delete etc.
    public func makeAlbum(albumName: String){
        let fetchResult = createAlbumFetchResult(albumName)
        if fetchResult.count == 0 {
            var albumPlaceholder: PHObjectPlaceholder?
            PHPhotoLibrary.shared().performChanges({
                // Request creating an album with parameter name
                let createAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
                // Get a placeholder for the new album
                albumPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
            }, completionHandler: { success, error in
                guard albumPlaceholder != nil else {
                    assert(false, "Album placeholder is nil")
                    return
                }
            })
        }
    }
    
    //Saves photo and returns it's identifier
    public func savePhotoToAlbum(albumName: String, photo:UIImage, completion: ((_ identifier: String?, _ error: Error?) -> Void)?){
        let fetchResult = createAlbumFetchResult(albumName)
        if fetchResult.count > 0{
            let assetCollection = fetchResult.firstObject
            var localIdentifier: String?
            PHPhotoLibrary.shared().performChanges({
                let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: photo)
                let assetPlaceholder = assetChangeRequest.placeholderForCreatedAsset
                let assetCollectionChangeRequest = PHAssetCollectionChangeRequest(for: assetCollection!)
                let enumeration: NSArray = [assetChangeRequest.placeholderForCreatedAsset!]
                assetCollectionChangeRequest?.addAssets(enumeration)
                localIdentifier = assetPlaceholder?.localIdentifier
            }, completionHandler: { status, error in
                if status {
                    completion?(localIdentifier, error)
                }
                else{
                    completion?(nil, error)
                }
            })
        }
    }
    
    //Saves photo and returns it's identifier
    public func saveVideoToAlbum(albumName: String, videoUrl:URL, completion: ((_ identifier: String?, _ error: Error?) -> Void)?){
        let fetchResult = createAlbumFetchResult(albumName)
        if fetchResult.count > 0{
            let assetCollection = fetchResult.firstObject
            var localIdentifier: String?
            PHPhotoLibrary.shared().performChanges({
                guard let assetChangeRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoUrl) else {
                    completion?(nil, nil)
                    return
                }
                let assetPlaceholder = assetChangeRequest.placeholderForCreatedAsset
                let assetCollectionChangeRequest = PHAssetCollectionChangeRequest(for: assetCollection!)
                let enumeration: NSArray = [assetChangeRequest.placeholderForCreatedAsset!]
                assetCollectionChangeRequest?.addAssets(enumeration)
                localIdentifier = assetPlaceholder?.localIdentifier
            }, completionHandler: { status, error in
                if status {
                    completion?(localIdentifier, error)
                }
                else{
                    completion?(nil, error)
                }
            })
        }
    }
    
    
    
    
    
    public func getPhoto(with identifier: String, mode: PHImageRequestOptionsDeliveryMode) -> UIImage? {
        var savedImage: UIImage?
        let fetchResult = createPhotoFetchResult(identifier)
        if fetchResult.count > 0 {
            if let asset = fetchResult.firstObject {
                let options = PHImageRequestOptions()
                options.deliveryMode = mode
                options.isSynchronous = true
                PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight), contentMode: .aspectFit, options: options, resultHandler: {(image: UIImage?, _: [AnyHashable: Any]?) -> Void in
                    savedImage = image
                })
            }
        }
        return savedImage
    }
    
    public func containsPhoto(identifier: String) -> Bool {
        let fetchResult = createPhotoFetchResult(identifier)
        if fetchResult.count > 0 {
            if let asset = fetchResult.firstObject {
                let options = PHImageRequestOptions()
                //options.deliveryMode = .highQualityFormat
                options.isSynchronous = true
                //var result: UIImage?
                PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight), contentMode: .aspectFit, options: options, resultHandler: {(image: UIImage?, _: [AnyHashable: Any]?) -> Void in
                    //result = image
                })
                return true
            }
        }
        return false
    }
    
    public func deletePhoto(identifier: String) {
        let fetchResult = createPhotoFetchResult(identifier)
        if fetchResult.count > 0 {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.deleteAssets(fetchResult)
            }, completionHandler: {success, error in
                //print(success ? "Success" : error )
            })
        }
    }
    
    //MARK:- Fetch results
    
    private func createAlbumFetchResult(_ albumName: String) -> PHFetchResult<PHAssetCollection>{
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "localizedTitle == %@", albumName)
        let fetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        return fetchResult
    }
    
    private func createPhotoFetchResult(_ identifier: String) -> PHFetchResult<PHAsset>{
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "localIdentifier = %@", identifier)
        let fetchResult = PHAsset.fetchAssets(with: fetchOptions)
        return fetchResult
    }
    
    
    //MARK: - SETTINGS ALERT
    func settingsAlert(title: String, message: String){
        let settingsAlert = UIAlertController (title: title , message: message, preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: Constants.settings, style: .destructive) { (_) -> Void in
            let settingsUrl = NSURL(string:UIApplication.openSettingsURLString)
            if let url = settingsUrl {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
                } else {
                    // Fallback on earlier versions
                }
            }
        }
        let cancelAction = UIAlertAction(title: Constants.cancel, style: .default, handler: nil)
        settingsAlert.addAction(cancelAction)
        settingsAlert.addAction(settingsAction)
        currentVC?.present(settingsAlert , animated: true, completion: nil)
    }
}

struct Constants {
    static let photoLibraryMessage = "App does not have access to your photos. To enable access, tap settings and turn on Photo Library Access."
    static let settings = "Settings"
    static let cancel = "Cancel"
    static let caution = "Caution"
}
