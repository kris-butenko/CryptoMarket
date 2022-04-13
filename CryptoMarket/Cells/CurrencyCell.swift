//
//  CurrencyCell.swift
//  CryptoMarket
//
//  Created by Kris on 13.04.2022.
//

import Foundation
import UIKit

class CurrencyCell : UICollectionViewCell {
    
    @IBOutlet var nameLabel : UILabel!
    @IBOutlet var symbolLabel : UILabel!
    @IBOutlet var rateLabel : UILabel!

    public var currency: Currency? {
        didSet {
            self.nameLabel.text = currency?.name
            self.symbolLabel.text = currency?.symbol
            
            if let rate = currency?.rateUSD {
                rateLabel.text = String(format: "%.2f", rate)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
}
