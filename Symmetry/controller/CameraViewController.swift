//
//  ViewController.swift
//  Camera
//
//  Created by Ahmed Allam on 2/17/19.
//  Copyright © 2019 Allam All rights reserved.
//

import UIKit
import Photos
import AVKit

protocol CameraViewControllerDelegate {
    func camera(didTakePhoto photo: UIImage)
    func camera(didRecordVideo url: URL)
}

class CameraViewController: UIViewController {
    
    @IBOutlet weak var overlayViewContainer: UIView!
    
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var galleryButton: UIButton!
    @IBOutlet weak var galleryImage: UIImageView!
   
    @IBOutlet weak var overlayViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var overlayViewBottomConstraint: NSLayoutConstraint!

    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    private var mediaStore: MediaStore!
    private var photoLibraryPicker: PhotoLibraryPickerProtocol?
    var leftSwipe: UISwipeGestureRecognizer!
    var rightSwipe: UISwipeGestureRecognizer!
    var delegate: CameraViewControllerDelegate?
    var currentOverlayView: UIView!
    var imagePicker: UIImagePickerController!
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoLibraryPicker = PhotoLibraryPicker(viewController: self)
        mediaStore = MediaStore(viewController: self)
        photoLibraryPicker!.delegate = self
        photoLibraryPicker?.pickLatestThumbnail()
        setupCamera()
        updateOverlayView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "settingsSegue",
            let settingsNavigationController = segue.destination as? UINavigationController,
            let settingsVC = settingsNavigationController.viewControllers.first as? SettingsTableViewController{
            settingsVC.delegate = self
        }
    }
    
    @objc func updateOverlayView(){
        overlayViewContainer.subviews.first?.removeFromSuperview()
        currentOverlayView =  OverlayView.getOverlayView(frame: overlayViewContainer.bounds)
        currentOverlayView.removeFromSuperview()
        overlayViewContainer.addSubview(currentOverlayView)
        currentOverlayView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            currentOverlayView.topAnchor.constraint(equalTo: overlayViewContainer.topAnchor),
            currentOverlayView.trailingAnchor.constraint(equalTo: overlayViewContainer.trailingAnchor),
            currentOverlayView.bottomAnchor.constraint(equalTo: overlayViewContainer.bottomAnchor),
            currentOverlayView.leadingAnchor.constraint(equalTo: overlayViewContainer.leadingAnchor)
            ])
        overlayViewContainer.layoutSubviews()
    }
    
    //MARK:- IBActions
    @IBAction func openGalleryPressed(_ sender: Any) {
        UIApplication.shared.open(URL(string:"photos-redirect://")!)
    }
    
    //MARK:- Helper Methods
    
   
    private func setupCamera(){
        imagePicker = UIImagePickerController(rootViewController: self)
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    
//    private func didCapture(photo: UIImage){
//        mediaStore.savePhoto(photo)
//        galleryImage.image = photo
//    }
//
//    private func didRecord(videoUrl url: URL){
//        mediaStore.saveVideo(with: url)
//        if let snapshot = Utiles.videoSnapshot(from: url){
//            galleryImage.image = snapshot
//        }
//    }
    
    
    
}


extension CameraViewController: PhotoLibraryPickerDelegate{
    
    func didPickImage(image: UIImage) {
    }
    
    func didPickVedio(url: URL) {
    }
    
    func latestThumbnail(image: UIImage?) {
//        DispatchQueue.main.async { [weak self] in
//            self?.galleryImage.image = image
//        }
    }
    
}

//will be called after user update settings
extension CameraViewController: SettingsTableViewControllerDelegate{
    func didChangeSettings(){
        updateOverlayView()
    }
}
