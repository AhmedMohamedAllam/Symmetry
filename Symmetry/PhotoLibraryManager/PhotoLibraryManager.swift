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
    
    func containsAlbum(albumName: String) -> Bool {
        let fetchResult = createAlbumFetchResult(albumName)
        return fetchResult.count > 0
    }
    
    
    //MARK: - Create folder, save delete etc.
    func makeAlbum(albumName: String){
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
    func savePhotoToAlbum(albumName: String, photo:UIImage, completion: ((_ identifier: String?, _ error: Error?) -> Void)?){
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
    func saveVideoToAlbum(albumName: String, videoUrl:URL, completion: ((_ identifier: String?, _ error: Error?) -> Void)?){
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
    
    private func allAssetsFetchResult() -> PHFetchResult<PHAsset>{
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
        options.includeAssetSourceTypes = [.typeCloudShared, .typeiTunesSynced, .typeUserLibrary]
        let fetchResult = PHAsset.fetchAssets(with: options)
        return fetchResult
    }
    
    
    private func getPhoto(with asset: PHAsset, result: @escaping (_ image: UIImage?) -> Void){
        PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight), contentMode: .aspectFit, options: nil, resultHandler: {(image: UIImage?, _: [AnyHashable: Any]?) -> Void in
            result(image)
        })
    }
    
    private func getVideo(with asset: PHAsset, result: @escaping (_ asset: AVAsset?) -> Void){
        PHImageManager.default().requestAVAsset(forVideo: asset, options: nil) { (avAsset, avAudioMix, _) in
            result(avAsset)
        }
    }
   
    
    func getLatestAsset(completion: @escaping (_ image: UIImage?, _ videoAsset: AVAsset?) -> Void){
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
        options.includeAssetSourceTypes = [.typeCloudShared, .typeiTunesSynced, .typeUserLibrary]
        let fetchResult = PHAsset.fetchAssets(with: options)
        let latestAsset = fetchResult[0]
        
        if latestAsset.mediaType == .image{
            getPhoto(with: latestAsset) { (image) in
                completion(image, nil)
            }
        }else if latestAsset.mediaType == .video{
            getVideo(with: latestAsset) { (videoAsset) in
                completion(nil, videoAsset)
            }
        }else{
            completion(nil, nil)
        }
        
    }
    
    func getPhoto(with identifier: String, mode: PHImageRequestOptionsDeliveryMode) -> UIImage? {
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
    
    func containsPhoto(identifier: String) -> Bool {
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
    
    func deletePhoto(identifier: String) {
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
    
    private func createPhotoFetchResult(_ identifier: String? = nil) -> PHFetchResult<PHAsset>{
        let fetchOptions = PHFetchOptions()
        if let identifier = identifier{
            fetchOptions.predicate = NSPredicate(format: "localIdentifier = %@", identifier)
        }
        let fetchResult = PHAsset.fetchAssets(with: fetchOptions)
        return fetchResult
    }
    
}

