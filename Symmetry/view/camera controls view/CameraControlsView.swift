//
//  CameraControlsView.swift
//  Symmetry
//
//  Created by Ahmed Allam on 6/17/19.
//  Copyright © 2019 Ahmed Allam. All rights reserved.
//

import UIKit

protocol CameraControlsViewDelegate {
    func didPressSettingsButton()
    func didPressFlashButton(newFlashMode: CameraFlashMode)
    func didPressCaptureButton()
    func didPressSwitchCamButton()
}

class CameraControlsView: UIView {
    
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var flashImageView: UIImageView!
    @IBOutlet weak var galleryImageView: UIImageView!
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var switchCamButton: UIButton!
    
    private var overlay: OverlayView!
    private var flashMode = CameraFlashMode.auto
    var delegate: CameraControlsViewDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        overlay = OverlayView()
        
    }
    
    class func loadFromNib() -> CameraControlsView? {
        let view: CameraControlsView = self.loadFromNib(withName: "CameraControlsView")!
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.width),
            view.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.height)
            ])
        view.addOverlayShape()
        configureSquare(for: view)
        return view
    }
    
    
    //MARK:- Actions
    @IBAction func didPressSettingsButton(_ sender: Any) {
        delegate?.didPressSettingsButton()
    }
    
    @IBAction func didPressFlashButton(_ sender: Any) {
        let newFlashMode = changeFlashMode()
        changeFlashImage(with: newFlashMode)
        delegate?.didPressFlashButton(newFlashMode: newFlashMode)
    }
    
    
    @IBAction func didPressCaptureButton(_ sender: Any) {
        delegate?.didPressCaptureButton()
    }
    
    @IBAction func didPressSwitchCamButton(_ sender: Any) {
        delegate?.didPressSwitchCamButton()
    }
    
    private func activateSquare() {
        heightConstraint.setMultiplier(multiplier: 1.0)
    }
    
    private func deactivateSquare() {
        heightConstraint.setMultiplier(multiplier: 3/4)
    }
    
    
    
    
    //MARK:- private methods
    
    private func changeFlashMode() -> CameraFlashMode {
        guard let newFlashMode = CameraFlashMode(rawValue: (flashMode.rawValue+1)%3) else { return flashMode }
        flashMode = newFlashMode
        return flashMode
    }
    
    private func changeFlashImage(with newFlashMode: CameraFlashMode){
        switch newFlashMode {
        case .off:
            flashImageView.image = UIImage(named: "flash off")
        case .on:
            flashImageView.image = UIImage(named: "flash on")
        case .auto:
            flashImageView.image = UIImage(named: "flash auto")
        }
    }
    
    private func addOverlayShape(){
        let overlayShape = OverlayView.overlayShape(with: previewView.bounds)
        overlayShape.translatesAutoresizingMaskIntoConstraints = false
        previewView.addSubview(overlayShape)
        
        NSLayoutConstraint.activate([
            overlayShape.widthAnchor.constraint(equalTo: previewView.widthAnchor),
            overlayShape.heightAnchor.constraint(equalTo: previewView.heightAnchor),
            overlayShape.centerXAnchor.constraint(equalTo: previewView.centerXAnchor),
            overlayShape.centerYAnchor.constraint(equalTo: previewView.centerYAnchor)
            ])
    }
    
    private static func configureSquare(for view: CameraControlsView){
        let isSquare =  UserDefaults.standard.bool(forKey: SettingsKeys.isSquared.rawValue)
        isSquare ? view.activateSquare() : view.deactivateSquare()
    }
    
}

extension CameraControlsView: SettingsTableViewControllerDelegate {
    func didChangeSettings(){
//        updateOverlayView()
    }
}

public enum CameraFlashMode: Int {
    case off, on, auto
}
