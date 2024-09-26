// RegisteredObjectsViewModel.swift
import Foundation
import SwiftUI

class RegisteredObjectsViewModel: ObservableObject {
    @Published var registeredObjects: [RegisteredObject] = []
    //    @Published var availableLabels: [String] = []
    @Published var isLoading: Bool = false // 認識中のフラグ
    @Published var recognitionError: String? = nil // 認識エラー
    
    // 登録済みオブジェクトを追加する関数
    //    func addObject(image: UIImage, label: String) {
    //        let newObject = RegisteredObject(image: image, label: label)
    //        DispatchQueue.main.async {
    //            self.registeredObjects.append(newObject)
    //        }
    //    }
    //
    //    func recognizeImage(_ image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
    //        isLoading = true
    //        recognitionError = nil
    //
    //        ImageRecognitionService.shared.recognizeImage(image) { result in
    //            DispatchQueue.main.async {
    //                self.isLoading = false
    //                switch result {
    //                case .success(let observations):
    //                    guard let topResult = observations.first else {
    //                        self.recognitionError = "ラベルが認識できませんでした。"
    //                        completion(.failure(NSError(domain: "RecognitionError", code: -1, userInfo: [NSLocalizedDescriptionKey: "ラベルが認識できませんでした。"])))
    //                        return
    //                    }
    //                    // 上位1件のラベルを使用
    //                    let recognizedLabel = topResult.identifier
    //                    completion(.success(recognizedLabel))
    //                case .failure(let error):
    //                    self.recognitionError = error.localizedDescription
    //                    completion(.failure(error))
    //                }
    //            }
    //        }
    //    }
    
    private let userDefaultsKey = "RegisteredObjects"
    
    init() {
        loadObjects()
    }
    
    // オブジェクトをUserDefaultsから読み込む
    func loadObjects() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey) {
            do {
                let decoder = JSONDecoder()
                registeredObjects = try decoder.decode([RegisteredObject].self, from: data)
            } catch {
                print("オブジェクトのデコードに失敗: \(error)")
            }
        }
    }
    
    // オブジェクトをUserDefaultsに保存する
    func saveObjects() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(registeredObjects)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        } catch {
            print("オブジェクトのエンコードに失敗: \(error)")
        }
    }
    
    // オブジェクトを追加する関数
    func addObject(image: UIImage, label: String) {
        // 画像を保存してパスを取得
        guard let imagePath = saveImage(image: image) else {
            print("画像の保存に失敗しました。")
            return
        }
        
        let newObject = RegisteredObject(imagePath: imagePath, label: label)
        DispatchQueue.main.async {
            self.registeredObjects.append(newObject)
            self.saveObjects() // 保存
        }
    }
    
    // オブジェクトを削除する関数
    func deleteObject(_ object: RegisteredObject) {
        if let index = registeredObjects.firstIndex(of: object) {
            // 画像ファイルを削除
            deleteImage(at: object.imagePath)
            
            // オブジェクトを削除
            registeredObjects.remove(at: index)
            saveObjects()
        }
    }
    
    
    // 画像をアプリのドキュメントディレクトリに保存し、パスを返す
    private func saveImage(image: UIImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 1.0) else { return nil }
        let filename = UUID().uuidString + ".jpg"
        let url = getDocumentsDirectory().appendingPathComponent(filename)
        do {
            try data.write(to: url)
            return filename
        } catch {
            print("画像の保存に失敗: \(error)")
            return nil
        }
    }
    
    // 画像を削除する関数
    private func deleteImage(at path: String) {
        let url = getDocumentsDirectory().appendingPathComponent(path)
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            print("画像の削除に失敗: \(error)")
        }
    }
    
    // ドキュメントディレクトリのURLを取得
    private func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    // 画像を読み込む関数
    func loadImage(from object: RegisteredObject) -> UIImage? {
        let url = getDocumentsDirectory().appendingPathComponent(object.imagePath)
        return UIImage(contentsOfFile: url.path)
    }
    
    // 画像認識を行い、ラベルを取得する関数
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
