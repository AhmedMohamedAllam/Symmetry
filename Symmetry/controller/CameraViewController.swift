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
import SwiftyCam

protocol CameraViewControllerDelegate {
    func camera(didTakePhoto photo: UIImage)
    func camera(didRecordVideo url: URL)
}

class CameraViewController: SwiftyCamViewController {
    
    @IBOutlet weak var overlayViewContainer: UIView!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var captureButton: SwiftyCamButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var galleryButton: UIButton!
    @IBOutlet weak var switchCameraButton: UIButton!
    @IBOutlet weak var galleryImage: UIImageView!
    @IBOutlet weak var recordCounterView: RecordCounterView!
    @IBOutlet var captureView: UIView!
    @IBOutlet var photoVideoView: PhotoOrVideoView!
    @IBOutlet weak var photoVideoViewCenterConstraint: NSLayoutConstraint!
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    private var mediaStore: MediaStore!
    private var photoLibraryPicker: PhotoLibraryPickerProtocol?
    var leftSwipe: UISwipeGestureRecognizer!
    var rightSwipe: UISwipeGestureRecognizer!
    var delegate: CameraViewControllerDelegate?
    
    private var isVideo: Bool = false {
        didSet{
            UIView.animate(withDuration: 1) { [unowned self] in
                self.updateCameraViews(self.isVideo)
            }
        }
    }
    private var isRecording: Bool = false{
        didSet{
            updateUIWhileRecording(isRecording)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoLibraryPicker = PhotoLibraryPicker(viewController: self)
        mediaStore = MediaStore(viewController: self)
        photoLibraryPicker!.delegate = self
        photoLibraryPicker?.pickLatestThumbnail()
        captureButton.delegate = self
        setupCamera()
        addSwipeGestureRecognizers()
        updatePhotoVideoViewCenter(isVideo)
        photoVideoView.delegate = self
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
        let overlayView =  OverlayView.getOverlayView(frame: overlayViewContainer.bounds)
        overlayView.removeFromSuperview()
        overlayViewContainer.addSubview(overlayView)
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: overlayViewContainer.topAnchor),
            overlayView.trailingAnchor.constraint(equalTo: overlayViewContainer.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: overlayViewContainer.bottomAnchor),
            overlayView.leadingAnchor.constraint(equalTo: overlayViewContainer.leadingAnchor)
            ])
        overlayViewContainer.layoutSubviews()
    }
    
    //MARK:- IBActions
    @IBAction func openGalleryPressed(_ sender: Any) {
        UIApplication.shared.open(URL(string:"photos-redirect://")!)
    }
    
    @IBAction func flashPressed(_ sender: Any) {
        let isFlashEnabled = (flashMode != .off)
        updateFlash(isOn: isFlashEnabled)
    }
    
    @IBAction func recordButtonPressed(_ sender: Any) {
        if isRecording{
            stopRecording()
        }else{
            startRecording()
        }
        isRecording = !isRecording
    }
    
    
    @IBAction func switchCameraPressed(_ sender: Any) {
        //swiftyCam method
        switchCamera()
    }
    
    //MARK:- Helper Methods
    
    private func updatePhotoVideoViewCenter(_ isVideo: Bool){
        let centerConstant = photoVideoView.calculateCenter(isVideo: isVideo)
        photoVideoViewCenterConstraint.constant = centerConstant
    }
    
    private func startRecording(){
        startVideoRecording()
        recordCounterView.startCounter()
    }
    
    private func stopRecording(){
        stopVideoRecording()
        recordCounterView.stopCounter()
    }
    
    private func setupCamera(){
        cameraDelegate = self
        flashMode = .off
        shouldUseDeviceOrientation = true
        swipeToZoom = false
        removeLongPressGestureRecognizer()
    }
    
    private func updateCameraViews(_ isVideo: Bool){
        captureButton.isHidden = isVideo
        recordButton.isHidden = !isVideo
        recordCounterView.isHidden = !isVideo
        updatePhotoVideoViewCenter(isVideo)
    }
    
    private func updateUIWhileRecording(_ isRecording: Bool){
        galleryImage.isHidden = isRecording
        galleryButton.isHidden = isRecording
        flashButton.isHidden = isRecording
        switchCameraButton.isHidden = isRecording
        photoVideoView.isHidden = isRecording
        settingsButton.isHidden = isRecording
    }
    
    private func removeLongPressGestureRecognizer(){
        if let recoginzers = captureButton.gestureRecognizers{
            let longPress = recoginzers[1]
            captureButton.removeGestureRecognizer(longPress)
        }
    }
    
    private func updateFlash(isOn: Bool){
        self.flashEnabled = !isOn
        let flashImage = flashEnabled ? UIImage(named: "flash on") : UIImage(named: "flash off")
        flashButton.setImage(flashImage, for: .normal)
    }
    
    private func didCapture(photo: UIImage){
        mediaStore.savePhoto(photo)
        galleryImage.image = photo
    }
    
    private func didRecord(videoUrl url: URL){
        mediaStore.saveVideo(with: url)
        if let snapshot = Utiles.videoSnapshot(from: url){
            galleryImage.image = snapshot
        }
    }
    
    
    //MARK:- Gesture recognizer
    func addSwipeGestureRecognizers(){
        leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        leftSwipe.delegate = self
        leftSwipe.direction = .left
        self.captureView.addGestureRecognizer(leftSwipe)
        self.view.addGestureRecognizer(leftSwipe)
        
        rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        rightSwipe.delegate = self
        rightSwipe.direction = .right
        self.captureView.addGestureRecognizer(rightSwipe)
        super.view.addGestureRecognizer(rightSwipe)
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizer.Direction.right {
            isVideo = true
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.left {
            isVideo = false
        }
    }
    
}


