
import Combine
import SwiftUI
import UniformTypeIdentifiers

class ð±AppModel: ObservableObject {
    
    @Published var é§ã®éç½®: [Int: ç¤ä¸ã®é§] = åæéç½®
    @Published var æé§: [çå´ãçå´ã: æã¡é§] = ç©ºã®æé§
    
    @AppStorage("Englishè¡¨è¨") var ð©Englishè¡¨è¨: Bool = false
    
    @Published var ð©ã¡ãã¥ã¼ãè¡¨ç¤º: Bool = false
    @Published var ð©é§ãæ´çä¸­: Bool = false
    
    var ãã©ãã°ããç¤ä¸ã®é§ã®åãã®ä½ç½®: Int? = nil
    var ãã©ãã°ããæã¡é§: (é£å¶: çå´ãçå´ã, è·å: é§ã®ç¨®é¡)? = nil
    
    var ç¾ç¶: ç¶æ³ = .ä½ããã©ãã°ãã¦ãªã {
        didSet {
            switch ç¾ç¶ {
                case .ç¤ä¸ã®é§ããã©ãã°ãã¦ãã:
                    ãã©ãã°ããæã¡é§ = nil
                case .æã¡é§ããã©ãã°ãã¦ãã:
                    ãã©ãã°ããç¤ä¸ã®é§ã®åãã®ä½ç½® = nil
                case .ã¢ããªå¤é¨ãããã©ãã°ãã¦ãã, .ä½ããã©ãã°ãã¦ãªã:
                    ãã©ãã°ããç¤ä¸ã®é§ã®åãã®ä½ç½® = nil
                    ãã©ãã°ããæã¡é§ = nil
            }
        }
    }
    
    
    func ãã®ç¤ä¸ã®é§ã®è¡¨è¨(_ é§: ç¤ä¸ã®é§) -> String {
        if é§.æã {
            return ð©Englishè¡¨è¨ ? é§.è·å.Englishæé§è¡¨è¨! : é§.è·å.æé§è¡¨è¨!
        } else {
            if é§.é£å¶ == .çå´ && é§.è·å == .ç {
                return ð©Englishè¡¨è¨ ? "K" : "ç"
            } else {
                return ð©Englishè¡¨è¨ ? é§.è·å.Englishçé§è¡¨è¨ : é§.è·å.rawValue
            }
        }
    }
    
    func ãã®æã¡é§ã®è¡¨è¨(_ é£å¶: çå´ãçå´ã, _ è·å: é§ã®ç¨®é¡) -> String {
        if é£å¶ == .çå´ && è·å == .ç {
            return ð©Englishè¡¨è¨ ? "K" : "ç"
        } else {
            return ð©Englishè¡¨è¨ ? è·å.Englishçé§è¡¨è¨ : è·å.rawValue
        }
    }
    
    func ãã®æã¡é§ã®æ°(_ é£å¶: çå´ãçå´ã, _ è·å: é§ã®ç¨®é¡) -> Int {
        æé§[é£å¶]?.åæ°(è·å) ?? 0
    }
    
    
    func ãã®ç¤ä¸ã®é§ããã©ãã°ãå§ãã(_ ä½ç½®: Int) -> NSItemProvider {
        ãã©ãã°ããç¤ä¸ã®é§ã®åãã®ä½ç½® = ä½ç½®
        ç¾ç¶ = .ç¤ä¸ã®é§ããã©ãã°ãã¦ãã
        return ãã©ãã°å¯¾è±¡ã¨ãªãã¢ã¤ãã ãç¨æãã()
    }
    
    func ãã®æã¡é§ããã©ãã°ãå§ãã(_ é£å¶: çå´ãçå´ã, _ è·å: é§ã®ç¨®é¡) -> NSItemProvider {
        ãã©ãã°ããæã¡é§ = (é£å¶, è·å)
        ç¾ç¶ = .æã¡é§ããã©ãã°ãã¦ãã
        return ãã©ãã°å¯¾è±¡ã¨ãªãã¢ã¤ãã ãç¨æãã()
    }
    
