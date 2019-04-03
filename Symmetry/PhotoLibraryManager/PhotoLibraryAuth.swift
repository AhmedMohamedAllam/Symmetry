//
//  CameraAuth.swift
//  Camera
//
//  Created by Ahmed Allam on 2/18/19.
//  Copyright © 2019 Ahmed Allam. All rights reserved.
//

import UIKit
import Photos

struct PhotoLibraryAuth {
   
    static func checkAuthorisationStatus(vc: UIViewController, completion: @escaping ((Bool) -> Void)) {
        
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            completion(true)
        case .denied:
            completion(false)
            self.settingsAlert(vc: vc, title: Constants.caution, message: Constants.photoLibraryMessage)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ (status) in
                if status == PHAuthorizationStatus.authorized{
                    completion(true)
                }else{
                    completion(false)
                    self.settingsAlert(vc: vc, title: Constants.caution, message: Constants.photoLibraryMessage)
                }
            })
        case .restricted:
            completion(false)
            self.settingsAlert(vc: vc, title: Constants.caution, message: Constants.photoLibraryMessage)
        }
    }
    
    //MARK: - SETTINGS ALERT
    static func settingsAlert(vc: UIViewController, title: String, message: String){
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
        vc.present(settingsAlert , animated: true, completion: nil)
    }
}
