//
//  ViewController.swift
//  AnyCodeReaderSample
//
//  Created by Kazuya Ueoka on 2017/12/16.
//

import UIKit
import AnyCodeReader

class ViewController: UIViewController, AnyCodeReaderDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(qrButton)
        layoutQrButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    lazy var qrButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), for: .normal)
        button.setTitle("QR", for: .normal)
        button.addTarget(self, action: #selector(handleTap(qrButton:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private func layoutQrButton() {
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: qrButton, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: qrButton, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.0, constant: 0.0),
            ])
    }

    @objc private func handleTap(qrButton: UIButton) {
        
        let codeReaderViewController = AnyCodeReaderViewController(metadataObjectTypes: [
            .ean13,
            .ean8,
            .qr
            ])
        codeReaderViewController.delegate = self
        
        let navigationController = UINavigationController(rootViewController: codeReaderViewController)
        present(navigationController, animated: true, completion: nil)
        
        self.codeReaderViewController = codeReaderViewController
    }
    
    weak var codeReaderViewController: AnyCodeReaderViewController?
    
    var lastCodeResult: AnyCodeReaderResult?

    func codeReaderViewController(_ viewController: AnyCodeReaderViewController, with results: [AnyCodeReaderResult]) {
        
        guard let result = results.first, nil == lastCodeResult else { return }
        
        lastCodeResult = result
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.codeReaderViewController?.dismiss(animated: true, completion: {
                debugPrint(#function, self.lastCodeResult)
            })
        }
        
    }
    
}

