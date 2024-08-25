import SwiftUI

struct ContentView: View {
    @State private var selectedFolder: URL?

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
        }
        .padding()
    }

    func selectFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.begin { response in
            if response == .OK, let url = panel.url {
                selectedFolder = url
            }
        }
    }
}

#Preview {
    ContentView()
}
