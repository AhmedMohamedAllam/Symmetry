//
//  MainViewController.swift
//  Symmetry
//
//  Created by Allam on 11/5/18.
//  Copyright © 2018 Allam. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class CameraViewController: UIViewController {
    
    let defaults = UserDefaults.standard
    var imagePicker: UIImagePickerController = UIImagePickerController()
    var overlay: OverlayView!
    var appName: String = Constants.appName
    lazy var cameraRect: CGRect = {
        return getRectAfterOrientation(rect: self.imagePicker.view.frame)
    }()
    
    var didCapture = false
    var previousOrientation: UIDeviceOrientation = .portrait
    var mediaStore: MediaStore!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
         mediaStore = MediaStore(viewController: self)
        
        overlay = OverlayView(delegate: self)
        addDidChangeOverlaySettingsObserver()
        addDidChangeOrientationObserver()
        openCamera()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        didCapture = false
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
    }
    
    @objc func settingButtonAction(_ sender: UIButton!) {
        let mainStroyboard = UIStoryboard(name: "Main", bundle: nil)
        if let settingsViewController = mainStroyboard.instantiateViewController(withIdentifier: SettingsTableViewController.storyboardID) as? SettingsTableViewController{
            imagePicker.pushViewController(settingsViewController, animated: true)
        }
    }
   
    
    //    MARK- Camera Configuration
    func openCamera() {
        setupCamera()
        requestCameraAuthorization {[unowned self] granted in
            DispatchQueue.main.async {
                if granted {
                    self.present(self.imagePicker, animated: false, completion: nil)
                }
                else{
                    self.presentAlertController(with: self, title: "Camera access permission is denied!" ,
                                                message: "Change (\(self.appName)) all access permessions from settings first!")
                }
            }
        }
    }
    
    private func setupCamera(){
       
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
        }else{
            presentAlertController(with: self, title:"Device Error" , message: "Device doesn't contain a camera!")
            return
        }
        
        if let availableMediaTypes = UIImagePickerController.availableMediaTypes(for: imagePicker.sourceType){
            imagePicker.mediaTypes = availableMediaTypes
        }
        let rect = getRectAfterOrientation(rect: cameraRect)
        let overlayView = overlay.getOverlayView(frame: rect)
        
        imagePicker.cameraOverlayView = overlayView
        imagePicker.delegate = self
        
        removeOverlayAfterTakePhoto(from: imagePicker)
        addOverlayAfterRejectPhoto(from: imagePicker)
    }
    
    

    
    //Mark: - Camera Authorization
    private func requestCameraAuthorization(_ completion : @escaping (Bool) -> Void){
        let mediaType = AVMediaType.video
        
        
        
        if !isCameraAuthorized(for: mediaType){
            requestCameraAuthorization(for: mediaType, onComplete: completion)
        }else if !isPhotoLiberaryAuthorized(){
            requestPhotoLiberaryAuthorization(onComplete: completion)
        }else{
            completion(true)
        }
        
    }
    
    private func isCameraAuthorized(for mediaType: AVMediaType) -> Bool {
        let authStatus = AVCaptureDevice.authorizationStatus(for: mediaType)
        return authStatus == .authorized
    }
    
    private func isPhotoLiberaryAuthorized() -> Bool {
        let authStatus = PHPhotoLibrary.authorizationStatus()
        return authStatus == .authorized
    }
    
    private func requestCameraAuthorization(for mediaType: AVMediaType,onComplete comletion : @escaping (Bool) -> Void){
        AVCaptureDevice.requestAccess(for: mediaType) { comletion($0)}
    }
    private func requestPhotoLiberaryAuthorization(onComplete completion : @escaping (Bool) -> Void){
        PHPhotoLibrary.requestAuthorization{
            completion($0 == PHAuthorizationStatus.authorized)
        }
    }
    
    //    MARK:- Notification Observers
    private func removeOverlayAfterTakePhoto(from imagePicker: UIImagePickerController){
        NotificationCenter.default.addObserver(forName: NSNotification.Name.didCaptureItem, object:nil, queue:nil, using: {[weak self] note in
            self?.didCapture = true
            imagePicker.cameraOverlayView = nil
        })
    }
    
    private func addOverlayAfterRejectPhoto(from imagePicker: UIImagePickerController){
        NotificationCenter.default.addObserver(forName: NSNotification.Name.didRejectItem, object:nil, queue:nil, using: {[weak self] note in
            guard let self = self else {return}
            self.didCapture = false
            imagePicker.cameraOverlayView = self.overlay.getOverlayView(frame: self.cameraRect)
        })
    }
    
    private func addDidChangeOverlaySettingsObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(CameraViewController.didChangeOverlaySettings(_:)), name: NSNotification.Name.didChangeOverlaySettings, object: nil)
    }
    
    private func addDidChangeOrientationObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeOrientation(_:)), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    // will be executed if user tab done button in settings
    @objc func didChangeOverlaySettings(_ notification:Notification){
        updateOverlayView()
    }
    
    @objc func didChangeOrientation(_ notification:Notification){
        if !didCapture{
            updateOverlayView()
        }
    }
    
    private func isPortrait() -> Bool{
        var isPortrait: Bool {
            let orientation = UIDevice.current.orientation
            switch orientation {
            case .portrait, .portraitUpsideDown:
                 previousOrientation = .portrait
                return true
            case .landscapeLeft, .landscapeRight:
                previousOrientation = .landscapeLeft
                return false
            default: // unknown or faceUp or faceDown
//                guard let window = self.view.window else { return false }
//                return window.frame.size.width < window.frame.size.height
                if previousOrientation == .portrait{
                    return true
                }else{
                    return false
                }
            }
        }
       
        return isPortrait
    }
    
    
    private func getRectAfterOrientation(rect: CGRect) -> CGRect{
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
        // It's an iPhone
            return rect
        case .pad:
            var width: CGFloat = 0.0
            var height: CGFloat = 0.0
            
            if isPortrait(){
                width = (rect.width > rect.height) ? rect.height : rect.width
                height = (rect.width > rect.height) ? rect.width : rect.height
            }else{
                width = (rect.width > rect.height) ? rect.width : rect.height
                height = (rect.width > rect.height) ? rect.height : rect.width
            }
            return CGRect(x: 0.0, y: 0.0, width: width, height: height)
        default:
            return rect
        }
        
    }
    
    
    private func updateOverlayView(){
        let deviceHasCamera = UIImagePickerController.isSourceTypeAvailable(.camera)
        guard deviceHasCamera else {
            return
        }
        let rect = getRectAfterOrientation(rect: cameraRect)
        let overlayView =  overlay.getOverlayView(frame: rect)
        imagePicker.cameraOverlayView = overlayView
    }
    
}

