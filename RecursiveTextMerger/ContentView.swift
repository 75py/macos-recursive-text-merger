import SwiftUI

struct ContentView: View {
    @State private var selectedFolder: URL?
    @State private var folderContents: [URL] = []
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            Button(action: {
                selectFolder()
            }) {
                Text("フォルダを選択")
            }

            if let folder = selectedFolder {
                Text("フォルダが選択されました: \(folder.path)")
                    .padding(.top, 10)

                if !folderContents.isEmpty {
                    List(folderContents, id: \.self) { file in
                        Text(file.absoluteString)
                    }
                    .padding(.top, 10)
                }
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
        DispatchQueue.main.async {
            panel.begin { response in
                if response == .OK, let url = panel.url {
                    selectedFolder = url
                    errorMessage = nil // Reset error message when a new folder is selected
                    fetchFolderContents(from: url)
                } else if response == .cancel {
                    selectedFolder = nil
                    errorMessage = "フォルダの選択がキャンセルされました。"
                } else {
                    selectedFolder = nil
                    errorMessage = "選択中に予期しないエラーが発生しました。再試行してください。"
                }
            }
        }
    }
    
    func fetchFolderContents(from url: URL) {
        do {
            let fileManager = FileManager.default
            
            let files = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
            DispatchQueue.main.async {
                folderContents = files
            }
        } catch {
            DispatchQueue.main.async {
                errorMessage = "フォルダの内容を取得中にエラーが発生しました: \(error.localizedDescription)"
                folderContents = []
            }
        }
    }
}

#Preview {
    ContentView()
}
