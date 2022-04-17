//
//  DatabaseManager.swift
//  CryptoMarket
//
//  Created by Kris on 16.04.2022.
//

import Foundation
import UIKit
import CoreData

final class DatabaseManager : NSObject {
    
    static let sharedInstance = DatabaseManager()
    static let currencyEntityName = "CryptoCurrency"
    
    @objc dynamic var currencies : Array<Currency>?
    
    var managedContext: NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
     }
    
    override init() {
        super.init()
        _ = Timer.scheduledTimer(withTimeInterval: 5*60, repeats: true) { [weak self] timer in
            NetworkManager.sharedInstance.loadCurrencies()
                { [weak self] (error, array) in
                     if let currencies = array {
                         self?.currencies = currencies
                         self?.saveCurrensies(currencies)
                     }
                     else {
                     }
                 }
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(networkStatusChanged(_:)),
            name: .reachabilityChanged,
            object: nil
        )
    }
    
    
    @objc func networkStatusChanged(_ notification: Notification) {
        self.currencies = fetchedCurrensies()
    }
    
    func saveCurrensies(_ array: Array<Currency>) {
        
        deleteAllCurrensies()
        do {
            for currency in array {
                try self.save(currency: currency)
            }
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        let defaults = UserDefaults.standard
        defaults.set(Date(), forKey: "lastDatabaseUpdate")
    }
    
    func deleteAllCurrensies() {

        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: DatabaseManager.currencyEntityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do
        {
            try self.managedContext.execute(deleteRequest)
            try self.managedContext.save()
        }
        catch
        {
            print ("There was an error")
        }
    }
    
    func fetchedCurrensies() -> Array<Currency> {
        var currencies = Array<Currency>()
        let fetchRequest = NSFetchRequest<CryptoCurrency>(entityName: DatabaseManager.currencyEntityName)
        do {
            let array = try managedContext.fetch(fetchRequest)
            for data in array {
                let currency = convertCryptoDataToCurrency(data)
                currencies.append(currency)
            }
            return currencies
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return currencies
    }
    
    func convertCryptoDataToCurrency(_ data:CryptoCurrency) -> Currency {
        let currency = Currency()
        currency.name = data.name
        currency.symbol = data.symbol
        currency.rateUSD = data.rateUSD
        currency.marketCapitalization = data.capitalization
        currency.totalCoins = UInt(data.totalCoins)
        currency.maxCoins = UInt(data.maxCoins)
        currency.percentChange1Hour = data.change1Hour
        currency.percentChange24Hours = data.change24Hours
        currency.percentChange7Days = data.change7Days

        return currency
    }
    
    private func save(currency: Currency) throws {
      
        let entity = NSEntityDescription.entity(forEntityName: DatabaseManager.currencyEntityName, in: self.managedContext)!
        let object = NSManagedObject(entity: entity, insertInto: self.managedContext) as? CryptoCurrency
    
        object?.name = currency.name
        object?.symbol = currency.symbol
        object?.rateUSD = currency.rateUSD ?? 0.0
        object?.capitalization = currency.marketCapitalization ?? 0.0
        object?.totalCoins = Int64(currency.totalCoins ?? 0)
        object?.maxCoins = Int64(currency.maxCoins ?? 0)
        object?.change1Hour = currency.percentChange1Hour ?? 0.0
        object?.change24Hours = currency.percentChange24Hours ?? 0.0
        object?.change7Days = currency.percentChange7Days ?? 0.0

        do {
            try self.managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    
}

