//
//  ConnectionHandler.swift
//  OnTheMap
//
//  Created by Richard H on 06/07/2017.
//  Copyright © 2017 Richard H. All rights reserved.
//

import Foundation
import UIKit

class ConnectionHandler: NSObject{
    
    
    
    //Mark: Initialisers
    override init() {
        super.init()
        
        
    }
    
    //Mark: get the session id from Udacity login
    func getUdacityLoginSession(parameters: [String:AnyObject], completionHandler: @escaping (_ sessionId: String?, _ error: String? ) -> Void){
        
        print(self.isInternetAvailable())
        
        if self.isInternetAvailable() {
            //make a request and set the paramaters
            let request = NSMutableURLRequest(url: URL(string: Constants.Login.url)!)
            let methodParameters = parameters
            let jsonParameters = ["udacity" : parameters] as [String:AnyObject]
            
            let jsonBody = try? JSONSerialization.data(withJSONObject: jsonParameters)
            
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonBody
            
            let task = URLSession.shared.dataTask(with: (request as URLRequest)) { (data, response, error) in
                
                //display the error
                func displayError(errorString: String){
                    print("ERROR: " + error.debugDescription)
                    completionHandler(nil, errorString)
                    
                    if data != nil{
                        let responseString = NSString(data:data!, encoding: String.Encoding.utf8.rawValue)!
                        print(responseString)
                    }
                }
                
                //check if error exists
                guard (error == nil) else{
                    displayError(errorString: "Failed to get the session from Udacity")
                    return
                }
                
                //check the status code
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else{
                    let statusCode = (response as? HTTPURLResponse)?.statusCode
                    if statusCode! >= 400 && statusCode! <= 499{
                        displayError(errorString: "Incorrect credentials provided. Please check and try again")
                    }else{
                        displayError(errorString: "The status code of the request was outside the accepted 2xx range")
                    }
                    
                    
                    return
                }
                
                guard data != nil else{
                    displayError(errorString: "The response returned no data")
                    return
                }
                
                //
                let range = Range(5..<data!.count)
                let newData = data?.subdata(in: range)
                
                var parsedResults = try? JSONSerialization.jsonObject(with: newData! , options: .allowFragments) as! [String:AnyObject]
                
                if let sessionId = parsedResults?["session"]?["id"] as? String, let key =  parsedResults?["account"]?["key"] as? String{
                    Constants.User.studentId = key
                    Constants.User.sessionId = sessionId
                    completionHandler(sessionId, nil)
                }else{
                    displayError(errorString: "Failed to sort the data")
                }
                
                
                
                
                
            }
            
            task.resume()
        } else {
            completionHandler(nil, "You have no internet connection")
        }
        
    }
    
    
    
