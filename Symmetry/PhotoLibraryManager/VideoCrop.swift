//
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
    static func suqareCropVideo(inputURL: NSURL,seconds: Float64, completion: @escaping (_ outputURL : NSURL?) -> ())
    {
        let videoAsset: AVAsset = AVAsset( url: inputURL as URL )
        let clipVideoTrack = videoAsset.tracks( withMediaType: AVMediaType.video ).first! as AVAssetTrack
        
        let composition = AVMutableComposition()
        composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: CMPersistentTrackID())
        
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = CGSize( width: clipVideoTrack.naturalSize.height, height: clipVideoTrack.naturalSize.height )
        videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        
        let transformer = AVMutableVideoCompositionLayerInstruction(assetTrack: clipVideoTrack)
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: CMTimeMakeWithSeconds(seconds, preferredTimescale: 30))
        
        
        let transform1: CGAffineTransform = CGAffineTransform(translationX: clipVideoTrack.naturalSize.height, y: (clipVideoTrack.naturalSize.width - clipVideoTrack.naturalSize.height) / 2)
        let transform2 = transform1.rotated(by: .pi/2)
        let finalTransform = transform2
        
        
        transformer.setTransform(finalTransform, at: CMTime.zero)
        
        instruction.layerInstructions = [transformer]
        videoComposition.instructions = [instruction]
        
        // Export
        let exportSession = AVAssetExportSession(asset: videoAsset, presetName: AVAssetExportPresetHighestQuality)!
        print ("random id = \(NSUUID().uuidString)")
        
        let croppedOutputFileUrl = URL( fileURLWithPath: getOutputPath( NSUUID().uuidString) ) // CREATE RANDOM FILE NAME HERE
        exportSession.outputURL = croppedOutputFileUrl
        exportSession.outputFileType = AVFileType.mov
        exportSession.videoComposition = videoComposition
        exportSession.exportAsynchronously() {
            if exportSession.status == .completed {
                print("Export complete")
                DispatchQueue.main.async(execute: {
                    completion(croppedOutputFileUrl as NSURL)
                })
                return
            } else if exportSession.status == .failed {
                print("Export failed - \(String(describing: exportSession.error))")
            }
            
            completion(nil)
            return
        }
    }
    
    private static func getOutputPath( _ name: String ) -> String
    {
        let documentPath = NSSearchPathForDirectoriesInDomains(      .documentDirectory, .userDomainMask, true )[ 0 ] as NSString
        let outputPath = "\(documentPath)/\(name).mov"
        return outputPath
    }
}
