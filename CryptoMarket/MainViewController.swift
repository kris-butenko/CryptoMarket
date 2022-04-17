//
//  ViewController.swift
//  CryptoMarket
//
//  Created by Kris on 13.04.2022.
//

import UIKit
import Reachability

class MainViewController: UIViewController {

    private var currencies : Array<Currency>?
    private var fullCurrenciesArray : Array<Currency>?
    @IBOutlet var collectionView : UICollectionView!
    
    private var selectedCurrency : Currency?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.collectionView.refreshControl = UIRefreshControl()
        self.collectionView.refreshControl?.addTarget(self, action: #selector(MainViewController.refresh), for: .valueChanged)
        
        let reachability = try? Reachability()
        if let conn = reachability?.connection, conn != .unavailable {
            loadCurrenciesList()
        }
        else {
            updateCurrenciesList()
        }
        
        DatabaseManager.sharedInstance.addObserver(self, forKeyPath: #keyPath(DatabaseManager.currencies), options: [.new, .old], context:nil)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            
        if keyPath == #keyPath(DatabaseManager.currencies) {
            if let newValue = change?[NSKeyValueChangeKey.newKey] as? Array<Currency> {
              // print("Data changed: \(newValue)")
                self.currencies = newValue
                self.collectionView.reloadData()
            }
        }
    }


    func loadCurrenciesList()
    {
        self.collectionView.refreshControl?.isHidden = false
        self.collectionView.refreshControl?.beginRefreshing()
        
        NetworkManager.sharedInstance.loadCurrencies()
            { [weak self] (error, currencies) in
            
            if let err = error {
                self?.showAlertWithError(err)
            }
            else {
                
                DatabaseManager.sharedInstance.saveCurrensies(currencies!)
                self?.currencies = currencies
                self?.fullCurrenciesArray = currencies
                self?.collectionView.reloadData()
                self?.collectionView.refreshControl?.endRefreshing()
            }
        }
    }
   
    func updateCurrenciesList()
    {
        self.collectionView.refreshControl?.isHidden = false
        self.collectionView.refreshControl?.beginRefreshing()
        
        self.currencies = DatabaseManager.sharedInstance.fetchedCurrensies()
        self.fullCurrenciesArray = currencies
        self.collectionView.reloadData()
        self.collectionView.refreshControl?.endRefreshing()
    }
    
    
    func showAlertWithError(_ error:AnyError) {
        let message: String?
        switch error {
        case let .invalidRequest(reason):  message = reason
        case let .notFound(reason):  message = reason
        case let .invalidJson(reason):  message = reason
        default:  message = nil
        }
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: IBActions

    @IBAction func refresh() {
        updateCurrenciesList()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CurrencyDetailSegueIdentifier" {
            if let viewCtrl = segue.destination as? CurrencyDetailViewController {
                viewCtrl.currency = self.selectedCurrency
            }
        }
    }
}


extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    static let cellIdentifier = "CurrencyCellIdentifier"
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.currencies?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell:CurrencyCell? = self.collectionView.dequeueReusableCell(withReuseIdentifier: MainViewController.cellIdentifier, for: indexPath) as? CurrencyCell
        
        if let currency = self.currencies?[indexPath.row] {
            cell?.currency = currency
        }
        return cell!
    }
    
    // MARK: - UICollectionViewDelegate
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let currency = self.currencies?[indexPath.row] {
            self.selectedCurrency = currency
            self.performSegue(withIdentifier: "CurrencyDetailSegueIdentifier", sender: nil)
        }
        
    }

}

extension MainViewController: UISearchBarDelegate {
    
    // MARK: - UISearchBarDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.count > 1 {
            self.currencies = self.fullCurrenciesArray?.filter { $0.name!.lowercased().contains(searchText.lowercased()) }
        }
        else {
            self.currencies = self.fullCurrenciesArray
        }
        self.collectionView.reloadData()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        self.currencies = self.fullCurrenciesArray
        self.collectionView.reloadData()
    }
    
}
