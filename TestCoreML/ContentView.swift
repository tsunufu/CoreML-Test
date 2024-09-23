import SwiftUI

struct ContentView: View {
    @StateObject private var cameraService = CameraService()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            CameraPreview(cameraService: cameraService)
                .edgesIgnoringSafeArea(.all)
            
            // 認識結果を表示するオーバーレイ
            Text(cameraService.recognizedText)
                .padding()
                .background(Color.black.opacity(0.6))
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.bottom, 50)
        }
    }
}
