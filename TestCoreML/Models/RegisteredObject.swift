import SwiftUI

//struct RegisteredObject: Identifiable, Equatable {
//    let id = UUID()
//    var image: UIImage
//    var label: String
//    
//    // Equatable プロトコルの実装
//    static func == (lhs: RegisteredObject, rhs: RegisteredObject) -> Bool {
//        return lhs.label.lowercased() == rhs.label.lowercased()
//    }
//}

struct RegisteredObject: Identifiable, Codable, Equatable {
    let id: UUID
    var imagePath: String // 画像の保存パス
    var label: String
    
    init(id: UUID = UUID(), imagePath: String, label: String) {
        self.id = id
        self.imagePath = imagePath
        self.label = label
    }
    
    // Equatable プロトコルの実装
    static func == (lhs: RegisteredObject, rhs: RegisteredObject) -> Bool {
        return lhs.id == rhs.id
    }
}
