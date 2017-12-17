//
//  AnyCodeReaderResult.swift
//  AnyCodeReader
//
//  Created by Kazuya Ueoka on 2017/12/16.
//

import Foundation
import AVFoundation

@objc public class AnyCodeReaderResult: NSObject {
    
    public var objectType: AVMetadataObject.ObjectType
    
    public var text: String
    
    public init(objectType: AVMetadataObject.ObjectType, text: String) {
        
        self.objectType = objectType
        
        self.text = text
        
        super.init()
        
    }
    
    public override var debugDescription: String {
        return String(format: "%@ {objectType: %@, text: %@}", super.debugDescription, objectType.rawValue, text)
    }
    
}
