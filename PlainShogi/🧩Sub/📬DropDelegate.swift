
import SwiftUI
import UniformTypeIdentifiers

struct ð¬ç¤ä¸ãã­ãã: DropDelegate {
    var ð±: ð±AppModel
    var ä½ç½®: Int
    
    func performDrop(info: DropInfo) -> Bool {
        ð±.ç¤ä¸ã®ããã«ãã­ãããã(ä½ç½®, info)
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        ð±.ç¤ä¸ã®ããã¯ãã­ããå¯è½ãç¢ºèªãã(ä½ç½®)
    }
    
    func validateDrop(info: DropInfo) -> Bool {
        ð±.æå¹ãªãã­ããããã§ãã¯ãã(info)
    }
    
    init(_ âppModel: ð±AppModel, _ ï½²ï¾: Int) {
        ð± = âppModel
        ä½ç½® = ï½²ï¾
    }
}


struct ð¬ç¤å¤ãã­ãã: DropDelegate {
    var ð±: ð±AppModel
    var é£å¶: çå´ãçå´ã
    
    func performDrop(info: DropInfo) -> Bool {
        ð±.ç¤å¤ã®ãã¡ãå´ã«ãã­ãããã(é£å¶, info)
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        ð±.ç¤å¤ã®ããã¯ãã­ããå¯è½ãç¢ºèªãã(é£å¶)
    }
    
    func validateDrop(info: DropInfo) -> Bool {
        ð±.æå¹ãªãã­ããããã§ãã¯ãã(info)
    }
    
    init(_ âppModel: ð±AppModel, _ ï½¼ï¾ï¾ï½´ï½²: çå´ãçå´ã) {
        ð± = âppModel
        é£å¶ = ï½¼ï¾ï¾ï½´ï½²
    }
}