    //Mark: logout with udacity session
    func logoutWithUdaticySession(sessionId: String, completionHandler: @escaping (_ loggedOut: Bool, _ error: String?) -> Void){
        
        if self.isInternetAvailable() {
            let request = NSMutableURLRequest(url: URL(string: Constants.Login.url)!)
            
            request.httpMethod = "DELETE"
            var xsrfCookie: HTTPCookie? = nil
            let sharedCookieStorage = HTTPCookieStorage.shared
            for cookie in sharedCookieStorage.cookies! {
                if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
            }
            
            if xsrfCookie != nil{
                request.setValue(xsrfCookie?.value, forHTTPHeaderField: "X-XSRF-TOKEN")
            }
            
            let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
                
                //display the error
                func displayError(errorString: String){
                    
                    completionHandler(false, errorString)
                    
                    if data != nil{
                        let responseString = NSString(data:data!, encoding: String.Encoding.utf8.rawValue)!
                        print(responseString)
                    }
                }
                
                //check if error exists
                guard (error == nil) else{
                    displayError(errorString: "Failed to get cancel session with Udacity")
                    return
                }
                
                //check the status code
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else{
                    displayError(errorString: "The status code of the request was outside the accepted 2xx range")
                    return
                }
                
                guard data != nil else{
                    displayError(errorString: "The response returned no data")
                    return
                }
                
                let range = Range(5..<data!.count)
                let newData = data?.subdata(in: range)
                
                var parsedResults = try? JSONSerialization.jsonObject(with: newData! , options: .allowFragments) as! [String:AnyObject]
                
                if (parsedResults?["session"]) != nil{
                    completionHandler(true, nil)
                }else{
                    displayError(errorString: "Failed to get cancel session with Udacity")
                }
                
                
            }
            
            task.resume()
            
        }else{
            completionHandler(false, "You have no internet connection")
        }
        
        
        
    }
    
    //Mark: get the data for the posting user
    func fetchUserData(userId: String, completionHandler: @escaping (_ results: [String:String]?, _ error: String?) -> Void){
        
        
        if self.isInternetAvailable() {
            
            let url = "\(Constants.User.UserDataUrl)/\(userId)"
            print(url)
            let request = NSMutableURLRequest(url: URL(string: url)!)
            
            let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
                
                //display the error
                func displayError(errorString: String){
                    print(errorString)
                    completionHandler(nil, errorString)
                    
                    if data != nil{
                        let responseString = NSString(data:data!, encoding: String.Encoding.utf8.rawValue)!
                        print(responseString)
                    }
                }
                
                //check if error exists
                guard (error == nil) else{
                    displayError(errorString: "Failed to get user data with Udacity")
                    return
                }
                
                //check the status code
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else{
                    displayError(errorString: "The status code of the request was outside the accepted 2xx range")
                    return
                }
                
                guard data != nil else{
                    displayError(errorString: "The response returned no data")
                    return
                }
                
                let range = Range(5..<data!.count)
                let newData = data?.subdata(in: range)
                
                var parsedResults = try? JSONSerialization.jsonObject(with: newData! , options: .allowFragments) as! [String:AnyObject]
                
                if let firstname = parsedResults?["user"]?["first_name"], let lastname = parsedResults?["user"]?["last_name"]{
                    
                    let name = ["firstname": firstname, "lastname": lastname] as! [String: String]
                    
                    completionHandler(name, nil)
                    
                }else{
                    completionHandler(nil, "Failed to sort the user data")
                }
                
                
            }
            task.resume()
            
        }
        
        
    }
    
    
    //Mark: post a new student location
    func parsePostMethodTask(parameters: [String : AnyObject], completionHandler: @escaping(_ results: String?, _ error: String?) -> Void){
     
        if self.isInternetAvailable() {
            
            let request = NSMutableURLRequest(url: URL(string:Constants.Parse.Url)!)
            
            request.httpMethod = "POST"
            request.addValue(Constants.Parse.AppID, forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue(Constants.Parse.APIKey, forHTTPHeaderField: "X-Parse-REST-API_Key")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let jsonBody = try? JSONSerialization.data(withJSONObject: parameters)
            request.httpBody = jsonBody
            
            let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
                
                //display the error
                func displayError(errorString: String){
                    print(errorString)
                    completionHandler(nil, errorString)
                    
                    if data != nil{
                        let responseString = NSString(data:data!, encoding: String.Encoding.utf8.rawValue)!
                        print(responseString)
                    }
                }
                
                //check if error exists
                guard (error == nil) else{
                    displayError(errorString: "Failed to post to parse")
                    return
                }
                
                //check the status code
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else{
                    displayError(errorString: "The status code of the request was outside the accepted 2xx range")
                    return
                }
                
                guard data != nil else{
                    displayError(errorString: "The response returned no data")
                    return
                }
                
                let parsedResults = try? JSONSerialization.jsonObject(with: data! , options: .allowFragments) as! [String:AnyObject]
                
                if let _ =  parsedResults?["objectId"]{
                    completionHandler("successful", nil)
                }else{
                    displayError(errorString: "Failed to post to the parse server")
                }
                
            }
            
            task.resume()
            
        }else{
            completionHandler(nil, "You have no internet connection")
        }
        
        
    }
    
    //Mark: get the parse data
    func parseGetMethodTask(parameters: [String: AnyObject], completionHandler: @escaping(_ results: String?, _ error: String?) -> Void){
        
        if self.isInternetAvailable() {
            
            var components = URLComponents()
            //let url = URL(string: Constants.Parse.Url)
            components.scheme = Constants.Parse.scheme
            components.host = Constants.Parse.host
            components.path = Constants.Parse.path
            components.queryItems = parameters.map{
                URLQueryItem(name: $0, value: $1 as? String)
            }
            
            
            let request = NSMutableURLRequest(url:components.url!)
            request.addValue(Constants.Parse.AppID, forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue(Constants.Parse.APIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
            
            let task = URLSession.shared.dataTask(with: (request as URLRequest)) { (data, response, error) in
                
                //display the error
                func displayError(errorString: String){
                    
                    completionHandler(nil, errorString)
                    
                    if data != nil{
                        let responseString = NSString(data:data!, encoding: String.Encoding.utf8.rawValue)!
                        print(responseString)
                    }
                }
                
                //check if error exists
                guard (error == nil) else{
                    displayError(errorString: "Failed to get the date from parse")
                    return
                }
                
                //check the status code
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else{
                    let statusCode = (response as? HTTPURLResponse)?.statusCode
                    if statusCode! >= 400 && statusCode! <= 499{
                        displayError(errorString: "Incorrect credentials provided. Please check and try again")
                    }else{
                        displayError(errorString: "The status code of the request was outside the accepted 2xx range")
                    }
                    
                    
                    return
                }
                
                guard data != nil else{
                    displayError(errorString: "The response returned no data")
                    return
                }
                
                let parsedResults = try? JSONSerialization.jsonObject(with: data! , options: .allowFragments) as! [String:AnyObject]
                
                if let resultsArray = parsedResults?["results"] as? [AnyObject]{
                    
                    for result in resultsArray{
                        
                        let location = StudentLocation(parameters: result as! Dictionary)
                        
                        Constants.User.studentLocations.append(location)
                        
                    }
                    
                    completionHandler("got them", nil)
                    
                    
                }else{
                    completionHandler(nil, "Failed to establish student locations from list")
                }
                
            }
        
        
            task.resume()
            
        }else{
            completionHandler(nil, "You have no internet connection")
        }
        
        
        
    }
    
    
    //Check the internet is available
    func isInternetAvailable() -> Bool{
        
        let appDelegate =  UIApplication.shared.delegate as! AppDelegate
        
        return appDelegate.hasInternetConnection()
        
    }
    
   
}

