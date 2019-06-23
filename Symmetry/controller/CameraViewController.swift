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
import CoreMotion

class CameraViewController: UIViewController {
    
    let defaults = UserDefaults.standard
    var flashMode = CameraFlashMode.auto
    var imagePicker: UIImagePickerController = UIImagePickerController()
    var appName: String = Constants.appName
    var cameraControlsView: CameraControlsView!
    var mediaStore: MediaStore!
    var uMM: CMMotionManager!
    var previousOrientation = UIDevice.current.orientation
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mediaStore = MediaStore(viewController: self)
        openCamera()
        updateOverlayView()
        saveStatusBarHeight()
    }
    
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        NotificationCenter.default.addObserver(self, selector: #selector(self.deviceRotated), name: UIDevice.orientationDidChangeNotification, object: nil)
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
    
    
    private func saveStatusBarHeight() {
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        UserDefaults.standard.set(statusBarHeight, forKey: "statusBarHeight")
    }
    
    private func changeFlashMode(with newFlashMode: CameraFlashMode){
        switch newFlashMode {
        case .off:
            imagePicker.cameraFlashMode = .off
        case .auto:
            imagePicker.cameraFlashMode = .auto
        case .on:
            imagePicker.cameraFlashMode = .on
        }
    }
    
    private func setupCamera(){
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
        }else{
            presentAlertController(with: self, title:"Device Error" , message: "Device doesn't contain a camera!")
            return
        }
        
//        if let availableMediaTypes = UIImagePickerController.availableMediaTypes(for: imagePicker.sourceType){
//            imagePicker.mediaTypes = availableMediaTypes
//        }
        
        imagePicker.cameraOverlayView = cameraControlsView
        imagePicker.delegate = self
        imagePicker.videoQuality = .typeHigh
        imagePicker.showsCameraControls = false
        translateCaptureViewToCenter()
    }
    

    
    @objc func deviceRotated(){
        switch UIDevice.current.orientation{
        case .portrait, .portraitUpsideDown:
            changeShouldRotate(false)
        case .landscapeLeft:
            changeShouldRotate(true)
        case .landscapeRight:
            changeShouldRotate(true)
        default:
            print("default")
        }
      
    }
    
    private func changeShouldRotate(_ bool: Bool){
        UserDefaults.standard.set(bool, forKey: "shouldRotate")
        updateOverlayView()
    }
    
    private func translateCaptureViewToCenter() {
        let screenHeight = UIScreen.main.bounds.size.height
        let screenWidth = UIScreen.main.bounds.size.width
        let imageHeight = screenWidth * (4/3)
        let headerHeight = (screenHeight - imageHeight) / 2
        let translate: CGAffineTransform = CGAffineTransform(translationX: 0.0, y: headerHeight)
        imagePicker.cameraViewTransform = translate
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
    
    
    // will be executed if user tab done button in settings
    @objc func didChangeOverlaySettings(_ notification:Notification){
        updateOverlayView()
    }
    
    @objc func didChangeOrientation(_ notification:Notification){
            updateOverlayView()
    }
    
    private func updateOverlayView(){
        cameraControlsView = CameraControlsView.loadFromNib()
        cameraControlsView.delegate = self
        imagePicker.cameraOverlayView = cameraControlsView
    }
    
}

extension CameraViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        
        // To handle image
        if let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
            cameraControlsView.updateGalleryImageView(with: image)
            mediaStore.savePhoto(image)
        }
        // To handle video
        if let videoUrl = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.mediaURL)] as? NSURL{
            saveVideo(with: videoUrl)
        }
        
//        picker.dismiss(animated: false) {
//            self.openCamera()
//        }
    }
    
    // Helper function inserted by Swift 4.2 migrator.
    fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
        return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
    }
    
    // Helper function inserted by Swift 4.2 migrator.
    fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
        return input.rawValue
    }
    
    private func saveVideo(with videoUrl: NSURL){
        self.mediaStore.saveVideo(from: videoUrl as URL)
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

extension CameraViewController: CameraControlsViewDelegate{
    func didPressFlashButton(newFlashMode: CameraFlashMode) {
        changeFlashMode(with: newFlashMode)
    }
    
    func didPressCaptureButton() {
        imagePicker.takePicture()
    }
    
    func didPressSwitchCamButton() {
        let currentCam = imagePicker.cameraDevice
        imagePicker.cameraDevice = currentCam == .rear ? .front : .rear
    }
    
    
    func didPressSettingsButton() {
        let mainStroyboard = UIStoryboard(name: "Main", bundle: nil)
        let settingsViewController = mainStroyboard.instantiateViewController(withIdentifier: SettingsTableViewController.storyboardID) as? SettingsTableViewController
        settingsViewController?.delegate = self
        imagePicker.pushViewController(settingsViewController!, animated: true)
    }
    
    
}




extension CameraViewController: SettingsTableViewControllerDelegate {
    func didChangeSettings(){
        updateOverlayView()
    }
}
