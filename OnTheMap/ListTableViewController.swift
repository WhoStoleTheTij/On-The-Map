//
//  ListTableViewController.swift
//  OnTheMap
//
//  Created by Richard H on 08/07/2017.
//  Copyright © 2017 Richard H. All rights reserved.
//

import UIKit

class ListTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    var locations: Array<StudentLocation> = []
    
    var connectionHandler = ConnectionHandler()
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        locations = Constants.User.studentLocations
        
        locations.sort { $0.createdAt?.compare(($1.createdAt)!) == .orderedAscending }
        
        
        
        
    }
    
    //reload the data
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return locations.count
    }

    //Mark: set the cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        let location = locations[indexPath.row]
        
        cell.imageView?.image = UIImage(named: "icon_pin")
        cell.textLabel?.text = "\(location.firstname ?? "") \(location.lastname ?? "")"
     
        
        return cell
    }
    
    //Mark: open the location url in browser
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let location = locations[indexPath.row]
        if location.mapString != nil{
            var urlString = location.mapString
            urlString = urlString?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
            
            if !((urlString?.contains("https"))!){
                urlString = "https://" + urlString!
            }
            UIApplication.shared.open(URL(string: urlString!)!, options: [:], completionHandler: nil)
            
            
        }
        
    }
    
    //Mark: log the user out
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
    
    //Mark: display an error message to the user
    func showUserErrorMessage(message:String){
        let alert = UIAlertController(title:"Error", message:message, preferredStyle: .alert)
        let okAction = UIAlertAction(title:"OK", style: .default)
        alert.addAction(okAction)
        self.present(alert, animated:true, completion:nil)
    }
    
    //Mark: reload the data from the server
    @IBAction func refreshData(_ sender: Any) {
        
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
                    
                    self.tableView.reloadData()
                }
            }
            
        }
        
    }

}
