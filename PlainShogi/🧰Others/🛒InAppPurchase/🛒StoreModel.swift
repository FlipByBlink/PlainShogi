
let 🛒InAppPurchaseProductID = "PlainShogi.adfree"


import StoreKit
import SwiftUI

typealias Transaction = StoreKit.Transaction

class 🛒StoreModel: ObservableObject {
    
    @Published private(set) var 🎫Product: Product?
    @Published private(set) var 🚩Purchased: Bool? = nil
    
    @AppStorage("🄻aunchCount") var 🄻aunchCount: Int = 0
    
    var 🚩ADisActive: Bool {
        !(🚩Purchased ?? true) && ( 🄻aunchCount > 5 )
    }
    
    var 🚩Unconnected: Bool { 🎫Product == nil }
    
    var 🤖UpdateListenerTask: Task<Void, Error>? = nil
    
    
    init() {
        //Start a transaction listener as close to app launch as possible so you don't miss any transactions.
        🤖UpdateListenerTask = 📪ListenForTransactions()
        
        Task {
            //During store initialization, request products from the App Store.
            await 🅁equestProducts()
            
            //Deliver products that the customer purchases.
            await 🅄pdateCustomerProductStatus()
        }
        
        🄻aunchCount += 1
    }
    
    deinit { 🤖UpdateListenerTask?.cancel() }
    
    
    func 📪ListenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            //Iterate through any transactions that don't come from a direct call to `purchase()`.
            for await 📦 in Transaction.updates {
                do {
                    let 🧾Transaction = try self.🔍CheckVerified(📦)
                    
                    //Deliver products to the user.
                    await self.🅄pdateCustomerProductStatus()
                    
                    //Always finish a transaction.
                    await 🧾Transaction.finish()
                } catch {
                    //StoreKit has a transaction that fails verification. Don't deliver content to the user.
                    print("Transaction failed verification")
                }
            }
        }
    }
    
    
    @MainActor
    func 🅁equestProducts() async {
        do {
            if let 📦 = try await Product.products(for: [🛒InAppPurchaseProductID]).first {
                🎫Product = 📦
            }
        } catch {
            print(#function, "Failed product request from the App Store server: \(error)")
        }
    }
    
    
    func 👆Purchase() async throws {
        guard let 🎫 = 🎫Product else { return }
        
        let 📦Result = try await 🎫.purchase()
        
        switch 📦Result {
            case .success(let 📦):
                //Check whether the transaction is verified. If it isn't,
                //this function rethrows the verification error.
                let 🧾Transaction = try 🔍CheckVerified(📦)
                
                //The transaction is verified. Deliver content to the user.
                await 🅄pdateCustomerProductStatus()
                
                //Always finish a transaction.
                await 🧾Transaction.finish()
            case .userCancelled, .pending: return
            default: return
        }
    }
    
    
    func 🔍CheckVerified<T>(_ 📦Result: VerificationResult<T>) throws -> T {
        //Check whether the JWS passes StoreKit verification.
        switch 📦Result {
            case .unverified:
                //StoreKit parses the JWS, but it fails verification.
                throw 🚨StoreError.failedVerification
            case .verified(let 📦):
                //The result is verified. Return the unwrapped value.
                return 📦
        }
    }
    
    
    @MainActor
    func 🅄pdateCustomerProductStatus() async {
        var 🄿urchased = false
        
        for await 📦 in Transaction.currentEntitlements {
            do {
                //Check whether the transaction is verified. If it isn’t, catch `failedVerification` error.
                let 🧾Transaction = try 🔍CheckVerified(📦)
                if 🧾Transaction.productID == 🛒InAppPurchaseProductID {
                    🄿urchased = true
                }
            } catch {
                print(#function, error)
            }
        }
        
        🚩Purchased = 🄿urchased
    }
    
    
    var 🎫Name: String {
        guard let 🎫 = 🎫Product else { return "(Placeholder)" }
        return 🎫.displayName
    }
    
    
    var 🎫Price: String {
        guard let 🎫 = 🎫Product else { return "…" }
        return 🎫.displayPrice
    }
}


public enum 🚨StoreError: Error {
    case failedVerification
}
