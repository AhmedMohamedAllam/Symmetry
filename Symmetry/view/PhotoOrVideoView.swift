//
//  PhotoOrVideoView.swift
//  StoryMateCamera
//
//  Created by Ahmed Allam on 2/26/19.
//  Copyright © 2019 TheD. GmbH. All rights reserved.
//

import UIKit

protocol PhotoVideoViewDelegate {
    func didTapPhoto()
    func didTapVideo()
}

class PhotoOrVideoView: UIView {
    
    
    @IBOutlet weak var photo: UILabel!
    @IBOutlet weak var video: UILabel!
    
    var delegate: PhotoVideoViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let photoTapGesture = UITapGestureRecognizer(target: self, action: #selector(photoTapped))
        let videoTapGesture = UITapGestureRecognizer(target: self, action: #selector(videoTapped))
        
        photo.addGestureRecognizer(photoTapGesture)
        video.addGestureRecognizer(videoTapGesture)
    }
    
    func calculateCenter(isVideo: Bool) -> CGFloat{
        updateUI(isVideo)
        if isVideo{
            let centerVideo = (video.frame.width / 2) + 14
            return centerVideo
        }else{
            let centerPhoto = (photo.frame.width / 2) + 10
            return centerPhoto * -1
        }
    }
    
    
    private func updateUI(_ isVideo: Bool){
        update(label: photo, isSelected: !isVideo)
        update(label: video, isSelected: isVideo)
    }
    
    private func update(label: UILabel, isSelected: Bool){
        let choosenColor = UIColor(displayP3Red: 255.0, green: 200.0, blue: 0, alpha: 1.0)
        label.textColor = isSelected ? choosenColor : UIColor.white
    }
    
    //    MARK:- Gesture Recognizer
    @objc private func photoTapped(){
        delegate?.didTapPhoto()
    }
    
    @objc private func videoTapped(){
        delegate?.didTapVideo()
    }
    
    
}
