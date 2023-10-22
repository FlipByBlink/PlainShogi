import SwiftUI

struct 閉じるボタン: ViewModifier {
    private var dismiss: DismissAction
    func body(content: Content) -> some View {
        if #available(watchOS 10.0, *) {
            content
        } else {
            content
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(role: .cancel) {
                            self.dismiss()
                            フィードバック.軽め()
                        } label: {
                            Image(systemName: "xmark")
                        }
                    }
                }
        }
    }
    init(_ dismiss: DismissAction) {
        self.dismiss = dismiss
    }
}
