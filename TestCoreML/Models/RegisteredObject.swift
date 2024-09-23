import SwiftUI

struct RegisteredObject: Identifiable, Equatable {
    let id = UUID()
    var image: UIImage
    var label: String
    
    // Equatable プロトコルの実装
    static func == (lhs: RegisteredObject, rhs: RegisteredObject) -> Bool {
        return lhs.label.lowercased() == rhs.label.lowercased()
    }
}
