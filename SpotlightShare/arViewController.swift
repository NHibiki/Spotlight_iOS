//
//  ArCamera.swift
//  SpotlightShare
//
//  Created by NHibiki on 08/07/2017.
//  Copyright © 2017 NHibiki. All rights reserved.
//

import Foundation
import Material
import AVFoundation
import CoreMotion

class arViewController: UIViewController, AMapLocationManagerDelegate, AVCapturePhotoCaptureDelegate {
    
    fileprivate var exitButton: IconButton!
    fileprivate var photoBtn: IconButton!
    
    fileprivate var photoImageview: UIImageView!
    fileprivate var cursorImageview: UIImageView!
    
    fileprivate var captureSesssion: AVCaptureSession!
    fileprivate var cameraOutput: AVCapturePhotoOutput!
    fileprivate var previewLayer: AVCaptureVideoPreviewLayer!
    
    fileprivate var motionManager: CMMotionManager!
    fileprivate var locationManager: AMapLocationManager!
    
    @IBOutlet weak var capturedImage: UIImageView!
    
    lazy var locationM: CLLocationManager = {
        let locationM = CLLocationManager()
        locationM.delegate = self
        return locationM
    }()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.white
        
        locationManager = AMapLocationManager()
        locationManager.delegate = self
        locationManager.distanceFilter = 200
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.startUpdatingLocation()
        
        motionManager = CMMotionManager()
        motionManager.startAccelerometerUpdates()
        if CLLocationManager.headingAvailable() {
            locationM.startUpdatingHeading()
        }else {
            print("Error!")
        }
        
        prepareButtons()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}

extension arViewController {
    fileprivate func prepareButtons() {
        
        captureSesssion = AVCaptureSession()
        captureSesssion.sessionPreset = AVCaptureSessionPreset1280x720
        cameraOutput = AVCapturePhotoOutput()
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        if let input = try? AVCaptureDeviceInput(device: device) {
            if (captureSesssion.canAddInput(input)) {
                captureSesssion.addInput(input)
                if (captureSesssion.canAddOutput(cameraOutput)) {
                    captureSesssion.addOutput(cameraOutput)
                    previewLayer = AVCaptureVideoPreviewLayer(session: captureSesssion)
                    previewLayer.frame = view.bounds
                    view.layer.addSublayer(previewLayer)
                    captureSesssion.startRunning()
                }
            } else {
                print("issue here : captureSesssion.canAddInput")
            }
        } else {
            print("some problem here")
        }
        
        photoImageview = UIImageView(frame: view.layer.frame)
        view.addSubview(photoImageview)
        
        exitButton = IconButton(image: Icon.close, tintColor: Color.white)
        exitButton.pulseColor = rgba(1, 1, 1, 1)
        exitButton.pulseOpacity = 0.7
        exitButton.addTarget(self, action: #selector(exitButtonClick), for: .touchUpInside)
        view.layout(exitButton).bottom(20).left(20).width(60).height(60)
        
        photoBtn = IconButton(image: UIImage(named: "add.png"))
        photoBtn.pulseColor = Color.white
        photoBtn.pulseOpacity = 1
        
        cursorImageview = UIImageView(image: UIImage(named: "cursor.png"))
        view.layout(cursorImageview).center().width(20).height(20)
        
        photoBtn.addTarget(self, action: #selector(photoButtonClick), for: .touchUpInside)
        view.layout(photoBtn).bottom(20).centerHorizontally().width(60).height(60)
    }
}

extension arViewController {
    @objc
    fileprivate func exitButtonClick() {
        self.dismiss(animated: true)
    }
    
    @objc
    fileprivate func photoButtonClick() {
        self.present(AppNavigationController(rootViewController: editingViewController()), animated: true)
    }
}


extension arViewController {
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        if let error = error {
            print("error occure : \(error.localizedDescription)")
        }
        
        if  let sampleBuffer = photoSampleBuffer,
            let previewBuffer = previewPhotoSampleBuffer,
            let dataImage =  AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer:  sampleBuffer, previewPhotoSampleBuffer: previewBuffer) {
            //print(UIImage(data: dataImage)?.size as Any)
            
            let dataProvider = CGDataProvider(data: dataImage as CFData)
            let cgImageRef: CGImage! = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
            let image = UIImage(cgImage: cgImageRef, scale: 1.0, orientation: UIImageOrientation.right)
            
            self.capturedImage.image = image
        } else {
            print("some error here")
        }
    }
}

extension arViewController: CLLocationManagerDelegate {
    func amapLocationManager(_ manager: AMapLocationManager!, didUpdate location: CLLocation!, reGeocode: AMapLocationReGeocode?) {
        myPosition.savePos(location)
        //debugPrint(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        myPosition.savePos(manager.location)
        let angle = newHeading.magneticHeading
        let arc = CGFloat(angle / 1180 * Double.pi)
        
        if motionManager.isAccelerometerAvailable {
            if let data = motionManager.accelerometerData {
                myPosition.saveSens(Double(arc), data.acceleration.z)
            }
        }
        //debugPrint(myPosition.getData())
    }
}
