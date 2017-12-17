//
//  AnyCodePreviewView.swift
//  AnyCodeReader
//
//  Created by Kazuya Ueoka on 2017/12/16.
//

import UIKit

final class AnyCodePreviewView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setUp()
    }
    
    private var isSetUp: Bool = false
    private func setUp() {
        guard !isSetUp else { return }
        defer { isSetUp = true }
        
        layer.borderColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1).cgColor
        layer.borderWidth = 2.0
    }
    
}
