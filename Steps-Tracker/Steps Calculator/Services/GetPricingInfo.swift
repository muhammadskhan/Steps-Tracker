//
//  GetPricingInfo.swift
//  Steps Calculator
//
//  Created by Shahryar Khan on 07/07/2021.
//  Copyright © 2021 HxB. All rights reserved.
//

import Foundation

class GetPricingInfo: GenericService {
    
    func get(completion: @escaping CompletionBlock<SubscriptionPricing>, failure: @escaping FailureBlock) {
        
        let urlString = "/documents/search?ref=\(dataManager.prismicRef ?? "")&q=%5B%5Bat(document.type%2C%22subscription_pricing%22)%5D%5D#format=json"
        //Request
        let request = self.createURLRequest(urlString: urlString, requestType: .get, postData: "")
        if request != nil {
            let session = URLSession.shared
            let task = session.dataTask(with: request!) { (data, urlResponse, error) in
                if (error != nil) {
                    //we got error from service
                    if let nsError = error as NSError? {
                        if (nsError.code == NSURLErrorTimedOut) {
                            failure(Constants.GenericStrings.requestTimedOut)
                        } else if (nsError.code == NSURLErrorCannotConnectToHost || nsError.code == NSURLErrorNetworkConnectionLost || nsError.code == NSURLErrorNotConnectedToInternet) {
                            failure(Constants.GenericStrings.internetNotFound)
                        } else {
                            failure(Constants.GenericStrings.somethingWentWrong)
                        }
                    } else {
                        failure(Constants.GenericStrings.somethingWentWrong)
                    }
                    
                } else if (urlResponse as? HTTPURLResponse) != nil {
                    
                    
                    //chcek if json is valid and does not contain error key
                    let jsonString = String(data: data!, encoding:String.Encoding.utf8)
                    if(jsonString!.count == 0) {
                        //json is not valid
                        //show error message
                        failure(Constants.GenericStrings.somethingWentWrong)
                    } else {
                        
                        
                        DispatchQueue.main.async {
                            
                            //Completion
                            let pricing = self.parseJson(jsonString: jsonString ?? "")
                            completion(pricing)
                        }
                    }
                    
                }
            }
            task.resume()
        } else {
            failure("Invalid Url")
        }
    }
    
    private func parseJson(jsonString: String) -> SubscriptionPricing {
        
        var pricing = SubscriptionPricing()
        do {
            //Converting json to dictionary using JsonSerialization
            if let responseDictionary = try JSONSerialization.jsonObject(with: jsonString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, options: .allowFragments) as? [String: Any] {
                
                if let dataArray = responseDictionary["results"] as? [[String : Any]] {
                    
                    guard let data = dataArray.first else {
                        return pricing
                    }
                    if let data = data["data"] as? [String: Any] {
                        pricing.price = data["price"] as? String ?? ""
                        pricing.discountedPrice = data["discounted_price"] as? String ?? ""
                    }
                }
                return pricing
            }
        } catch  {
            
            //an exception has occured
            return pricing
        }
        return pricing
    }
}

struct SubscriptionPricing {
    var price = ""
    var discountedPrice = ""
}
