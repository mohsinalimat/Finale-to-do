//
//  IAPManager.swift
//  Finale To Do
//
//  Created by Grant Oganan on 5/13/22.
//

import Foundation
import StoreKit

class IAPManager : NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    static let instance = IAPManager()
    
    let unlockAllPerksID = "UnlockAllPerks"
    
    func configure () {
        SKPaymentQueue.default().add(self)
    }
    
    func buyProduct(_ product: SKProduct) {
        print("Sending the Payment Request to Apple")
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    func RestorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Error %@ \(error)")
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("Got the request from Apple")
        let count: Int = response.products.count
        if count > 0 {
            _ = response.products
            let validProduct: SKProduct = response.products[0]
            print(validProduct.localizedTitle)
            print(validProduct.localizedDescription)
            print(validProduct.price)
            buyProduct(validProduct);
        }
        else {
            print("No products")
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("Received Payment Transaction Response from Apple");
        
        for transaction: AnyObject in transactions {
            if let trans: SKPaymentTransaction = transaction as? SKPaymentTransaction {
                switch trans.transactionState {
                case .purchased:
                    print("Product Purchased")
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    HandlePurchase(id: trans.payment.productIdentifier)
                    break
                case .failed:
                    print("Purchased Failed")
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    break
                case .restored:
                    print("Product Restored")
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    HandlePurchase(id: trans.payment.productIdentifier)
                    break
                default:
                    break
                }
            }
            else {
                
            }
        }
    }
    
    func unlockProduct(_ productIdentifier: String!) {
        if SKPaymentQueue.canMakePayments() {
            let productID: NSSet = NSSet(object: productIdentifier)
            let productsRequest: SKProductsRequest = SKProductsRequest(productIdentifiers: productID as! Set<String>)
            productsRequest.delegate = self
            productsRequest.start()
            print("Fetching Products")
        }
        else {
            print("Сan't make purchases")
        }
    }
    
    func PurchaseUnlockAllPerks() {
        unlockProduct(unlockAllPerksID)
    }
    
    func HandlePurchase(id: String) {
        if id == unlockAllPerksID {
            StatsManager.stats.purchasedUnlockAllPerks = true
            SaveManager.instance.SaveData()
        }
    }
}
