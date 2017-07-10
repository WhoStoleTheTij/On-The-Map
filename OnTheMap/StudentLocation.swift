//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by Richard H on 08/07/2017.
//  Copyright © 2017 Richard H. All rights reserved.
//

import Foundation


struct StudentLocation{
    
    var createdAt: Date?
    var objectId: String?
    var uniqueKey: String?
    var firstname: String?
    var lastname: String?
    var mapString: String?
    var mediaUrl: String?
    var latitude: Double?
    var longitude: Double?
    
    
    init(parameters: [String:AnyObject]){
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/mm/yy"
        
        createdAt = dateFormatter.date(from: parameters["createdAt"] as? String ?? "01/01/1970")
        objectId =  parameters["objectId"] as? String
        uniqueKey = parameters["uniqueKey"] as? String
        firstname = parameters["firstName"] as? String
        lastname = parameters["lastName"] as? String
        mapString = parameters["mapString"] as? String
        mediaUrl = parameters["mediaURL"] as? String
        latitude = parameters["latitude"] as? Double
        longitude = parameters["longitude"] as? Double
    }
    
    
}
