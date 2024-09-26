// ContentView.swift
import SwiftUI

struct ContentView: View {
    @StateObject private var cameraService = CameraService()
    @StateObject private var registeredObjectsViewModel = RegisteredObjectsViewModel()
    @State private var showingRegisterView = false
    
    var body: some View {
        TabView {
            // リアルタイム認識タブ
            NavigationView {
                ZStack(alignment: .bottom) {
                    CameraPreview(cameraService: cameraService)
                        .edgesIgnoringSafeArea(.all)
                    
                    // 認識結果を表示するオーバーレイ
                    VStack(spacing: 10) {
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
                                .padding(.bottom, 10)
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
                .navigationBarTitle("リアルタイム画像認識", displayMode: .inline)
                .navigationBarItems(trailing: Button(action: {
                    showingRegisterView = true
                }) {
                    Image(systemName: "plus")
                        .imageScale(.large)
                })
                .sheet(isPresented: $showingRegisterView) {
                    RegisterObjectView(viewModel: registeredObjectsViewModel)
                }
            }
            .tabItem {
                Image(systemName: "camera")
                Text("認識")
            }
            
            // 登録済みオブジェクトリストタブ
            RegisteredObjectsListView(viewModel: registeredObjectsViewModel)
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("登録一覧")
                }
        }
    }
}
