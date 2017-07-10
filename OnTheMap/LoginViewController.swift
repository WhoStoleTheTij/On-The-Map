//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Richard H on 06/07/2017.
//  Copyright © 2017 Richard H. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    
    
    
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var loginButtton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    var activeTextfield: UITextField? = nil
    
    var connectionHandler = ConnectionHandler()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        self.subscribeToKeyboardNotification()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        self.unsubscribeToKeyboardNotification()
    }
    
    //Mark: action to log the user into the Udacity API
    @IBAction func login(_ sender: Any) {
        
        
        
        self.setupUIForNetworking(enabled: false)
        let email = self.emailTextfield.text
        let password = self.passwordTextfield.text
        
        if((email?.isEmpty)! && (password?.isEmpty)!){
            self.showUserErrorMessage(message: "Enter a valid email and password")
            self.setupUIForNetworking(enabled: true)
        } else if (email?.isEmpty)!{
            self.showUserErrorMessage(message: "Enter a valid email")
            self.setupUIForNetworking(enabled: true)
        } else if (password?.isEmpty)!{
            self.showUserErrorMessage(message: "Enter a valid password")
            self.setupUIForNetworking(enabled: true)
        }else{
            
            let parameters = ["username": email, "password": password]
            
            connectionHandler.getUdacityLoginSession(parameters: parameters as [String : AnyObject]) { (sessionId, error) in
                
                if error != nil{
                    DispatchQueue.main.async {
                        self.showUserErrorMessage(message: error!)
                        self.setupUIForNetworking(enabled: true)
                    }
                    
                }else{
                    DispatchQueue.main.async {
                        //move to next screen
                        self.setupUIForNetworking(enabled: true)
                        let mapViewController: UITabBarController
                        mapViewController = self.storyboard?.instantiateViewController(withIdentifier: "TabController") as! UITabBarController
                        self.present(mapViewController, animated: true, completion:nil)
                        self.performSegue(withIdentifier: "loginSegue", sender: sender)
                    }
                    
                    
                }
                
            }
            
        }
        
        
        
    }

    //Mark: if the login segue is called then allow
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "loginSegue"{
            return true 
        }
        return false
    }

    //Mark: open a new safari view and set the url to udacity website
    @IBAction func signUpButtonClick(_ sender: Any) {
        
        UIApplication.shared.open(URL(string: Constants.Login.udacity)!, options: [:], completionHandler: nil)
        
    }
    
    //Mark: enable and disable the UI elements
    func setupUIForNetworking(enabled: Bool){
        self.emailTextfield.isEnabled = enabled
        self.passwordTextfield.isEnabled = enabled
        self.loginButtton.isEnabled = enabled
        self.signupButton.isEnabled = enabled
    }
    
    //Mark: display an error message to the user
    func showUserErrorMessage(message:String){
        let alert = UIAlertController(title:"Error", message:message, preferredStyle: .alert)
        let okAction = UIAlertAction(title:"OK", style: .default)
        alert.addAction(okAction)
        self.present(alert, animated:true, completion:nil)
    }
    
    
    //Mark: get the adjustment value for the frame move depending on the selected textfield and the orientation of the screen
    func getAdjustmentHeight(notification: NSNotification) -> CGFloat{
        let returnValue: CGFloat!
        
        if(self.activeTextfield != nil){
            
            let mainFrameHeight = self.view.frame.height
            
            var margin: Double = 0;
            
            /*
             set the margin value based on the device orientation and the selected textfield tag 1 = email, tag 2 = password
             landscape needs to adjust the screen more that portrait.
             */
            if UIDevice.current.orientation == UIDeviceOrientation.portrait{
                margin = Double(0.5)
            }else{
                if(self.activeTextfield?.tag == 1){
                    margin = Double(0.5)
                }else{
                    margin = Double(0.8)
                }
            }
            
            
            
            let userInfo = notification.userInfo
            let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
            let keyboardHeight = keyboardSize.cgRectValue.height
            returnValue = (mainFrameHeight - keyboardHeight) * CGFloat(margin)
        }else{
            returnValue = CGFloat(0)
        }
        
        return returnValue
    }
    
    //Mark: set activeTextfield to email textfield
    @IBAction func didBeginEditingEmail(_ sender: UITextField) {
        sender.becomeFirstResponder()
        
        self.activeTextfield = sender
    }
    
    //Mark: set activeTextfield to nil when no longer editing email
    @IBAction func didEndEditingEmail(_ sender: UITextField) {
        
        sender.resignFirstResponder()
        
        self.activeTextfield = nil
        
    }
    
    //Mark: set activeTextfield to password textfield
    @IBAction func didBeginEditingPassword(_ sender: UITextField) {
        
        sender.becomeFirstResponder()
        
        self.activeTextfield = sender
        
    }
    
    //Mark: set activeTextfield to nil when no longer editing passwword
    @IBAction func didEndEditingPassword(_ sender: UITextField) {
        
        sender.resignFirstResponder()
        
        self.activeTextfield = nil
    }
    
    //Mark: subscribe from keyboard notifications
    func subscribeToKeyboardNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    //Mark: unsubscribe from keyboard notifications
    func unsubscribeToKeyboardNotification(){
        NotificationCenter.default.removeObserver(self, name:Notification.Name.UIKeyboardWillShow, object:nil)
        NotificationCenter.default.removeObserver(self, name:Notification.Name.UIKeyboardWillHide, object:nil)
    }
    
    //Mark: move the frame to show the textfield when keyboard shown
    func keyboardWillShow(notification: NSNotification){
        self.view.frame.origin.y = -self.getAdjustmentHeight(notification: notification)
    }
    
    //Mark: move the frame back to its original position on keyboard hide
    func keyboardWillHide(notification: NSNotification){
        self.view.frame.origin.y = 0
    }
    
    //Mark: hide the keyboard when the return key is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        
        if self.activeTextfield != nil{
            self.activeTextfield = nil
        }
        
        return false
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
