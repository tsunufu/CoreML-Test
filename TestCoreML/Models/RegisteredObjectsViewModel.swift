// RegisteredObjectsViewModel.swift
import Foundation
import SwiftUI

class RegisteredObjectsViewModel: ObservableObject {
    @Published var registeredObjects: [RegisteredObject] = []
    @Published var availableLabels: [String] = []
    @Published var isLoading: Bool = false // 認識中のフラグ
    @Published var recognitionError: String? = nil // 認識エラー
    
    // 登録済みオブジェクトを追加する関数
    func addObject(image: UIImage, label: String) {
        let newObject = RegisteredObject(image: image, label: label)
        DispatchQueue.main.async {
            self.registeredObjects.append(newObject)
        }
    }
    
    func recognizeImage(_ image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        isLoading = true
        recognitionError = nil
        
        ImageRecognitionService.shared.recognizeImage(image) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let observations):
                    guard let topResult = observations.first else {
                        self.recognitionError = "ラベルが認識できませんでした。"
                        completion(.failure(NSError(domain: "RecognitionError", code: -1, userInfo: [NSLocalizedDescriptionKey: "ラベルが認識できませんでした。"])))
                        return
                    }
                    // 上位1件のラベルを使用
                    let recognizedLabel = topResult.identifier
                    completion(.success(recognizedLabel))
                case .failure(let error):
                    self.recognitionError = error.localizedDescription
                    completion(.failure(error))
                }
            }
        }
    }
}
