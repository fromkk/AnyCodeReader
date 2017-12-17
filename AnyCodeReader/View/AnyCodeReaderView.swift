//
//  ヒグチユウコ.swift
//  AnyCodeReader
//
//  Created by Kazuya Ueoka on 2017/12/16.
//

import UIKit
import AVFoundation

class AnyCodeReaderView: UIImageView {
    
    weak var metadataOutputObjectsDelegate: AVCaptureMetadataOutputObjectsDelegate?
    
    init(configuration: Configuration, delegate: AVCaptureMetadataOutputObjectsDelegate? = nil) {
        self.configuration = configuration
        
        self.metadataOutputObjectsDelegate = delegate
        
        super.init(image: nil)
        
        setupConfiguration()
        
        session.addOutput(metadataOutput)
        metadataOutput.metadataObjectTypes = configuration.metadataObjectTypes
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var bounds: CGRect {
        didSet {
            videoLayer?.frame = bounds
        }
    }
    
    /// 設定
    struct Configuration {
        var device: AVCaptureDevice
        var input: AVCaptureInput
        var output: AVCaptureOutput
        var metadataObjectTypes: [AVMetadataObject.ObjectType]
    }
    
    var configuration: Configuration {
        didSet {
            session.removeInput(oldValue.input)
            session.removeOutput(oldValue.output)
            
            setupConfiguration()
        }
    }
    
    private func setupConfiguration() {
        if session.canAddInput(configuration.input) {
            session.addInput(configuration.input)
        }
        
        if session.canAddOutput(configuration.output) {
            session.addOutput(configuration.output)
        }
    }
    
    lazy var metadataOutput: AVCaptureMetadataOutput = {
        let metadataOutput = AVCaptureMetadataOutput()
        if let delegate = metadataOutputObjectsDelegate {
            metadataOutput.setMetadataObjectsDelegate(delegate, queue: DispatchQueue.main)
        }
        metadataOutput.rectOfInterest = CGRect(x: 0.1, y: 0.1, width: 0.8, height: 0.8)
        return metadataOutput
    }()
    
    /// Videoを表示するレイヤー
    var videoLayer: AVCaptureVideoPreviewLayer?
    
    private func createVideoLayerIfNeeded() {
        guard nil == self.videoLayer else { return }
        
        let videoLayer = AVCaptureVideoPreviewLayer(session: session)
        videoLayer.frame = frame
        videoLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(videoLayer)
        self.videoLayer = videoLayer
    }
    
    private let session: AVCaptureSession = AVCaptureSession()
    
    /// セッションが動作しているかどうか
    var isSessionRunning: Bool {
        return session.isRunning
    }
    
    /// カメラのキャプチャを開始する
    func sessionStart() {
        guard !isSessionRunning else { return }
        
        createVideoLayerIfNeeded()
        handle(deviceOrientation: UIApplication.shared.statusBarOrientation)
        
        session.startRunning()
    }
    
    /// カメラのキャプチャを停止する
    func sessionStop() {
        guard isSessionRunning else { return }
        
        session.stopRunning()
    }
    
    /// フォーカス
    ///
    /// - Parameter point: CGPoint
    /// - Throws: LockForConfigurationError
    func focus(to point: CGPoint) throws {
        let focusPoint = convert(point: point)
        
        try configuration.device.lockForConfiguration()
        
        if configuration.device.isFocusModeSupported(.continuousAutoFocus) {
            configuration.device.focusPointOfInterest = focusPoint
            configuration.device.focusMode = .continuousAutoFocus
        }
        
        configuration.device.unlockForConfiguration()
    }
    
    /// 明るい場所
    ///
    /// - Parameter point: CGPoint
    /// - Throws: LockForConfigurationError
    func exposure(to point: CGPoint) throws {
        let exposurePoint = convert(point: point)
        
        try configuration.device.lockForConfiguration()
        
        if configuration.device.isExposureModeSupported(.continuousAutoExposure) {
            configuration.device.exposurePointOfInterest = exposurePoint
            configuration.device.exposureMode = .continuousAutoExposure
        }
        
        configuration.device.unlockForConfiguration()
    }
    
    /// UIKitの位置をAVFoundationの位置に変換する
    ///
    /// - Parameter point: CGPoint
    /// - Returns: CGPoint
    private func convert(point: CGPoint) -> CGPoint {
        return CGPoint(x: point.y / bounds.size.height, y: 1.0 - point.x / bounds.size.width)
    }
    
}

// MARK: - DeviceOrientation
extension AnyCodeReaderView {
    
    func handle(deviceOrientation: UIInterfaceOrientation) {
        switch deviceOrientation {
        case .landscapeLeft:
            videoLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.landscapeLeft
        case .landscapeRight:
            videoLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.landscapeRight
        case .portraitUpsideDown:
            videoLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portraitUpsideDown
        default:
            videoLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        }
        
    }
    
}
