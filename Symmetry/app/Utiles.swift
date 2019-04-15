//
//  Utiles.swift
//  StoryMateCamera
//
//  Created by Ahmed Allam on 2/26/19.
//  Copyright © 2019 TheD. GmbH. All rights reserved.
//

import UIKit
import AVKit

class Utiles {
    
    static func videoSnapshot(from url: URL) -> UIImage?{
         let asset = AVAsset(url: url)
        return generateSnapshot(from: asset)
    }
    
    static func videoSnapshot(from asset: AVAsset) -> UIImage?{
       return generateSnapshot(from: asset)
    }
    
    private static func generateSnapshot(from asset: AVAsset) -> UIImage?{

        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        let timestamp = CMTime(seconds: 1, preferredTimescale: 60)
        
        do{
            let cgImage = try imageGenerator.copyCGImage(at: timestamp, actualTime: nil)
            return UIImage(cgImage: cgImage)
        }catch{
            print("Failed to generate video snapshot")
            return nil
        }
    }
    
}
