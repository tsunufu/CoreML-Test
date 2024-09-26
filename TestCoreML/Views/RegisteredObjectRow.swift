// RegisteredObjectRow.swift
import SwiftUI

struct RegisteredObjectRow: View {
    var object: RegisteredObject
    @ObservedObject var viewModel: RegisteredObjectsViewModel
    
    var body: some View {
        HStack {
            // 画像の表示
            if let uiImage = viewModel.loadImage(from: object) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipped()
                    .cornerRadius(8)
            } else {
                // 画像が見つからない場合のプレースホルダー
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.white)
                    )
            }
            
            // ラベルの表示
            Text(object.label)
                .font(.headline)
                .padding(.leading, 10)
            
            Spacer()
        }
        .padding(.vertical, 5)
    }
}

struct RegisteredObjectRow_Previews: PreviewProvider {
    static var previews: some View {
        RegisteredObjectRow(object: RegisteredObject(imagePath: "example.jpg", label: "Example Label"), viewModel: RegisteredObjectsViewModel())
    }
}
