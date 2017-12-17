//
//  Localizable.swift
//  AnyCodeReader
//
//  Created by Kazuya Ueoka on 2017/12/16.
//

import Foundation

protocol Localizable: RawRepresentable {}

extension Localizable where RawValue == String {
    
    func localize(args: CVarArg? = nil) -> String {
        
        let bundle = Bundle(for: AnyCodeReaderViewController.self)
        
        let result = NSLocalizedString(rawValue, tableName: nil, bundle: bundle, value: "", comment: "")
        
        if let args = args {
            return String(format: result, args)
        }
        
        return result
    }
    
}
