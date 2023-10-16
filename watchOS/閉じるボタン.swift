import SwiftUI

struct 閉じるボタン: ToolbarContent {
    private var dismiss: DismissAction
    var body: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(role: .cancel) {
                self.dismiss()
                フィードバック.軽め()
            } label: {
                Image(systemName: "xmark")
            }
        }
    }
    init(_ dismiss: DismissAction) {
        self.dismiss = dismiss
    }
}
