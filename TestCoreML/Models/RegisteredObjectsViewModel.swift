// RegisteredObjectsViewModel.swift
import Foundation
import SwiftUI

class RegisteredObjectsViewModel: ObservableObject {
    @Published var registeredObjects: [RegisteredObject] = []
    @Published var availableLabels: [String] = []
    @Published var isLoading: Bool = false // 認識中のフラグ
    @Published var recognitionError: String? = nil // 認識エラー
    
    init() {
        loadLabels()
    }
    
    func loadLabels() {
        // labels.txt の読み込みは不要になったため、この関数は削除または無視可能
        // 以前の手順を踏まえた実装では、labels.txt を使用しないため、
        // ここでは使用しません。
    }
    
    // 登録済みオブジェクトを追加する関数
    func addObject(image: UIImage, label: String) {
        let newObject = RegisteredObject(image: image, label: label)
        DispatchQueue.main.async {
            self.registeredObjects.append(newObject)
        }
    }
    
    // 画像認識を行い、ラベルを取得する関数
    func recognizeAndAddObject(image: UIImage, completion: @escaping (Bool) -> Void) {
        isLoading = true
        recognitionError = nil
        
        ImageRecognitionService.shared.recognizeImage(image) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let observations):
                    guard let topResult = observations.first else {
                        self.recognitionError = "ラベルが認識できませんでした。"
                        completion(false)
                        return
                    }
                    // 上位1件のラベルを使用
                    let recognizedLabel = topResult.identifier
                    self.addObject(image: image, label: recognizedLabel)
                    completion(true)
                case .failure(let error):
                    self.recognitionError = error.localizedDescription
                    completion(false)
                }
            }
        }
    }
}
