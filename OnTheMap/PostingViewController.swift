//
//  PostingViewController.swift
//  OnTheMap
//
//  Created by Richard H on 09/07/2017.
//  Copyright © 2017 Richard H. All rights reserved.
//

import UIKit
import MapKit

class PostingViewController: UIViewController, MKMapViewDelegate {

    
    @IBOutlet weak var locationTextfield: UITextField!
    @IBOutlet weak var urlTextfield: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var submitButton: UIButton!
    
    let geocoder = CLGeocoder()
    
    let activityIndicator = UIActivityIndicatorView()
    
    var connectionHandler = ConnectionHandler()
    
    var parameters:[String:AnyObject]? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicator.frame = CGRect(origin: CGPoint(x:0, y:0), size: CGSize(width:self.view.frame.width, height:self.view.frame.height))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Mark: cancel post
    @IBAction func cancelAddingPin(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    @IBAction func findLocation(_ sender: Any) {
        
        
        guard let locationText = self.locationTextfield.text else {
            self.showUserErrorMessage(message: "Please enter a location")
            return
        }
        let mediaUrl = self.urlTextfield.text
        
        
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        
        geocoder.geocodeAddressString(locationText) { (placemarks, error) in
            
            
            if error != nil{
                self.showUserErrorMessage(message: "Failed to fetch your location. Please try again")
            }else{
                
                if (placemarks?.count)! > 0
                {
                    
                    let placemark = placemarks?[0]
                    let location = placemark?.location
                    let coordinate = location?.coordinate
                    
                    let lat = CLLocationDegrees((coordinate?.latitude)!)
                    let long = CLLocationDegrees((coordinate?.longitude)!)
                    
                    Constants.User.latitude = String(lat)
                    Constants.User.longitude = String(long)
                    
                    let mapCoord = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    
                    self.connectionHandler.fetchUserData(userId: Constants.User.studentId, completionHandler: { (results, error) in
                        
                        DispatchQueue.main.async{
                            self.activityIndicator.stopAnimating()
                            //self.view.willRemoveSubview(self.activityIndicator)
                            self.activityIndicator.removeFromSuperview()
                            
                            if error != nil{
                                self.showUserErrorMessage(message: error!)
                            }else{
                                let annotation = MKPointAnnotation()
                                annotation.coordinate = mapCoord
                                annotation.title = "\(results?["firstname"] ?? "") \(results?["lastname"] ?? "")"
                                annotation.subtitle = mediaUrl
                                self.mapView.addAnnotation(annotation)
                                
                                self.parameters = [
                                    "uniquekey" : Constants.User.studentId ,
                                    "firstName" : (results?["firstname"]) ?? "",
                                    "lastname" : (results?["lastname"]) ?? "",
                                    "mapString" : locationText,
                                    "mediaURL" : mediaUrl ?? "",
                                    "latitude" : lat,
                                    "longitude" : long
                                    ] as [String : AnyObject]
                                
                                let span = MKCoordinateSpanMake(0.5, 0.5)
                                let region = MKCoordinateRegionMake(annotation.coordinate, span)
                                self.mapView.setRegion(region, animated: true)
                                
                                
                                
                                self.submitButton.isEnabled = true
                            }
                            
                        }
                        
                        
                        
                        
                    })
                    
                    
                }
            }
            
        }
        
        
    }
    
    
    //Mark: submit a new location to the
    @IBAction func submitLocation(_ sender: Any) {
        
        if self.parameters != nil{
            self.connectionHandler.parsePostMethodTask(parameters: self.parameters!, completionHandler: { (result, error) in
                
                if error != nil{
                    
                    DispatchQueue.main.async {
                        self.showUserErrorMessage(message: "There was an error posting your location to the server")
                    }
                    
                    
                }else{
                    let date = Date();
                    let formatter = DateFormatter()
                    formatter.dateFormat = "dd/mm/yy"
                    let d = formatter.string(from: date)
                    self.parameters?["createdAt"] = d as AnyObject
                    
                    DispatchQueue.main.async{
                        
                        
                        let studentLocation = StudentLocation(parameters: self.parameters!)
                        Constants.User.studentLocations.append(studentLocation)
                        self.dismiss(animated: true, completion: nil)
                        
                    }
                    
                    
                }
                
            })
        }else{
            self.showUserErrorMessage(message: "Something has gone wrong. Please try again")
        }
        
        
        
        
    }
    
    
    //Mark: display an error message to the user
    func showUserErrorMessage(message:String){
        let alert = UIAlertController(title:"Error", message:message, preferredStyle: .alert)
        let okAction = UIAlertAction(title:"OK", style: .default)
        alert.addAction(okAction)
        self.present(alert, animated:true, completion:nil)
    }
}
