//
//  GetDocumentRef.swift
//  Steps Calculator
//
//  Created by Shahryar Khan on 04/06/2021.
//  Copyright © 2021 HxB. All rights reserved.
//

import Foundation

class GetDocumentRef: GenericService {
    
    func getDocumentRef(completion: @escaping CompletionBlock<String>, failure: @escaping FailureBlock) {
        
        //Request
        let request = createURLRequest(urlString: "", requestType: .get, postData: "")
        
        let session = URLSession.shared
        if request != nil {
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
                
            }else if (urlResponse as? HTTPURLResponse) != nil{
                
                
                //chcek if json is valid and does not contain error key
                let jsonString = String(data: data!, encoding:String.Encoding.utf8)
                if(jsonString!.count == 0) {
                    //json is not valid
                    //show error message
                    failure(Constants.GenericStrings.somethingWentWrong)
                } else {
                    
                    DispatchQueue.main.async {
                        
                        //Completion
                        let ref = self.parseRefJson(jsonString: jsonString ?? "")
                        dataManager.prismicRef = ref
                        completion(ref)
                    }
                    
                }
            }
        }
        task.resume()
        } else {
            failure("Invalid Url")
        }
    }
    
    private func parseRefJson(jsonString: String) -> String {
        
        do {
            //Converting json to dictionary using JsonSerialization
            if let responseDictionary = try JSONSerialization.jsonObject(with: jsonString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, options: .allowFragments) as? [String: Any] {
                
                if let dataArray = responseDictionary["refs"] as? [[String : Any]] {
                    
                    guard let firstItem = dataArray.first else {
                        return ""
                    }
                    
                    return firstItem["ref"] as? String ?? ""
                }
                
                return ""
            }
        } catch  {
            
            //an exception has occured
            return ""
        }
        
        return ""
    }
}
