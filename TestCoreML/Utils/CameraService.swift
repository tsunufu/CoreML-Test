import Foundation
import AVFoundation
import Vision
import CoreML
import SwiftUI

class CameraService: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // カメラセッション
    let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "cameraSessionQueue")
    
    // Visionリクエスト
    private var visionRequests = [VNRequest]()
    
    // 認識結果を公開するプロパティ
    @Published var recognizedText: String = "認識中..."
    @Published var isCorrect: Bool = false
    
    // 処理中かどうかを管理するフラグ
    private var isProcessing = false
    
    // 登録済みオブジェクトへの参照
    var registeredLabels: [String] = []
    
    override init() {
        super.init()
        configureSession()
        setupVision()
        startSession()
    }
    
    func configureSession() {
        session.beginConfiguration()
        session.sessionPreset = .high
        
        // カメラデバイスの選択
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("カメラデバイスが見つかりません")
            session.commitConfiguration()
            return
        }
        
        // カメラ入力の追加
        do {
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            if session.canAddInput(videoDeviceInput) {
                session.addInput(videoDeviceInput)
            } else {
                print("カメラ入力の追加に失敗")
                session.commitConfiguration()
                return
            }
        } catch {
            print("カメラ入力の取得に失敗: \(error)")
            session.commitConfiguration()
            return
        }
        
        // カメラ出力の追加
        let videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)
        ]
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoDataOutputQueue"))
        
        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
        } else {
            print("ビデオデータ出力の追加に失敗")
            session.commitConfiguration()
            return
        }
        
        session.commitConfiguration()
    }
    
    func setupVision() {
        // CoreMLモデルのロード
        guard let model = try? VNCoreMLModel(for: MobileNetV2().model) else {
            print("CoreMLモデルのロードに失敗しました")
            return
        }
        
        // Visionリクエストの作成
        let classificationRequest = VNCoreMLRequest(model: model) { [weak self] request, error in
            self?.processClassification(request: request, error: error)
        }
        classificationRequest.imageCropAndScaleOption = .centerCrop
        visionRequests = [classificationRequest]
    }
    
    func processClassification(request: VNRequest, error: Error?) {
        if let results = request.results as? [VNClassificationObservation] {
            if let topResult = results.first {
                DispatchQueue.main.async {
                    self.recognizedText = "\(topResult.identifier) \(String(format: "%.2f", topResult.confidence * 100))%"
                    
                    // 登録済みラベルと比較
                    if self.registeredLabels.contains(where: { $0.lowercased() == topResult.identifier.lowercased() }) {
                        self.isCorrect = true
                    } else {
                        self.isCorrect = false
                    }
                }
            }
        } else if let error = error {
            print("分類エラー: \(error.localizedDescription)")
        }
    }
    
    // セッション開始
    func startSession() {
        sessionQueue.async {
            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }
    
    // セッション停止
    func stopSession() {
        sessionQueue.async {
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }
    
    // フレーム毎に呼び出されるデリゲートメソッド
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            if isProcessing {
                return
            }
            isProcessing = true
            
            // CMSampleBufferからCVPixelBufferを取得
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
                isProcessing = false
                return
            }
            
            // Visionリクエストハンドラの作成
            let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .right, options: [:])
            
            do {
                try imageRequestHandler.perform(self.visionRequests)
            } catch {
                print("Visionリクエストの実行に失敗: \(error)")
            }
            
            isProcessing = false
        }
        
        deinit {
            stopSession()
        }
}
