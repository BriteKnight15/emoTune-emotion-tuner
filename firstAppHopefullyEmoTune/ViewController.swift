//
//  ViewController.swift
//  firstAppHopefullyEmoTune
//
//  Created by Admin on 1/14/25.
//

import Foundation
import SwiftUI
import UIKit
import AVFoundation
import AVKit

class ViewController: UIViewController {
    
    var selectedUIImage: Binding<UIImage?> = .constant(nil)
    
    // capture session
    var session: AVCaptureSession?
    
    // photo output
    let output = AVCapturePhotoOutput()
    
    // video preview
    let previewLayer = AVCaptureVideoPreviewLayer()
    
    // shutter button
    private let shutterButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        button.layer.cornerRadius = 50
        button.layer.borderWidth = 10
        button.layer.borderColor = UIColor.white.cgColor
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .black
        view.layer.addSublayer(previewLayer)
        view.addSubview(shutterButton)
        checkCameraPermissions()
        
        shutterButton.addTarget(self, action: #selector(didTapTakePhoto), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
        
        shutterButton.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height * 7/8)
    }
    
    private func checkCameraPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            
        case .notDetermined:
            //Request
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { [weak self] granted in
                guard granted else {
                    return
                }
                DispatchQueue.main.async {
                    self?.setUpCameraFront()
                }
                
            })
        case .restricted:
            // :(
            break
        case .denied:
            // :(
            break
        case .authorized:
            // :)
            setUpCameraFront()
        @unknown default:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { [weak self] granted in
                guard granted else {
                    return
                }
                DispatchQueue.main.async {
                    self?.setUpCameraFront()
                }
                
            })
        }
    }
    
    private func setUpCameraFront() {
        let session = AVCaptureSession()
            if let device = AVCaptureDevice.default(_: .builtInWideAngleCamera, for: .video, position: .front) {
                do {
                    let input = try AVCaptureDeviceInput(device: device)
                    if session.canAddInput(input) {
                        session.addInput(input)
                    }
                    if session.canAddOutput(output) {
                        session.addOutput(output)
                    }
                    
                    previewLayer.videoGravity = .resizeAspectFill
                    previewLayer.session = session
                    
                    session.startRunning()
                    self.session = session
                } catch {
                    print(error)
                }
            }
    }
    
    @objc private func didTapTakePhoto() {
        output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
    }

}

extension ViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation() else {
            return
        }
        
        let image = UIImage(data: data)
        selectedUIImage.wrappedValue = image
        
        session?.stopRunning()
        
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.frame = view.bounds
        view.addSubview(imageView)
    }
}

struct HostedViewController: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    
    func makeUIViewController(context: Context) -> UIViewController {
        let vc = ViewController()
        vc.selectedUIImage = $image
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
    
    typealias UIViewControllerType = UIViewController
}
