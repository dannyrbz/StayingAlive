//
//  SettingViewController.swift
//  FIT5140-Assign3b
//
//  Created by Danny on 30/10/18.
//  Copyright © 2018 rbzha1. All rights reserved.
//

import UIKit
import CocoaMQTT
import FirebaseDatabase
import Firebase
import FirebaseAuth

class SettingViewController: UIViewController {
    
    @IBOutlet weak var waterSlider: UISlider!
    @IBOutlet weak var setWaterLevel: UILabel!
    @IBOutlet weak var editButtonOutlet: UIButton!
    @IBOutlet weak var modeSelectorOutlet: UISegmentedControl!
    @IBOutlet weak var tempSlider: UISlider!
    @IBOutlet weak var setTemp: UILabel!
    @IBOutlet weak var cancelButtonOutlet: UIButton!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var waterLabel: UILabel!
    @IBOutlet weak var modeLabel: UILabel!
    @IBOutlet weak var tankHeightLabel: UILabel!
    @IBOutlet weak var tankHeightSlider: UISlider!
    @IBOutlet weak var setTankHeight: UILabel!
    @IBOutlet weak var settingView: UIView!
    
    var ref:DatabaseReference?
    var currentSetTempLevel: String = ""
    var currentSetWaterLevel: String = ""
    var newSetTempLevel: String = ""
    var newSetWaterLevel: String = ""
    var modeSelectorStatus: String = ""
    var currentMode: String = ""
    var currentTankHeight: String = ""
    var newSetTankHeight: String = ""
    var userId: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingView.layer.cornerRadius = 6//self.frame.height/6
        //settingView.layer.shadowColor = UIColor(hexString: "8580DB") as! CGColor
        settingView.layer.shadowRadius = 3
        settingView.layer.shadowOpacity = 0.2
        settingView.layer.shadowOffset = CGSize(width: 0, height: 0)
        ref = Database.database().reference()
        userId = Auth.auth().currentUser!.uid

        modeSelectorOutlet.isHidden = true
        cancelButtonOutlet.isHidden = true
        
