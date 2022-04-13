//
//  ViewController.swift
//  CryptoMarket
//
//  Created by Kris on 13.04.2022.
//

import UIKit

class ViewController: UIViewController {

    private var currencies : Array<Currency>?
    private var fullCurrenciesArray : Array<Currency>?
    @IBOutlet var collectionView : UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.collectionView.refreshControl = UIRefreshControl()
        self.collectionView.refreshControl?.addTarget(self, action: #selector(ViewController.refresh), for: .valueChanged)
        
        updateCurrenciesList()
    }

    func updateCurrenciesList()
    {
        self.collectionView.refreshControl?.isHidden = false
        self.collectionView.refreshControl?.beginRefreshing()
        
       let params = ["start":"1","limit":"100", "convert":"USD"]
        NetworkManager.sharedInstance.getCurrenciesWithParameters(params)
        { [weak self] (error, currencies) in
            
            if let err = error {
                self?.showAlertWithError(err)
            }
            else {
                self?.currencies = currencies
                self?.fullCurrenciesArray = currencies
                self?.collectionView.reloadData()
                self?.collectionView.refreshControl?.endRefreshing()
            }
        }
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
}


extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    static let cellIdentifier = "CurrencyCellIdentifier"
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.currencies?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell:CurrencyCell? = self.collectionView.dequeueReusableCell(withReuseIdentifier: ViewController.cellIdentifier, for: indexPath) as? CurrencyCell
        
        if let currency = self.currencies?[indexPath.row] {
            cell?.currency = currency
        }
        return cell!
    }
    
    // MARK: - UICollectionViewDelegate
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }

}

extension ViewController: UISearchBarDelegate {
    
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
