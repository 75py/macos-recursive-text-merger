import SwiftUI

struct ContentView: View {
    @State private var selectedFolder: URL?
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            Button(action: {
                selectFolder()
            }) {
                Text("フォルダを選択")
            }

            if let folder = selectedFolder {
                Text("選択されたフォルダ: \(folder.path)")
                    .padding(.top, 10)
            }

            if let errorMessage = errorMessage {
                Text("エラー: \(errorMessage)")
                    .foregroundColor(.red)
                    .padding(.top, 10)
            }
        }
        .padding()
    }

    func selectFolder() {
        let panel = NSOpenPanel()
        panel.directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.begin { response in
            if response == .OK, let url = panel.url {
                selectedFolder = url
                errorMessage = nil
            } else if response == .cancel {
                selectedFolder = nil
                errorMessage = "フォルダの選択がキャンセルされました。"
            } else {
                selectedFolder = nil
                errorMessage = "不明なエラーが発生しました。"
            }
        }
    }
}

#Preview {
    ContentView()
}
