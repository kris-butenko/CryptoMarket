//
//  Currency.swift
//  CryptoMarket
//
//  Created by Kris on 13.04.2022.
//

import Foundation

class Currency {
    
    public var name : String?
    public var symbol : String?
    
    public var rateUSD : Float?

    
    init(_ dict: Dictionary<String, Any>) {
        
        name = dict["name"] as? String
        symbol = dict["symbol"] as? String
        
        if let quote = dict["quote"] as? Dictionary<String, Any> {
            let quoteUSD = quote["USD"] as? Dictionary<String, Any>
            if let rate = quoteUSD?["price"] as? Double {
                rateUSD = Float(rate)
            }
        }
    }
}
