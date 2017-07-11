//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Richard H on 08/07/2017.
//  Copyright © 2017 Richard H. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet var mapView: MKMapView!
    
    var connectionHandler = ConnectionHandler()
    
    var annotations = [MKPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.mapView.delegate = self
        
        self.loadData()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.mapView.reloadInputViews()
    }

    
    //Mark: display an error message to the user
    func showUserErrorMessage(message:String){
        let alert = UIAlertController(title:"Error", message:message, preferredStyle: .alert)
        let okAction = UIAlertAction(title:"OK", style: .default)
        alert.addAction(okAction)
        self.present(alert, animated:true, completion:nil)
    }
    
    //Mark: Open the link if in a browser if there is one
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView{
            let app = UIApplication.shared
            if var toOpen = view.annotation?.subtitle!
            {
                //Some URLs did not contain http
                if !toOpen.contains("https://"){
                    toOpen = "https://" + toOpen
                }
                
                
                app.open(URL(string: toOpen)!, options: [:], completionHandler: nil)
            }
        }
    }
    
    //Mark: setup the pins for the map
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)  as? MKPinAnnotationView
        
        if pinView == nil{
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            pinView!.pinTintColor = .purple
            
        }else{
            pinView!.annotation = annotation
        }
        
        return pinView
        
    }
    //Mark: log out of the app
    @IBAction func logoutAction(_ sender: Any) {
        
        connectionHandler.logoutWithUdaticySession(sessionId: Constants.User.sessionId) { (success, error) in
            
            if !success{
                self.showUserErrorMessage(message: error!)
            }else{
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
                
            }
            
        }
        
        
    }
    
    //Mark: reload the data
    @IBAction func refreshData(_ sender: Any) {
        self.loadData()
        self.reloadInputViews()
    }
    
    //Mark: load the date from the server
    func loadData(){
        
        if Constants.User.studentLocations.count > 0{
            Constants.User.studentLocations.removeAll()
        }
        
        let parameters = ["limit":"100"] as [String:AnyObject]
        connectionHandler.parseGetMethodTask(parameters: parameters) { (results, error) in
            
            if error != nil{
                DispatchQueue.main.async {
                    self.showUserErrorMessage(message: error!)
                }
            }else{
                
                DispatchQueue.main.async {
                    let locations = Constants.User.studentLocations
                    
                    for location in locations{
                        
                        if location.latitude != nil && location.longitude != nil{
                            let lat = CLLocationDegrees(location.latitude!)
                            let long = CLLocationDegrees(location.longitude!)
                            
                            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude:long)
                            
                            let annotation = MKPointAnnotation()
                            annotation.coordinate = coordinate
                            annotation.title = "\(location.firstname ?? "") \(location.lastname ?? "")"
                            annotation.subtitle = location.mediaUrl
                            
                            self.annotations.append(annotation)
                        }
                        
                        
                        
                    }
                    self.mapView.addAnnotations(self.annotations)
                }
            }
            
        }
    }
}