        getCurrentFirebaseData()
        
    }
    
    // Get data from firebase database
    func getCurrentFirebaseData() {
        let settingRef = Database.database().reference().child("Users").child(userId).queryLimited(toLast: 1)
        settingRef.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            for(key) in (value?.allKeys)! {
                let object = value?[key] as? NSDictionary
                self.currentMode = object?["mode"]! as! String
                self.currentTankHeight = object?["tankHeight"]! as! String
                self.currentSetTempLevel = object?["tempLevel"]! as! String
                self.currentSetWaterLevel = object?["waterLevel"]! as! String

                self.setInitialState()
            }
        })
    }

    // Sets data to labels and sliders
    func setInitialState() {
        if (currentSetWaterLevel != "") {
            self.modeLabel.text = "Mode: \(self.currentMode)"
            self.setTemp.text = "\(self.currentSetTempLevel)°C"
            self.setWaterLevel.text = "\(self.currentSetWaterLevel)%"
            self.newSetTempLevel = self.currentSetTempLevel
            self.newSetWaterLevel = self.currentSetWaterLevel
            self.tankHeightSlider.setValue(Float(self.currentTankHeight)!, animated: true)
            self.tempSlider.setValue(Float(self.currentSetTempLevel)!, animated: true)
            self.waterSlider.setValue(Float(self.currentSetWaterLevel)!, animated: true)
            self.setTankHeight.text = "\(self.currentTankHeight) cm"
            self.newSetTankHeight = self.currentTankHeight
        } else {
            // Create a pop up error
            self.displayErrorMessage("Initiate Setting Failed")
        }
    }
    
    // On click, allows users to edit settings
    // Changes between edit and save button. Shows cancel button if save button is active
    @IBAction func editButtonAction(_ sender: UIButton) {
        if editButtonOutlet.titleLabel?.text == "Edit" {
            modeLabel.text = "Mode: "
            editButtonOutlet.setTitle("Save", for: .normal)
            cancelButtonOutlet.isHidden = false
            modeSelectorOutlet.isHidden = false
            tankHeightLabel.isEnabled = true
            setTankHeight.isEnabled = true
            tankHeightSlider.isEnabled = true
            
            if (currentMode == "Auto") {
                modeSelectorOutlet.selectedSegmentIndex = 0
            } else {
                modeSelectorOutlet.selectedSegmentIndex = 1
            }
            
            if (modeSelectorOutlet.selectedSegmentIndex == 0) {
                tempLabel.isEnabled = true
                tempSlider.isEnabled = true
                setTemp.isEnabled = true
                
                waterLabel.isEnabled = true
                waterSlider.isEnabled = true
                setWaterLevel.isEnabled = true
                
                modeSelectorStatus = "Auto"
            } else {
                tempLabel.isEnabled = false
                tempSlider.isEnabled = false
                setTemp.isEnabled = false
                
                waterLabel.isEnabled = false
                waterSlider.isEnabled = false
                setWaterLevel.isEnabled = false
                
                modeSelectorStatus = "Manual"
            }
            
            saveData()

        } else {
            editButtonOutlet.setTitle("Edit", for: .normal)
            cancelButtonOutlet.isHidden = true
            modeSelectorOutlet.isHidden = true
            
            tempLabel.isEnabled = false
            tempSlider.isEnabled = false
            setTemp.isEnabled = false
            
            waterLabel.isEnabled = false
            waterSlider.isEnabled = false
            setWaterLevel.isEnabled = false
            
            tankHeightSlider.isEnabled = false
            tankHeightLabel.isEnabled = false
            setTankHeight.isEnabled = false
            
            saveData()
            getCurrentFirebaseData()
        }
    }
    
    // Slider for setting temperature
    // Updates values to firebase for set temperature level
    @IBAction func tempSlider(_ sender: UISlider) {
        setTemp.text = String(Int(sender.value))+"°C"
        newSetTempLevel = String(Int(sender.value))
    }
    
    // Slider for setting water level
    // Updates value to firebase for set water level
    @IBAction func waterSlider(_ sender: UISlider) {
        setWaterLevel.text = String(Int(sender.value))+"%"
        newSetWaterLevel = String(Int(sender.value))
    }
    
    // Saves setting from editing to firebase database
    func saveData() {
        ref?.child("Users").child(userId).child("Setting").child("mode").setValue("\(modeSelectorStatus)")
        ref?.child("Users").child(userId).child("Setting").child("tempLevel").setValue("\(newSetTempLevel)")
        ref?.child("Users").child(userId).child("Setting").child("waterLevel").setValue("\(newSetWaterLevel)")
        ref?.child("Users").child(userId).child("Setting").child("tankHeight").setValue("\(newSetTankHeight)")
    }
    
    // Selector for manual or auto mode during editing
    @IBAction func modeSelector(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            modeSelectorOutlet.isHidden = false
            
            tempLabel.isEnabled = true
            tempSlider.isEnabled = true
            setTemp.isEnabled = true
            
            waterLabel.isEnabled = true
            waterSlider.isEnabled = true
            setWaterLevel.isEnabled = true
            
            modeSelectorStatus = "Auto"
        } else {
            modeSelectorOutlet.isHidden = false
            
            tempLabel.isEnabled = false
            tempSlider.isEnabled = false
            setTemp.isEnabled = false
            
            waterLabel.isEnabled = false
            waterSlider.isEnabled = false
            setWaterLevel.isEnabled = false
            
            modeSelectorStatus = "Manual"
        }
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        editButtonOutlet.setTitle("Edit", for: .normal)
        cancelButtonOutlet.isHidden = true
        modeSelectorOutlet.isHidden = true
        
        tempLabel.isEnabled = false
        tempSlider.isEnabled = false
        setTemp.isEnabled = false
        
        waterLabel.isEnabled = false
        waterSlider.isEnabled = false
        setWaterLevel.isEnabled = false
        
        tankHeightSlider.isEnabled = false
        tankHeightLabel.isEnabled = false
        setTankHeight.isEnabled = false
        
        getCurrentFirebaseData()
    }
    
    
    @IBAction func tankHeightSliderAction(_ sender: UISlider) {
        setTankHeight.text = String(Int(sender.value))+" cm"
        newSetTankHeight = String(Int(sender.value))
    }
    
    func displayErrorMessage(_ erroMessage:String){
        let alertController = UIAlertController(title: "Error", message: erroMessage, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}

