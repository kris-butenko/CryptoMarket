//
//  Currency.swift
//  CryptoMarket
//
//  Created by Kris on 13.04.2022.
//

import Foundation

class Currency : NSObject {
    
    public var name : String?
    public var symbol : String?
    
    public var rateUSD : Float?
    public var marketCapitalization : Double?
    public var totalCoins : UInt?
    public var maxCoins : UInt?
    public var percentChange1Hour : Float?
    public var percentChange24Hours : Float?
    public var percentChange7Days : Float?

    override init() {
       
    }
    
    init(_ dict: Dictionary<String, Any>) {
        
        name = dict["name"] as? String
        symbol = dict["symbol"] as? String
        
        if let coins = dict["total_supply"] as? UInt {
            totalCoins = UInt(coins)
        }
        if let coins = dict["max_supply"] as? UInt {
            maxCoins = UInt(coins)
        }
        
        if let quote = dict["quote"] as? Dictionary<String, Any> {
            let quoteUSD = quote["USD"] as? Dictionary<String, Any>
            if let rate = quoteUSD?["price"] as? Double {
                rateUSD = Float(rate)
            }
            if let cap = quoteUSD?["market_cap"] as? Double {
                marketCapitalization = Double(cap)
            }
            if let percent = quoteUSD?["percent_change_1h"] as? Double {
                percentChange1Hour = Float(percent)
            }
            if let percent = quoteUSD?["percent_change_24h"] as? Double {
                percentChange24Hours = Float(percent)
            }
            if let percent = quoteUSD?["percent_change_7d"] as? Double {
                percentChange7Days = Float(percent)
            }
        }
    }
}
