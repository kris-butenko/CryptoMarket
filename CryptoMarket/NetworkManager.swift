//
//  NetworkManager.swift
//  CryptoMarket
//
//  Created by Kris on 13.04.2022.
//

import Foundation
import Alamofire

enum AnyError: Error {
    case unknownError
    case connectionError
    case invalidRequest(reason: String)
    case notFound(reason: String)
    case invalidResponse
    case serverError
    case serverUnavailable
    case timeOut
    case unsuppotedURL
    case invalidJson(reason: String)
 }


final class NetworkManager : NSObject {
    
    static let sharedInstance = NetworkManager()
    
    let domainURL = "https://pro-api.coinmarketcap.com/v1"
    let headerAPIKey = HTTPHeader(name: "X-CMC_PRO_API_KEY", value: "c5052912-e0f0-4402-a928-100dcaad50db")

    
    private func requestWithPath(_ path:String, params:Dictionary<String, String>,  completion: @escaping (AnyError?, Dictionary<String, Any>?) -> Void) {
        
        let request = AF.request(domainURL + "/" + path, method: .get, parameters: params, encoder: URLEncodedFormParameterEncoder.default, headers: [headerAPIKey], interceptor: nil, requestModifier: nil)
        
        let requestComplete: (HTTPURLResponse?, Result<String, AFError>) -> Void = { response, result in

            if response?.statusCode != 200 {
                let error = AnyError.invalidRequest(reason: "Invalid request")
                completion(error, nil)
            }
            else {
                if let jsonString = try? result.get() {
                    let jsonData: Data = jsonString.data(using: .utf8) ?? Data()
                    do {
                        let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options:JSONSerialization.ReadingOptions(rawValue: 0))
                        guard let dictionary = jsonObject as? Dictionary<String, Any> else {
                            let error = AnyError.notFound(reason: "Data is Not a Dictionary")
                            completion(error, nil)
                            return
                        }

                        print("JSON Dictionary! \(dictionary)")
                        completion(nil, dictionary)
                    }
                    catch let error {
                        let error = AnyError.invalidJson(reason: error.localizedDescription)
                        completion(error, nil)
                    }
                }
            }
        }
        
        request.responseString { response in
            requestComplete(response.response, response.result)
        }
    }
    
    func getCurrenciesWithParameters(_ params:Dictionary<String, String>, completion: @escaping (AnyError?, Array<Currency>?) -> Void) {
        
        self.requestWithPath("cryptocurrency/listings/latest", params: params) { error, dictResult in
            
            if error == nil {
                var currencies = Array<Currency>()
                if let dataArray = dictResult?["data"] as? Array<Dictionary<String, Any>> {
                    for item in dataArray {
                        let currency = Currency(item)
                        currencies.append(currency)
                    }
                }
                completion(nil, currencies)
            }
            else {
                completion(error, nil)
            }
        }
    }
    
    
}
