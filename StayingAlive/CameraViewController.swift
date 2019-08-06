//
//  CameraViewController.swift
//  FIT5140-Assign3b
//
//  Created by Danny on 4/11/18.
//  Copyright © 2018 rbzha1. All rights reserved.
//

import UIKit
import FirebaseStorage
import Firebase
import FirebaseAuth
import FirebaseDatabase

class CameraViewController: UIViewController {

    @IBOutlet weak var takePhoto: UIImageView!
    @IBOutlet weak var takeBTN: UIButton!
    
    var ref:DatabaseReference?
    var storageImageUrl: String = ""
    var storageRef = Storage.storage().reference()
    var image:UIImage? = nil
    var userId: String = ""
    var cameraStatus: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        takePhoto.layer.cornerRadius = 6
        takePhoto.layer.shadowRadius = 6
        takePhoto.layer.shadowOpacity = 0.5
        takePhoto.layer.shadowOffset = CGSize(width: 0, height: 0)
        loadingIndicator.isHidden = true
        userId = Auth.auth().currentUser!.uid
        ref = Database.database().reference()
        //getCurrentFirebaseData()
    }
    
    func getCurrentFirebaseData() {
        let ref = Database.database().reference().child("Users").child(userId).queryLimited(toLast: 1)
        ref.observeSingleEvent(of:DataEventType.value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            for(key) in (value?.allKeys)! {
                let object = value?[key] as? NSDictionary
                self.cameraStatus = object?["cameraStatus"]! as! String
                self.test()
            }
        })
    }
    
    func downloadPhoto(){
        while (cameraStatus != "done") {

        }
        DispatchQueue.main.async {
            let starsRef = self.storageRef.child("piPic.jpg")
            
            let downloadTask = starsRef.getData(maxSize: 1 * 5120 * 5120){
                data,error in
                if(error != nil){
                    self.displayErrorMessage("Error: the take photo button is not working.")
                }else{
                    self.image = UIImage(data: data!)!
                }
            }
            downloadTask.observe(.progress){ snapshot in
            }
            downloadTask.observe(.success){ snapshot in
                DispatchQueue.main.async {
                    self.takePhoto.image = self.image
                }
                self.takeBTN.isEnabled = true
                self.loadingIndicator.isHidden = true
                self.loadingIndicator.stopAnimating()
                self.ref?.child("Users").child(self.userId).child("Setting").child("cameraStatus").setValue("off")
            }
        }
    }
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    @IBAction func getPhot(_ sender: Any) {
        ref?.child("Users").child(userId).child("Setting").child("cameraStatus").setValue("on")
        self.takeBTN.isEnabled = false
        self.loadingIndicator.isHidden = false
        self.loadingIndicator.startAnimating()
        getCurrentFirebaseData()
        test()
    }
    
    func test(){
        if(cameraStatus != "done"){
            getCurrentFirebaseData()
        }else {
            self.takePhoto.image = nil
            self.downloadPhoto()
        }
    }
    func displayErrorMessage(_ erroMessage:String){
        let alertController = UIAlertController(title: "Error", message: erroMessage, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}


