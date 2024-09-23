// ContentView.swift
import SwiftUI

struct ContentView: View {
    @StateObject private var cameraService = CameraService()
    @StateObject private var registeredObjectsViewModel = RegisteredObjectsViewModel()
    @State private var showingRegisterView = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                CameraPreview(cameraService: cameraService)
                    .edgesIgnoringSafeArea(.all)
                
                // 認識結果を表示するオーバーレイ
                VStack {
                    Text(cameraService.recognizedText)
                        .padding()
                        .background(Color.black.opacity(0.6))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.bottom, 10)
                    
                    if cameraService.isCorrect {
                        Text("Correct")
                            .font(.headline)
                            .padding()
                            .background(Color.green.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.bottom, 50)
                    }
                }
            }
            .onAppear {
                // 登録済みラベルをCameraServiceに渡す
                cameraService.registeredLabels = registeredObjectsViewModel.registeredObjects.map { $0.label }
            }
            .onChange(of: registeredObjectsViewModel.registeredObjects) { _ in
                // 登録済みラベルを更新
                cameraService.registeredLabels = registeredObjectsViewModel.registeredObjects.map { $0.label }
            }
            // ナビゲーションバーのタイトルとアイテムをNavigationView内に配置
            .navigationBarTitle("リアルタイム画像認識", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                showingRegisterView = true
            }) {
                Image(systemName: "plus")
                    .imageScale(.large)
            })
        }
        .sheet(isPresented: $showingRegisterView) {
            RegisterObjectView(viewModel: registeredObjectsViewModel)
        }
    }
}
