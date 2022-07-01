

import Combine
import SwiftUI
import UniformTypeIdentifiers

class 📱AppModel2: ObservableObject {

    @Published var 駒の配置2: [Int: 盤上に置かれた駒] = 初期配置2

    @Published var 手駒2: [王側か玉側か: 手持ちの駒] = [.王側: .init(), .玉側: .init()]

    @AppStorage("English表記") var 🚩English表記: Bool = false
    
    
}
