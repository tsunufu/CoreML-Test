// RegisterObjectView.swift
import SwiftUI

struct RegisterObjectView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: RegisteredObjectsViewModel
    
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var inputLabel: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 画像表示エリア
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .cornerRadius(10)
                        .padding()
                } else {
                    Rectangle()
                        .fill(Color.secondary)
                        .frame(height: 200)
                        .overlay(
                            Text("画像を選択")
                                .foregroundColor(.white)
                                .font(.headline)
                        )
                        .cornerRadius(10)
                        .padding()
                }
                
                // 画像選択ボタン
                Button(action: {
                    showingImagePicker = true
                }) {
                    Text("画像を選択")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding([.leading, .trailing])
                }
                
                // 認識結果表示とラベル編集
                if viewModel.isLoading {
                    ProgressView("認識中...")
                        .padding()
                } else if let error = viewModel.recognitionError {
                    Text("エラー: \(error)")
                        .foregroundColor(.red)
                        .padding()
                } else if let image = selectedImage {
                    VStack {
                        Text("認識されたラベル:")
                            .font(.headline)
                        
                        TextField("ラベルを編集", text: $inputLabel)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding([.leading, .trailing])
                    }
                }
                
                Spacer()
            }
            .navigationBarTitle("オブジェクト登録", displayMode: .inline)
            .navigationBarItems(trailing: Button("保存") {
                if let image = selectedImage, !inputLabel.isEmpty {
                    viewModel.addObject(image: image, label: inputLabel)
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .disabled(selectedImage == nil || inputLabel.isEmpty))
            .onChange(of: selectedImage) { newImage in
                if let image = newImage {
                    // 画像が選択されたら認識を開始
                    viewModel.recognizeAndAddObject(image: image) { success in
                        if success, let topObject = viewModel.registeredObjects.last {
                            // 認識結果を入力ラベルに設定
                            self.inputLabel = topObject.label
                        }
                    }
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
            }
        }
    }
}
