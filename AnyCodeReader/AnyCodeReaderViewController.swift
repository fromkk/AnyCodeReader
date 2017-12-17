//
//  AnyCodeReaderViewController.swift
//  AnyCodeReader
//
//  Created by Kazuya Ueoka on 2017/12/16.
//

import UIKit
import AVFoundation

@objc public protocol AnyCodeReaderDelegate: class {
    
    func codeReaderViewController(_ viewController: AnyCodeReaderViewController, with results: [AnyCodeReaderResult])
    
}

@objc public class AnyCodeReaderViewController: UIViewController {
    
    private enum Localizations: String, Localizable {
        case error = "AnyCodeReader.Error"
        case notSupported = "AnyCodeReader.NotSupported"
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public var metadataObjectTypes: [AVMetadataObject.ObjectType]
    
    public weak var delegate: AnyCodeReaderDelegate?
    
    public init(metadataObjectTypes: [AVMetadataObject.ObjectType], delegate: AnyCodeReaderDelegate? = nil) {
        self.metadataObjectTypes = metadataObjectTypes
        
        self.delegate = delegate
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {
        super.loadView()
        
        setUpCameraView()
        
        view.addSubview(previewView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive(_:)), name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground(_:)), name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        cameraView?.sessionStart()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        cameraView?.sessionStop()
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: nil) { (_) in
            self.cameraView?.handle(deviceOrientation: UIApplication.shared.statusBarOrientation)
        }
    }
    
    var cameraView: AnyCodeReaderView?
    
    /// CameraViewを作成する
    ///
    /// - Parameters:
    ///   - device: AVCaptureDevice
    ///   - input: AVCaptureInput
    ///   - output: AVCaptureOutput
    /// - Returns: CameraView
    private func cameraView(with device: AVCaptureDevice, input: AVCaptureInput, output: AVCaptureOutput)  -> AnyCodeReaderView {
        let configuration = AnyCodeReaderView.Configuration(device: device, input: input, output: output, metadataObjectTypes: metadataObjectTypes)
        
        let cameraView = AnyCodeReaderView(configuration: configuration, delegate: self)
        cameraView.translatesAutoresizingMaskIntoConstraints = false
        return cameraView
    }
    
    /// CameraViewのセットアップをしたかどうか
    private var isSetUpCameraView: Bool = false
    
    /// CameraViewのセットアップ
    private func setUpCameraView() {
        guard !isSetUpCameraView else { return }
        defer { isSetUpCameraView = true }
        
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else {
            showNotSupportedAlert()
            return
        }
        
        guard let input = try? AVCaptureDeviceInput(device: device) else {
            showNotSupportedAlert()
            return
        }
        
        let output = AVCaptureStillImageOutput()
        
        let cameraView = self.cameraView(with: device, input: input, output: output)
        view.addSubview(cameraView)
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: cameraView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: cameraView, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: cameraView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: cameraView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.0, constant: 0.0),
            ])
        
        self.cameraView = cameraView
    }
    
    lazy var previewView: AnyCodePreviewView = {
        let view = AnyCodePreviewView()
        view.isHidden = true
        return view
    }()
    
    /// カメラが対応してない場合に表示するエラーのアラート
    private func showNotSupportedAlert() {
        let alertController = UIAlertController(title: Localizations.error.localize(), message: Localizations.notSupported.localize(), preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    @objc private func applicationDidBecomeActive(_ notification: Notification) {
        cameraView?.sessionStart()
    }
    
    @objc private func applicationDidEnterBackground(_ notification: Notification) {
        cameraView?.sessionStart()
    }
    
}

extension AnyCodeReaderViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if let firstMetadataObject = metadataObjects.first,
            let converted = cameraView?.videoLayer?.transformedMetadataObject(for: firstMetadataObject) {
            
            previewView.isHidden = false
                
            previewView.frame = converted.bounds
        } else {
            previewView.isHidden = true
        }
        
        let results: [AnyCodeReaderResult] = metadataObjects.flatMap { (metadataObject) -> AnyCodeReaderResult? in
            guard let metadataObject = metadataObject as? AVMetadataMachineReadableCodeObject,
                let stringValue: String = metadataObject.stringValue else { return nil }
            
            return AnyCodeReaderResult(objectType: metadataObject.type, text: stringValue)
        }
        
        delegate?.codeReaderViewController(self, with: results)
        
    }
    
}
