//
//  ViewController.swift
//  BasicMLApp
//
//  Created by Ajay on 1/7/18.
//  Copyright © 2018 Obsessed. All rights reserved.
//

import UIKit
import AVKit
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var aa = VNClassificationObservation()
    
    let identifierLabel = UILabel()
    let confidenceLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let captureSession = AVCaptureSession()
        
        captureSession.sessionPreset = .photo
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        
        captureSession.addInput(input)
        
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        view.layer.addSublayer(previewLayer)

        previewLayer.frame = view.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        
        captureSession.addOutput(dataOutput)
        
        
        
    }

    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        guard let model = try? VNCoreMLModel(for: Resnet50().model) else { return }
        
        let request = VNCoreMLRequest(model: model) { (finishReq, err) in
            
            guard let results = finishReq.results as? [VNClassificationObservation] else { return }
            
            guard let firstObservation = results.first else { return }
            
            print(firstObservation.identifier, firstObservation.confidence)
            
            self.aa = firstObservation
        }
        
        
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
        
        DispatchQueue.main.async {
        
        
            self.identifierLabel.frame = CGRect(x: 15, y: 0, width: 210, height: 100)
            self.view.addSubview(self.identifierLabel)
            self.identifierLabel.text = self.aa.identifier
        
            self.confidenceLabel.frame = CGRect(x: 260, y: 0, width: 100, height: 100)
            self.view.addSubview(self.confidenceLabel)
            self.confidenceLabel.text = String(self.aa.confidence)
        
        }
        
    }


}