extension CameraViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        didCapture = false
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        
        // To handle image
        if let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
            mediaStore.savePhoto(image)
        }
        // To handle video
        if let videoUrl = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.mediaURL)] as? NSURL{
            mediaStore.saveVideo(with: videoUrl as URL)
//            UISaveVideoAtPathToSavedPhotosAlbum(videoPath, self, nil, nil)
        }
        
        picker.dismiss(animated: false) {
            self.didCapture = false
            self.openCamera()
        }
    }
    
    
   
    
    private func presentAlertController(
        with viewController: UIViewController,
        title: String,
        message: String
        ) {
        let alertController = getAlertWith(title: title, message: message)
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    private func getAlertWith(title: String, message: String) -> UIAlertController{
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        return alertController
    }
}

extension CameraViewController: OverLayViewDelegate{
    func didPressSettingsButton() {
        let mainStroyboard = UIStoryboard(name: "Main", bundle: nil)
        let settingsViewController = mainStroyboard.instantiateViewController(withIdentifier: SettingsTableViewController.storyboardID) as? SettingsTableViewController
        imagePicker.pushViewController(settingsViewController!, animated: true)
    }
}

extension Notification.Name{
    static let didChangeOverlaySettings = NSNotification.Name(rawValue: "settingsDidChange")
    static let didCaptureItem =  NSNotification.Name(rawValue: "_UIImagePickerControllerUserDidCaptureItem")
    static let didRejectItem =  NSNotification.Name(rawValue: "_UIImagePickerControllerUserDidRejectItem")
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
