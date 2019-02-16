//
//  Constants.swift
//  Symmetry
//
//  Created by Ahmed Allam on 2/16/19.
//  Copyright © 2019 Ahmed Allam. All rights reserved.
//

import Foundation

struct Constants {
    static let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleExecutable") as! String
    static let photoLibraryMessage = "App does not have access to your photos. To enable access, tap settings and turn on Photo Library Access."
    static let settings = "Settings"
    static let cancel = "Cancel"
    static let caution = "Caution"
}
