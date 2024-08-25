import SwiftUI

class FolderViewModel: ObservableObject {
    @Published var selectedFolder: URL?
    @Published var folderContents: [URL] = []
    @Published var errorMessage: String?

    func selectFolder() {
        let panel = NSOpenPanel()
        panel.directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        Task { @MainActor in
            let response = await panel.begin()
            if response == .OK, let url = panel.url {
                self.selectedFolder = url
                self.errorMessage = nil // Reset error message when a new folder is selected
                await self.fetchFolderContents(from: url)
            } else if response == .cancel {
                self.selectedFolder = nil
                self.errorMessage = "フォルダの選択がキャンセルされました。"
            } else {
                self.selectedFolder = nil
                self.errorMessage = "選択中に予期しないエラーが発生しました。再試行してください。"
            }
        }
    }

    private func fetchFolderContents(from url: URL) async {
        do {
            let fileManager = FileManager.default
            let files = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
            Task { @MainActor in
                self.folderContents = files
            }
        } catch {
            Task { @MainActor in
                self.errorMessage = "フォルダの内容を取得中にエラーが発生しました。"
                self.folderContents = []
            }
        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = FolderViewModel()

    var body: some View {
        VStack {
            Button(action: {
                viewModel.selectFolder()
            }) {
                Text("フォルダを選択")
            }

            if let folder = viewModel.selectedFolder {
                Text("フォルダが選択されました: \(folder.path)")
                    .padding(.top, 10)

                if !viewModel.folderContents.isEmpty {
                    List(viewModel.folderContents, id: \.self) { file in
                        Text(file.absoluteString)
                    }
                    .padding(.top, 10)
                }
            }

            if let errorMessage = viewModel.errorMessage {
                Text("エラー: \(errorMessage)")
                    .foregroundColor(.red)
                    .padding(.top, 10)
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
