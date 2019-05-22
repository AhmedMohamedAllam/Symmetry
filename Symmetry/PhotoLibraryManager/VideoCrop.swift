//  VideoCrop.swift
//  Symmetry
//
//  Created by Ahmed Allam on 5/18/19.
//  Copyright © 2019 Ahmed Allam. All rights reserved.
//

import Foundation
import Photos
import AVKit

struct VideoCrop {
    
    static func suqareCropVideo(seconds: Float64, videoUrl inputUrl: NSURL,completion: @escaping (_ outputURL : NSURL?) -> ()) throws {
        let asset = AVAsset(url: inputUrl as URL)
        guard  let videoTrack = asset.tracks(withMediaType: AVMediaType.video).first else {
            return
        }
        
        let assetComposition = AVMutableComposition()
        let frame1Time = CMTime(seconds: seconds, preferredTimescale: asset.duration.timescale)
        let trackTimeRange = CMTimeRangeMake(start: .zero, duration: frame1Time)
        
        guard let videoCompositionTrack = assetComposition.addMutableTrack(withMediaType: .video,
                                                                           preferredTrackID: kCMPersistentTrackID_Invalid) else {
                                                                            return
        }
        
        try videoCompositionTrack.insertTimeRange(trackTimeRange, of: videoTrack, at: CMTime.zero)
        
        if let audioTrack = asset.tracks(withMediaType: AVMediaType.audio).first {
            let audioCompositionTrack = assetComposition.addMutableTrack(withMediaType: AVMediaType.audio,
                                                                         preferredTrackID: kCMPersistentTrackID_Invalid)
            try audioCompositionTrack?.insertTimeRange(trackTimeRange, of: audioTrack, at: CMTime.zero)
        }
        
        //1. Create the instructions
        let mainInstructions = AVMutableVideoCompositionInstruction()
        mainInstructions.timeRange = CMTimeRangeMake(start: .zero, duration: asset.duration)
        
        //2 add the layer instructions
        let layerInstructions = AVMutableVideoCompositionLayerInstruction(assetTrack: videoCompositionTrack)
        
        let renderSize = CGSize(width: videoTrack.naturalSize.height,
                                height: videoTrack.naturalSize.height)
        let transform = getTransform(for: videoTrack)
        
        layerInstructions.setTransform(transform, at: CMTime.zero)
        layerInstructions.setOpacity(1.0, at: CMTime.zero)
        mainInstructions.layerInstructions = [layerInstructions]
        
        //3 Create the main composition and add the instructions
        
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = renderSize
        videoComposition.instructions = [mainInstructions]
        videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        
        let url = URL(fileURLWithPath: "\(NSTemporaryDirectory())TrimmedMovie.mp4")
        try? FileManager.default.removeItem(at: url)
        
        let exportSession = AVAssetExportSession(asset: assetComposition, presetName: AVAssetExportPresetHighestQuality)
        exportSession?.outputFileType = AVFileType.mp4
        exportSession?.shouldOptimizeForNetworkUse = true
        exportSession?.videoComposition = videoComposition
        exportSession?.outputURL = url
        exportSession?.exportAsynchronously(completionHandler: {
            
            DispatchQueue.main.async {
                
                if let url = exportSession?.outputURL, exportSession?.status == .completed {
                    UISaveVideoAtPathToSavedPhotosAlbum(url.path, nil, nil, nil)
                } else {
                    let error = exportSession?.error
                    print("error exporting video \(String(describing: error))")
                }
            }
        })
    }
    
    private static func getTransform(for videoTrack: AVAssetTrack) -> CGAffineTransform {
        
        let renderSize = CGSize(width: videoTrack.naturalSize.height,
                                height: videoTrack.naturalSize.height)
        let y = (videoTrack.naturalSize.width - videoTrack.naturalSize.height) / 2
        let cropFrame = CGRect(x: 0, y: y, width: videoTrack.naturalSize.height, height: videoTrack.naturalSize.height)
        let renderScale = renderSize.width / cropFrame.width
        let offset = CGPoint(x: -cropFrame.origin.x, y: -cropFrame.origin.y)
        let rotation = atan2(videoTrack.preferredTransform.b, videoTrack.preferredTransform.a)
        
        var rotationOffset = CGPoint(x: 0, y: 0)
        
        if videoTrack.preferredTransform.b == -1.0 {
            rotationOffset.y = videoTrack.naturalSize.width
        } else if videoTrack.preferredTransform.c == -1.0 {
            rotationOffset.x = videoTrack.naturalSize.height
        } else if videoTrack.preferredTransform.a == -1.0 {
            rotationOffset.x = videoTrack.naturalSize.width
            rotationOffset.y = videoTrack.naturalSize.height
        }
        
        var transform = CGAffineTransform.identity
        transform = transform.scaledBy(x: renderScale, y: renderScale)
        transform = transform.translatedBy(x: offset.x + rotationOffset.x, y: offset.y + rotationOffset.y)
        transform = transform.rotated(by: rotation)
        
        print("track size \(videoTrack.naturalSize)")
        print("preferred Transform = \(videoTrack.preferredTransform)")
        print("rotation angle \(rotation)")
        print("rotation offset \(rotationOffset)")
        print("actual Transform = \(transform)")
        return transform
    }

}
