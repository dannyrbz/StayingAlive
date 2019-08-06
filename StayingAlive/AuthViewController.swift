//
//  AuthViewController.swift
//  FIT5140-Assign3b
//
//  Created by Danny on 30/10/18.
//  Copyright © 2018 rbzha1. All rights reserved.
//

import UIKit
import Firebase

class AuthViewController: UIViewController {

    @IBOutlet weak var emailAddrTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var handle: AuthStateDidChangeListenerHandle?
    var userCheck: String?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = Auth.auth().addStateDidChangeListener({(auth, user) in
            if user != nil {
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    // Uses input from email and password field to login in
    // Validates and returns error message if authetication is not valid
    @IBAction func loginMethod(_ sender: Any) {
        guard let password = passwordTextField.text else {
            displayErrorMessage("Please enter a password")
            return
        }
        
        guard let email = emailAddrTextField.text else {
            displayErrorMessage("Please enter an email addresss")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password){ (user, error) in
            self.userCheck = user as? String
            if error != nil{
                self.displayErrorMessage(error!.localizedDescription)
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            } else {
                self.shouldPerformSegue(withIdentifier: "loginSegue", sender: nil)
                self.emailAddrTextField.text = ""
                self.passwordTextField.text = ""
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        if identifier == "loginSegue" {
            if userCheck == nil {
                return false
            }
        }
        return true
    }
    
    // Creates a new account for the user using email and password input field
    // Validates to check if account with email already exists in firebase
    @IBAction func registerMethod(_ sender: Any) {
        guard let password = passwordTextField.text else {
            displayErrorMessage("Please enter the password!")
            return
        }
        guard let email = emailAddrTextField.text else{
            displayErrorMessage("Please enter an email address!")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password){
            (user, error) in
            if error != nil{
                self.displayErrorMessage(error!.localizedDescription)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayErrorMessage(_ erroMessage:String){
        let alertController = UIAlertController(title: "Error", message: erroMessage, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }

}
