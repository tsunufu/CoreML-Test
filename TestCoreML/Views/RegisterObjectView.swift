// RegisterObjectView.swift
import SwiftUI

struct RegisterObjectView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: RegisteredObjectsViewModel
    
    @State private var showingImagePicker = false
    @State private var showingActionSheet = false
    @State private var selectedImage: UIImage?
    @State private var inputLabel: String = ""
    @State private var imagePickerSourceType: UIImagePickerController.SourceType = .photoLibrary
    
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
                    showingActionSheet = true
                }) {
                    Text("画像を選択")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding([.leading, .trailing])
                }
                .actionSheet(isPresented: $showingActionSheet) {
                    ActionSheet(title: Text("画像の選択"), message: Text("画像を撮影するか、写真ライブラリから選択してください。"), buttons: [
                        .default(Text("カメラで撮影")) {
                            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                                imagePickerSourceType = .camera
                                showingImagePicker = true
                            } else {
                                // カメラが利用できない場合の処理
                                // 例えば、アラートを表示
                                print("カメラが利用できません。")
                            }
                        },
                        .default(Text("写真ライブラリから選択")) {
                            imagePickerSourceType = .photoLibrary
                            showingImagePicker = true
                        },
                        .cancel()
                    ])
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
                    viewModel.recognizeImage(image) { result in
                        switch result {
                        case .success(let label):
                            // 認識結果を入力ラベルに設定
                            self.inputLabel = label
                        case .failure(let error):
                            // エラー処理（既に viewModel でエラーが設定されている）
                            break
                        }
                    }
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $selectedImage, sourceType: imagePickerSourceType)
                    .edgesIgnoringSafeArea(.all)
            }
        }
    }
}
