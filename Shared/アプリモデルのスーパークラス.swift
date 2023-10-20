import UIKit

#if targetEnvironment(macCatalyst)
typealias スーパークラス = UIResponder
#else
typealias スーパークラス = NSObject
#endif
