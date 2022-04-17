//
//  CurrencyDetailViewController.swift
//  CryptoMarket
//
//  Created by Kris on 17.04.2022.
//

import Foundation
import UIKit

class CurrencyDetailViewController : UIViewController {
    
    @IBOutlet var USDRateLabel : UILabel!
    @IBOutlet var totalMaxCoinsLabel : UILabel!
    @IBOutlet var marketCapitalizationLabel : UILabel!
    @IBOutlet var change1HourLabel : UILabel!
    @IBOutlet var change24HoursLabel : UILabel!
    @IBOutlet var change7daysLabel : UILabel!

    
    public var currency: Currency?
    
    override func viewDidLoad() {
        
        if let symbol = currency?.symbol, let rate = currency?.rateUSD {
            self.USDRateLabel.text = "1 \(symbol) = \(rate) USD"
        }

        if let total = currency?.totalCoins, let max = currency?.maxCoins {
            self.totalMaxCoinsLabel.text = "Total Coins: \(total) \n Max Coins: \(max)"
        }
        else if let total = currency?.totalCoins {
            self.totalMaxCoinsLabel.text = "Total Coins: \(total)"
        }
        else if let max = currency?.maxCoins {
            self.totalMaxCoinsLabel.text = "Max Coins: \(max)"
        }

        if let cap = currency?.marketCapitalization {
            self.marketCapitalizationLabel.text = "Market Capitalization: \(cap)"
        }
        
        updatePercentForPeriod(currency?.percentChange1Hour, percentLabel: self.change1HourLabel)
        updatePercentForPeriod(currency?.percentChange24Hours, percentLabel: self.change24HoursLabel)
        updatePercentForPeriod(currency?.percentChange7Days, percentLabel: self.change7daysLabel)
    }
    
    func updatePercentForPeriod(_ periodValue:Float?, percentLabel:UILabel)
    {
        if let percent = periodValue {
            percentLabel.text = String(format: "%.2f", percent)
            percentLabel.textColor = UIColor.black
            if percent > 0.0 {
                percentLabel.textColor = UIColor.green
                percentLabel.text = String(format: "+%.2f", percent)
            }
            else if percent < 0.0 {
                percentLabel.textColor = UIColor.red
            }
        }
    }
}
