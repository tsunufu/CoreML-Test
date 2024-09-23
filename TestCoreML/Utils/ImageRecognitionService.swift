// ImageRecognitionService.swift
import Foundation
import Vision
import CoreML
import UIKit

class ImageRecognitionService {
    // シングルトンインスタンス
    static let shared = ImageRecognitionService()
    
    private init() {}
    
    // 画像認識を行う関数
    func recognizeImage(_ image: UIImage, completion: @escaping (Result<[VNClassificationObservation], Error>) -> Void) {
        // MobileNetV2 モデルのロード
        guard let model = try? VNCoreMLModel(for: MobileNetV2().model) else {
            completion(.failure(NSError(domain: "ModelError", code: -1, userInfo: [NSLocalizedDescriptionKey: "モデルのロードに失敗しました"])))
            return
        }
        
        // リクエストの作成
        let request = VNCoreMLRequest(model: model) { (request, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let results = request.results as? [VNClassificationObservation] else {
                completion(.failure(NSError(domain: "ResultError", code: -1, userInfo: [NSLocalizedDescriptionKey: "結果の取得に失敗しました"])))
                return
            }
            
            completion(.success(results))
        }
        
        // 画像の前処理
        guard let cgImage = image.cgImage else {
            completion(.failure(NSError(domain: "ImageError", code: -1, userInfo: [NSLocalizedDescriptionKey: "CGImageへの変換に失敗しました"])))
            return
        }
        
        // リクエストハンドラの作成
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                completion(.failure(error))
            }
        }
    }
}