    func ãã©ãã°å¯¾è±¡ã¨ãªãã¢ã¤ãã ãç¨æãã() -> NSItemProvider {
        let ð = ç¾å¨ã®ç¤é¢ããã­ã¹ãã«å¤æãã()
        let ð¦ = NSItemProvider(object: ð as NSItemProviderWriting)
        ð¦.suggestedName = "ã¢ããªåã§ã®ã³ãç§»å"
        return ð¦
    }
    
    
    func ç¤é¢ãåæåãã() {
        é§ã®éç½® = åæéç½®
        æé§ = ç©ºã®æé§
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
    
    // ================================================================================
    // ============================= ä»¥ä¸ããã­ããDelegate =============================
    func ç¤ä¸ã®ããã«ãã­ãããã(_ ç½®ããä½ç½®: Int, _ ânfo: DropInfo) -> Bool {
        switch ç¾ç¶ {
            case .ç¤ä¸ã®é§ããã©ãã°ãã¦ãã:
                guard let åºçºå°ç¹ = ãã©ãã°ããç¤ä¸ã®é§ã®åãã®ä½ç½® else { return false }
                if ç½®ããä½ç½® == åºçºå°ç¹ { return false }
                
                let åãããé§ = é§ã®éç½®[åºçºå°ç¹]!
                
                if let åå®¢ = é§ã®éç½®[ç½®ããä½ç½®] {
                    if åå®¢.é£å¶ == åãããé§.é£å¶ { return false }
                    
                    æé§[åãããé§.é£å¶]?.ä¸åå¢ãã(åå®¢.è·å)
                }
                
                é§ã®éç½®.removeValue(forKey: åºçºå°ç¹)
                é§ã®éç½®.updateValue(åãããé§, forKey: ç½®ããä½ç½®)
                
                é§ãç§»åãçµãã£ããã­ã°ãæ´æ°ãã¦ãã£ã¼ãããã¯ãçºçããã()
                
            case .æã¡é§ããã©ãã°ãã¦ãã:
                guard let é§ = ãã©ãã°ããæã¡é§ else { return false }
                if é§ã®éç½®[ç½®ããä½ç½®] != nil { return false }
                
                é§ã®éç½®.updateValue(ç¤ä¸ã®é§(é§.é£å¶, é§.è·å), forKey: ç½®ããä½ç½®)
                
                æé§[é§.é£å¶]?.ä¸åæ¸ãã(é§.è·å)
                
                é§ãç§»åãçµãã£ããã­ã°ãæ´æ°ãã¦ãã£ã¼ãããã¯ãçºçããã()
                
            case .ã¢ããªå¤é¨ãããã©ãã°ãã¦ãã:
                let ð¦ = ânfo.itemProviders(for: [UTType.utf8PlainText])
                ãã®ã¢ã¤ãã ãç¤é¢ã«åæ ãã(ð¦)
                
            case .ä½ããã©ãã°ãã¦ãªã:
                return false
        }
        
        return true
    }
    
    func ç¤å¤ã®ãã¡ãå´ã«ãã­ãããã(_ ãã­ãããããé£å¶: çå´ãçå´ã, _ ânfo: DropInfo) -> Bool {
        switch ç¾ç¶ {
            case .ç¤ä¸ã®é§ããã©ãã°ãã¦ãã:
                guard let åºçºå°ç¹ = ãã©ãã°ããç¤ä¸ã®é§ã®åãã®ä½ç½® else { return false }
                let åãããé§ = é§ã®éç½®[åºçºå°ç¹]!
                
                é§ã®éç½®.removeValue(forKey: åºçºå°ç¹)
                æé§[ãã­ãããããé£å¶]?.ä¸åå¢ãã(åãããé§.è·å)
                
                é§ãç§»åãçµãã£ããã­ã°ãæ´æ°ãã¦ãã£ã¼ãããã¯ãçºçããã()
                
            case .æã¡é§ããã©ãã°ãã¦ãã:
                guard let é§ = ãã©ãã°ããæã¡é§ else { return false }
                
                æé§[é§.é£å¶]?.ä¸åæ¸ãã(é§.è·å)
                æé§[ãã­ãããããé£å¶]?.ä¸åå¢ãã(é§.è·å)
                
                é§ãç§»åãçµãã£ããã­ã°ãæ´æ°ãã¦ãã£ã¼ãããã¯ãçºçããã()
                
            case .ã¢ããªå¤é¨ãããã©ãã°ãã¦ãã:
                let ð¦ = ânfo.itemProviders(for: [UTType.utf8PlainText])
                ãã®ã¢ã¤ãã ãç¤é¢ã«åæ ãã(ð¦)
                
            case .ä½ããã©ãã°ãã¦ãªã:
                return false
        }
        
        return true
    }
    
    func é§ãç§»åãçµãã£ããã­ã°ãæ´æ°ãã¦ãã£ã¼ãããã¯ãçºçããã() {
        ç¾ç¶ = .ä½ããã©ãã°ãã¦ãªã
        ã­ã°ãæ´æ°ãã()
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }
    
    
    func ç¤ä¸ã®ããã¯ãã­ããå¯è½ãç¢ºèªãã(_ ä½ç½®: Int) -> DropProposal? {
        switch ç¾ç¶ {
            case .ç¤ä¸ã®é§ããã©ãã°ãã¦ãã:
                if ä½ç½® == ãã©ãã°ããç¤ä¸ã®é§ã®åãã®ä½ç½® {
                    return DropProposal(operation: .cancel)
                }
                
                if let åãã®ä½ç½® = ãã©ãã°ããç¤ä¸ã®é§ã®åãã®ä½ç½® {
                    if é§ã®éç½®[ä½ç½®]?.é£å¶ == é§ã®éç½®[åãã®ä½ç½®]?.é£å¶ {
                        return DropProposal(operation: .cancel)
                    }
                }
                
            case .æã¡é§ããã©ãã°ãã¦ãã:
                if é§ã®éç½®[ä½ç½®] != nil {
                    return .init(operation: .cancel)
                }
                
            case .ã¢ããªå¤é¨ãããã©ãã°ãã¦ãã, .ä½ããã©ãã°ãã¦ãªã:
                return nil
        }
        
        return nil
    }
    
    func ç¤å¤ã®ããã¯ãã­ããå¯è½ãç¢ºèªãã(_ ãã­ãããããã¨ãã¦ããé£å¶: çå´ãçå´ã) -> DropProposal? {
        if ç¾ç¶ == .æã¡é§ããã©ãã°ãã¦ãã {
            if let é§ = ãã©ãã°ããæã¡é§ {
                if ãã­ãããããã¨ãã¦ããé£å¶ == é§.é£å¶ {
                    return DropProposal(operation: .cancel)
                }
            }
        }
        
        return nil
    }
        
    func æå¹ãªãã­ããããã§ãã¯ãã(_ ânfo: DropInfo) -> Bool {
        let ð¦ItemProvider = ânfo.itemProviders(for: [UTType.utf8PlainText])
        guard let ð¦ = ð¦ItemProvider.first else { return false }
        
        if let ð· = ð¦.suggestedName {
            if ð· != "ã¢ããªåã§ã®ã³ãç§»å" {
                print("ã¢ããªå¤é¨ããã®ã¢ã¤ãã ã§ã")
                print("ð¦.suggestedName: ", ð·)
                ç¾ç¶ = .ã¢ããªå¤é¨ãããã©ãã°ãã¦ãã
            }
        } else {
            print("ã¢ããªå¤é¨ããã®ã¢ã¤ãã ã§ã")
            ç¾ç¶ = .ã¢ããªå¤é¨ãããã©ãã°ãã¦ãã
        }
        
        return true
    }
    
    // ==============================================================================
    // ============================= ä»¥ä¸ãã­ã°ã®æ´æ°ãä¿å­ =============================
    init() { ä»¥åã¢ããªèµ·åããéã®ã­ã°ãèª­ã¿è¾¼ã() }
    
    func ä»¥åã¢ããªèµ·åããéã®ã­ã°ãèª­ã¿è¾¼ã() {
        let ð = UserDefaults.standard
        
        if let é§â£ã®éç½® = ð.dictionary(forKey: "é§ã®éç½®") as? [String: [String]] {
            if let æâ£é§ = ð.dictionary(forKey: "æé§") as? [String: [String: String]] {
                é§ã®éç½® = [:]
                æé§ = ç©ºã®æé§
                
                é§â£ã®éç½®.forEach { (ä½ç½®ãã­ã¹ã: String, é§ãã­ã¹ã: [String]) in
                    if é§ãã­ã¹ã.count != 3 { return }
                    if let é£å¶ = çå´ãçå´ã(rawValue: é§ãã­ã¹ã[0]) {
                        if let è·å = é§ã®ç¨®é¡(rawValue: é§ãã­ã¹ã[1]) {
                            if let ä½ç½® = Int(ä½ç½®ãã­ã¹ã) {
                                if let æã = Bool(é§ãã­ã¹ã[2]) {
                                    é§ã®éç½®.updateValue(ç¤ä¸ã®é§(é£å¶, è·å, æã), forKey: ä½ç½®)
                                } else {
                                    é§ã®éç½®.updateValue(ç¤ä¸ã®é§(é£å¶, è·å), forKey: ä½ç½®)
                                }
                            }
                        }
                    }
                }
                
                çå´ãçå´ã.allCases.forEach { é£å¶ in
                    if let æé§ãã­ã¹ã = æâ£é§[é£å¶.rawValue] {
                        æé§ãã­ã¹ã.forEach { (è·åãã­ã¹ã: String, æ°ãã­ã¹ã: String) in
                            if let è·å = é§ã®ç¨®é¡(rawValue: è·åãã­ã¹ã) {
                                if let æ° = Int(æ°ãã­ã¹ã) {
                                    æé§[é£å¶]?.éå.updateValue(æ°, forKey: è·å)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    func ã­ã°ãæ´æ°ãã() {
        let ð = UserDefaults.standard
        var é§â£ã®éç½®: [String: [String]] = [:]
        var æâ£é§: [String: [String: String]] = ["çå´": [:], "çå´": [:]]
        
        é§ã®éç½®.forEach { (ä½ç½®: Int, é§: ç¤ä¸ã®é§) in
            é§â£ã®éç½®.updateValue([é§.é£å¶.rawValue, é§.è·å.rawValue, é§.æã.description], forKey: ä½ç½®.description)
        }
        
        çå´ãçå´ã.allCases.forEach { é£å¶ in
            æé§[é£å¶]?.éå.forEach { (è·å: é§ã®ç¨®é¡, æ°: Int) in
                æâ£é§[é£å¶.rawValue]?[è·å.rawValue] = æ°.description
            }
        }
        
        ð.set(é§â£ã®éç½®, forKey: "é§ã®éç½®")
        ð.set(æâ£é§, forKey: "æé§")
    }
    
    // ==============================================================================
    // ======================== ä»¥ä¸ããã­ã¹ãæ¸ãåºãèª­ã¿è¾¼ã¿æ©è½ ========================
    func ç¾å¨ã®ç¤é¢ããã­ã¹ãã«å¤æãã() -> String {
        var ð = "â"

        é§ã®ç¨®é¡.allCases.forEach { è·å in
            if let æ° = æé§[.çå´]?.åæ°(è·å) {
                if æ° >= 1 {
                    ð += ð©Englishè¡¨è¨ ? é§ãEnglishãã¬ã¼ã³ãã­ã¹ãã«å¤æ(è·å) : è·å.rawValue
                    ð += "Í"
                }
                
                if æ° >= 2 {
                    ð += æ°.description
                }
            }
        }

        ð += "\nï¼ï¼ï¼ï¼ï¼ï¼ï¼ï¼ï¼\n"

        for è¡ in 0 ..< 9 {
            for å in 0 ..< 9 {
                if let é§ = é§ã®éç½®[è¡*9+å] {
                    if ð©Englishè¡¨è¨ {
                        ð += é§ãEnglishãã¬ã¼ã³ãã­ã¹ãã«å¤æ(é§.è·å, é§.æã)
                    } else {
                        ð += é§.æã ? é§.è·å.æé§è¡¨è¨! : é§.è·å.rawValue
                    }

                    if é§.é£å¶ == .çå´ {
                        ð += "Í"
                    }
                } else {
                    ð += "ã"
                }
            }
            ð += "\n"
        }

        ð += "ï¼ï¼ï¼ï¼ï¼ï¼ï¼ï¼ï¼\nâ"

        é§ã®ç¨®é¡.allCases.forEach { è·å in
            if let æ° = æé§[.çå´]?.åæ°(è·å) {
                if æ° >= 1 {
                    ð += ð©Englishè¡¨è¨ ? é§ãEnglishãã¬ã¼ã³ãã­ã¹ãã«å¤æ(è·å) : è·å.rawValue
                }
                
                if æ° >= 2 {
                    ð += æ°.description
                }
            }
        }

        return ð
    }
    
    
    func ãã®ã¢ã¤ãã ãç¤é¢ã«åæ ãã(_ ð¦ItemProvider: [NSItemProvider]) {
        Task { @MainActor in
            do {
                guard let ð¦ = ð¦ItemProvider.first else { return }
                let ðecureCoding = try await ð¦.loadItem(forTypeIdentifier: UTType.utf8PlainText.identifier)
                guard let ð¾ = ðecureCoding as? Data else { return }
                guard let ð = String(data: ð¾, encoding: .utf8) else { return }
                if ð.first != "â" { return }
                
                var é§â£ã®éç½®: [Int: ç¤ä¸ã®é§] = [:]
                var æâ£é§: [çå´ãçå´ã: æã¡é§] = ç©ºã®æé§
                
                var æ¹è¡æ°: Int = 0
                var å: Int = 0
                var èª­ã¿è¾¼ã¿ä¸­ã®æã¡é§ã®ç¨®é¡: é§ã®ç¨®é¡ = .æ­©
                
                for å­åºåã in ð {
                    if å­åºåã == "\n" {
                        æ¹è¡æ° += 1
                        å = 0
                        continue
                    }
                    
                    let é§ãã­ã¹ã = å­åºåã.description
                    
                    switch æ¹è¡æ° {
                        case 0:
                            if let æ° = Int(é§ãã­ã¹ã) {
                                æâ£é§[.çå´]?.éå[èª­ã¿è¾¼ã¿ä¸­ã®æã¡é§ã®ç¨®é¡] = æ°
                            } else {
                                if let é§ = ãã¬ã¼ã³ãã­ã¹ããé§ã«å¤æ(é§ãã­ã¹ã) {
                                    æâ£é§[é§.é£å¶]?.éå[é§.è·å] = 1
                                    
                                    èª­ã¿è¾¼ã¿ä¸­ã®æã¡é§ã®ç¨®é¡ = é§.è·å
                                }
                            }
                        case 1...11:
                            let ä½ç½® = ( æ¹è¡æ° - 2 ) * 9 + å
                            
                            if let é§ = ãã¬ã¼ã³ãã­ã¹ããé§ã«å¤æ(é§ãã­ã¹ã) {
                                é§â£ã®éç½®.updateValue(ç¤ä¸ã®é§(é§.é£å¶, é§.è·å, é§.æã), forKey: ä½ç½®)
                            }
                        case 12:
                            if let æ° = Int(é§ãã­ã¹ã) {
                                æâ£é§[.çå´]?.éå[èª­ã¿è¾¼ã¿ä¸­ã®æã¡é§ã®ç¨®é¡] = æ°
                            } else {
                                if let é§ = ãã¬ã¼ã³ãã­ã¹ããé§ã«å¤æ(é§ãã­ã¹ã) {
                                    æâ£é§[é§.é£å¶]?.éå[é§.è·å] = 1
                                    
                                    èª­ã¿è¾¼ã¿ä¸­ã®æã¡é§ã®ç¨®é¡ = é§.è·å
                                }
                            }
                        default: break
                    }
                    
                    å += 1
                }
                
                é§ã®éç½® = é§â£ã®éç½®
                æé§ = æâ£é§
                
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                ç¾ç¶ = .ä½ããã©ãã°ãã¦ãªã
            } catch { print(#function, error) }
        }
    }
}


func é§ãEnglishãã¬ã¼ã³ãã­ã¹ãã«å¤æ(_ è·å: é§ã®ç¨®é¡, _ æã: Bool = false) -> String {
    switch è·å {
        case .æ­©: return æã ? "ï½" : "ï¼°"
        case .è§: return æã ? "ï½" : "ï¼¢"
        case .é£: return æã ? "ï½" : "ï¼²"
        case .é¦: return æã ? "ï½" : "ï¼¬"
        case .æ¡: return æã ? "ï½" : "ï¼®"
        case .é: return æã ? "ï½" : "ï¼³"
        case .é: return "ï¼§"
        case .ç: return "ï¼«"
    }
}

func ãã¬ã¼ã³ãã­ã¹ããé§ã«å¤æ(_ ãã­ã¹ã: String) -> (é£å¶: çå´ãçå´ã, è·å: é§ã®ç¨®é¡, æã: Bool)? {
    var é£å¶: çå´ãçå´ã = .çå´
    var è·å: é§ã®ç¨®é¡ = .æ­©
    var æã = false
    
    if ãã­ã¹ã.unicodeScalars.contains("Í") { é£å¶ = .çå´ }
    
    if let è·åãã­ã¹ã = ãã­ã¹ã.unicodeScalars.first?.description {
        switch è·åãã­ã¹ã {
            case "æ­©","ï¼°": è·å = .æ­©
            case "è§","ï¼¢": è·å = .è§
            case "é£","ï¼²": è·å = .é£
            case "é¦","ï¼¬": è·å = .é¦
            case "æ¡","ï¼®": è·å = .æ¡
            case "é","ï¼³": è·å = .é
            case "é","ï¼§": è·å = .é
            case "ç","ç","ï¼«": è·å = .ç
            case "ã¨","ï½": (è·å, æã) = (.æ­©, true)
            case "é¦¬","ï½": (è·å, æã) = (.è§, true)
            case "é¾","ï½": (è·å, æã) = (.é£, true)
            case "æ","ï½": (è·å, æã) = (.é¦, true)
            case "å­","ï½": (è·å, æã) = (.æ¡, true)
            case "å¨","ï½": (è·å, æã) = (.é, true)
            default: return nil
        }
    }

    return (é£å¶, è·å, æã)
}








//FIXME: >==== Error: ð¦.loadItem ====
//> [Pasteboard] Could not retrieve data representation of type public.utf8-plain-text. Error: Error Domain=NSCocoaErrorDomain Code=4099 "The connection to service created from an endpoint was invalidated from this process." UserInfo={NSDebugDescription=The connection to service created from an endpoint was invalidated from this process.}
//> Error Domain=NSItemProviderErrorDomain Code=-1000 "Data transfer has been cancelled." UserInfo={NSLocalizedDescription=Data transfer has been cancelled.}

//FIXME: >==== Error: ð¦.loadItem ====
//> Error Domain=NSItemProviderErrorDomain Code=-1000 "Cannot load representation of type public.text" UserInfo={NSLocalizedDescription=Cannot load representation of type public.text, NSUnderlyingError=0x283f97de0 {Error Domain=PBErrorDomain Code=0 "Cannot load representation of type public.utf8-plain-text" UserInfo={NSLocalizedDescription=Cannot load representation of type public.utf8-plain-text, NSUnderlyingError=0x283f945a0 {Error Domain=NSCocoaErrorDomain Code=4097 "connection to service with pid 68717 created from an endpoint" UserInfo={NSDebugDescription=connection to service with pid 68717 created from an endpoint}}}}}
 
//FIXME: MacOS(Desiened for iPad)ã§é§ç§»åãã§ããªãä¸å·å
//> 2022-07-04 19:41:05.721240+0900 å°æ£ç¤[11108:591202] Cannot find representation conforming to type com.apple.UIKit.private.drag-suggested-name
//> 2022-07-04 19:41:05.723046+0900 å°æ£ç¤[11108:591259] [DragAndDrop] UIDragging: dataForItemIndex:0 type:com.apple.UIKit.private.drag-suggested-name got error: Error Domain=NSItemProviderErrorDomain Code=-1000 "Cannot load representation of type com.apple.UIKit.private.drag-suggested-name" UserInfo={NSLocalizedDescription=Cannot load representation of type com.apple.UIKit.private.drag-suggested-name}
//> ã¢ããªå¤é¨ããã®ã¢ã¤ãã ã§ã
