//
//  GetArticles.swift
//  Steps Calculator
//
//  Created by Shahryar Khan on 04/06/2021.
//  Copyright © 2021 HxB. All rights reserved.
//

import Foundation

typealias CompletionBlock<T> = (_ result: T?) -> Void
typealias FailureBlock = (_ errorString: String?) -> Void

enum RequestType {
    case get
    case post
    case delete
    case put
}

class GenericService {
    
    //MARK:- URL Request
    func createURLRequest(urlString: String, requestType: RequestType, postData: String) -> URLRequest? {
        
        
        //Request
        let url = URL(string: Constants.ServiceConfiguration.baseURL + urlString)
        if url != nil {
            var request =  URLRequest(url: url!)
            
            //Post Data
            if (requestType == .post) {
                
                request.httpMethod = "POST"
                request.addValue("multipart/form-data", forHTTPHeaderField: "Content-Type")
                request.httpBody = postData.data(using: .utf8)
            } else if requestType == .put {
                
                request.httpMethod = "PUT"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = postData.data(using: .utf8)
            } else if requestType == .delete {
                
                request.httpMethod = "DELETE"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = postData.data(using: .utf8)
            } else {
                
                request.httpMethod = "GET"
                request.addValue("text/plain", forHTTPHeaderField: "Content-Type")
            }
            
            //generic header
            request.addValue("*/*", forHTTPHeaderField: "Accept")
            
            return request
        } else {
            return nil
        }
    }
    
    
    //MARK:- Creating request payload
    //payload from dictionary
    func getJsonStringFromDictionary(_ dic:NSDictionary) -> String {
        var jsonString = String()
        
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dic, options: JSONSerialization.WritingOptions.prettyPrinted)
            // here "jsonData" is the dictionary encoded in JSON data
            jsonString = String(data: jsonData, encoding:String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
            
            
        } catch {
            
        }
        return jsonString
    }
    
    //payload from Array
    func getJsonStringFromArray(_ array:NSArray)->String{
        var jsonString = String()
        
        
        do {
            
            let jsonData = try JSONSerialization.data(withJSONObject: array, options: JSONSerialization.WritingOptions.prettyPrinted)
            // here "jsonData" is the dictionary encoded in JSON data
            jsonString = String(data: jsonData, encoding:String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
            
        } catch {
            
        }
        return jsonString
    }
    
    //MARK:- Parse Error Message
    func checkIfErrorFromJsonDict(responseDictionary: [String: Any]) -> [String] {
        
        var errorMessages = [String]()
        
        if let status = responseDictionary["status_code"] as? Int {
            
            if status == 500 {
                
                //failure
                //sample response: {"message":"DateTime::__construct(): Failed to parse time string (15) at position 0 (1): Unexpected character","status_code":500}
                if let errorMessage = responseDictionary["message"] as? String {
                    errorMessages.append(errorMessage)
                } else {
                    errorMessages.append(Constants.GenericStrings.somethingWentWrong)
                }
            } else if status != 200 {
                
                
                //failure
                //parsing the error dictionary
                if let errorDictionary = responseDictionary["errors"] as? [String : Any] {
                    
                    for (_, value) in errorDictionary {
                        errorMessages.append(value as! String)
                    }
                } else {
                    
                    //cannot parse error message
                    errorMessages.append(Constants.GenericStrings.somethingWentWrong)
                }
            }
        } else {
            
            //canot parse response
            errorMessages.append(Constants.GenericStrings.somethingWentWrong)
        }
        
        return errorMessages
    }
    
    func checkIfErrorsExist(jsonString: String) -> [String] {
        
        var errorMessages = [String]()
        
        do {
            if let responseDictionary = try JSONSerialization.jsonObject(with: jsonString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, options: .allowFragments) as? [String: Any] {
                
                if let status = responseDictionary["status"] as? String {
                    
                    if status == "error" {
                        
                        //failure
                        //sample response: {"message":"DateTime::__construct(): Failed to parse time string (15) at position 0 (1): Unexpected character","status_code":500}
                        if let errorMessage = responseDictionary["msg"] as? String {
                            errorMessages.append(errorMessage)
                        } else {
                            errorMessages.append(Constants.GenericStrings.somethingWentWrong)
                        }
                    }
                } else {
                    
                    //canot parse response
                    errorMessages.append(Constants.GenericStrings.somethingWentWrong)
                }
            }
        } catch  {
            
            //an exception has occured
            errorMessages.append(Constants.GenericStrings.somethingWentWrong)
        }

        return errorMessages
    }
}

class GetArticles: GenericService {
    
    func get(completion: @escaping CompletionBlock<[Article]>, failure: @escaping FailureBlock) {
        
        let urlString = "/documents/search?ref=\(dataManager.prismicRef ?? "")&q=%5B%5Bat(document.type%2C%22content_builder%22)%5D%5D#format=json"
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
                            let articles = self.parseJson(jsonString: jsonString ?? "")
                            completion(articles)
                        }
                    }
                    
                }
            }
            task.resume()
        } else {
            failure("Invalid Url")
        }
    }
    
    private func parseJson(jsonString: String) -> [Article] {
        
        var articles = [Article]()
        do {
            //Converting json to dictionary using JsonSerialization
            if let responseDictionary = try JSONSerialization.jsonObject(with: jsonString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, options: .allowFragments) as? [String: Any] {
                
                if let dataArray = responseDictionary["results"] as? [[String : Any]] {
                    for data in dataArray {
                        var article = Article()
                        if let data = data["data"] as? [String: Any] {
                            article.title = data["title"] as? String ?? ""
                            article.desc = data["description"] as? String ?? ""
                            let videoDict = data["video_link"] as? [String: Any] ?? [:]
                            article.videoLink = videoDict["url"] as? String ?? ""
                            let thumbnail = data["image"] as? [String: Any] ?? [:]
                            article.imageLink = thumbnail["url"] as? String ?? ""
                            let webDict = data["web_link"] as? [String: Any] ?? [:]
                            article.webLink = webDict["url"] as? String ?? ""
                            articles.append(article)
                        }
                    }
                }
                return articles
            }
        } catch  {
            
            //an exception has occured
            return articles
        }
        return articles
    }
}