extension CameraViewController: PhotoLibraryPickerDelegate{
    
    func didPickImage(image: UIImage) {
    }
    
    func didPickVedio(url: URL) {
    }
    
    func latestThumbnail(image: UIImage?) {
        DispatchQueue.main.async { [weak self] in
            self?.galleryImage.image = image
        }
    }
    
}

extension CameraViewController:  SwiftyCamViewControllerDelegate{
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didTake photo: UIImage) {
        didCapture(photo: photo)
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didBeginRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
        // Called when startVideoRecording() is called
        recordButton.setImage(#imageLiteral(resourceName: "stop btn"), for: .normal)
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
        // Called when stopVideoRecording() is called
        recordButton.setImage(#imageLiteral(resourceName: "record btn"), for: .normal)
        
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishProcessVideoAt url: URL) {
        // Called when stopVideoRecording() is called and the video is finished processing
        // Returns a URL in the temporary directory where video is stored
        didRecord(videoUrl: url)
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFocusAtPoint point: CGPoint) {
        // Called when a user initiates a tap gesture on the preview layer
        // Will only be called if tapToFocus = true
        // Returns a CGPoint of the tap location on the preview layer
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didChangeZoomLevel zoom: CGFloat) {
        // Called when a user initiates a pinch gesture on the preview layer
        // Will only be called if pinchToZoomn = true
        // Returns a CGFloat of the current zoom level
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didSwitchCameras camera: SwiftyCamViewController.CameraSelection) {
        // Called when user switches between cameras
        // Returns current camera selection
    }
    
}

extension CameraViewController: PhotoVideoViewDelegate{
    func didTapVideo() {
        isVideo = true
    }
    
    func didTapPhoto() {
        isVideo = false
    }
}

// UIGestureRecognizerDelegate methods from parent
extension CameraViewController{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if gestureRecognizer is UISwipeGestureRecognizer  {
             return !isRecording
        }
        return true
    }
}

//will be called after user update settings
extension CameraViewController: SettingsTableViewControllerDelegate{
    func didChangeSettings(){
        overlayViewContainer.subviews.first?.removeFromSuperview()
        updateOverlayView()
    }
}
