//
//  Constants.swift
//  OnTheMap
//
//  Created by Richard H on 06/07/2017.
//  Copyright © 2017 Richard H. All rights reserved.
//

import Foundation



struct Constants{
    
    
    struct Login{
        
        static let url = "https://www.udacity.com/api/session"
        static let udacity = "https://www.udacity.com"
        
        
    }
    
    
    struct Parse{
        static let AppID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let APIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let Url = "https://parse.udacity.com/parse/classes/StudentLocation"
        static let scheme = "https"
        static let host = "parse.udacity.com"
        static let path = "/parse/classes/StudentLocation"
    }
    
    struct User{
        static var sessionId = ""
        static var studentId = ""
        static var studentLocations = [StudentLocation]()
        static var firstname = "Richard"
        static var lastname = "Hall"
        static var longitude = ""
        static var latitude = ""
        
        static let UserDataUrl = "https://www.udacity.com/api/users"
    }
    
    
}
