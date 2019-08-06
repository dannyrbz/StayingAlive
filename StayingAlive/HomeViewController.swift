//
//  HomeViewController.swift
//  FIT5140-Assign3b
//
//  Created by Danny on 30/10/18.
//  Copyright © 2018 rbzha1. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import MKMagneticProgress

class HomeViewController: UIViewController {
    
    var ref:DatabaseReference?
    var databaseHandle:DatabaseHandle!
    var currentTemp: Double = 0.0
    var currentWaterLevel: Double = 0
    var currentMode: String = ""
    var heatingSwitchStatus: String = ""
    var waterPumpSwitchStatus: String = ""
    var userId: String = ""
    
    @IBOutlet weak var pumpOnLabel: UILabel!
    @IBOutlet weak var tempOnLabel: UILabel!
    @IBOutlet weak var tempGauge: MKMagneticProgress!
    @IBOutlet weak var gaugeTempLabel: UILabel!
    @IBOutlet weak var waterLevelGauge: MKMagneticProgress!
    @IBOutlet weak var gaugeWaterLabel: UILabel!
    @IBOutlet weak var heatingLabel: UILabel!
    @IBOutlet weak var heatingSwitchOutlet: UISwitch!
    @IBOutlet weak var waterPumpLabel: UILabel!
    @IBOutlet weak var waterPumpSwitchOutlet: UISwitch!
    @IBOutlet weak var setTemp: UILabel!
    @IBOutlet weak var setWaterLevel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var waterLabel: UILabel!
    @IBOutlet weak var currentModeLabel: UILabel!
    @IBOutlet weak var deviceView: UIView!
    @IBOutlet weak var settingView: UIView!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var modelDetailLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userId = Auth.auth().currentUser!.uid
        ref = Database.database().reference()
        getCurrentFirebaseData()
        tempOnLabel.isHidden = true
        pumpOnLabel.isHidden = true
        initateSetup()
    }
    
    func initateSetup() {
        deviceView.layer.cornerRadius = 6//self.frame.height/6
        //deviceView.layer.shadowColor = UIColor(hexString: "8580DB") as! CGColor
        deviceView.layer.shadowRadius = 3
        deviceView.layer.shadowOpacity = 0.2
        deviceView.layer.shadowOffset = CGSize(width: 0, height: 0)
        settingView.layer.cornerRadius = 6//self.frame.height/6
        //settingView.layer.shadowColor = UIColor(hexString: "8580DB") as! CGColor
        settingView.layer.shadowRadius = 3
        settingView.layer.shadowOpacity = 0.2
        settingView.layer.shadowOffset = CGSize(width: 0, height: 0)
        statusView.layer.cornerRadius = 6//self.frame.height/6
        //settingView.layer.shadowColor = UIColor(hexString: "8580DB") as! CGColor
        statusView.layer.shadowRadius = 3
        statusView.layer.shadowOpacity = 0.2
        statusView.layer.shadowOffset = CGSize(width: 0, height: 0)
        //currentModeLabel.font = UIFont(name: "System",
        //size: 16.0)
    }
    
    // Action for signing out firebase account
    @IBAction func signOut(_ sender: Any) {
        do{
            try Auth.auth().signOut()
        }catch{
            self.displayErrorMessage("Sign Out Failed")
        }
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }

    // Switch to turn on and off heating device
    // Updates firebase value with on or off
    @IBAction func heatingSwitch(_ sender: UISwitch) {
        if sender.isOn {
            ref?.child("Users").child(userId).child("Setting").child("manualHeat").setValue("on")
            heatingSwitchStatus = "on"
            tempOnLabel.isHidden = false
        }
        else {
            ref?.child("Users").child(userId).child("Setting").child("manualHeat").setValue("off")
            heatingSwitchStatus = "off"
            tempOnLabel.isHidden = true
        }
    }
    
    // Switch to turn on and off water pump device
    // Updates firebase value with on or off
    @IBAction func pumpSwitch(_ sender: UISwitch) {
        if sender.isOn {
            ref?.child("Users").child(userId).child("Setting").child("manualWater").setValue("on")
            waterPumpSwitchStatus = "on"
            pumpOnLabel.isHidden = false
        }
        else {
            ref?.child("Users").child(userId).child("Setting").child("manualWater").setValue("off")
            waterPumpSwitchStatus = "off"
            pumpOnLabel.isHidden = true
        }
    }
    
    // Gets realtime firebase data for current temperature and water level.
    func getCurrentFirebaseData() {
        let ref = Database.database().reference().child("Users").child(userId).child("Data").queryLimited(toLast: 1)
        ref.observe(DataEventType.value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            for(key) in (value?.allKeys)! {
                let object = value?[key] as? NSDictionary
                self.currentTemp = object?["Temp"]! as! Double
                self.currentWaterLevel = object?["waterLevel"]! as! Double
                self.setTempGauge()
                self.setWaterLevelGauge()
            }
        })
        
        let settingRef = Database.database().reference().child("Users").child(userId).queryLimited(toLast: 1)
        settingRef.observe(DataEventType.value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            for(key) in (value?.allKeys)! {
                let object = value?[key] as? NSDictionary
                self.currentMode = object?["mode"]! as! String
                self.currentModeLabel.text = "Mode:  \(self.currentMode)"
                self.heatingSwitchStatus = object?["manualHeat"]! as! String
                self.waterPumpSwitchStatus = object?["manualWater"] as! String
                self.setTemp.text = "\(object?["tempLevel"]! as! String)°C"
                self.setWaterLevel.text = "\(object?["waterLevel"]! as! String)%"
                self.currentModeLabel.text = "Mode:"
                self.modelDetailLbl.text = "\(self.currentMode)"
                print("Mode: \(self.currentMode)")
                self.checkInitialState()
            }
        })
    }
    
    // Customizes and sets the value for the temperature gauge.
    // Uses malkouz/MKMagnetic progress from: https://github.com/malkouz/MKMagneticProgress
    func setTempGauge() {
        let progressTemp = currentTemp / 60
        tempGauge.setProgress(progress: CGFloat(progressTemp), animated: true)
        tempGauge.progressShapeColor = UIColor.red
        tempGauge.backgroundShapeColor = UIColor.lightGray
        tempGauge.titleColor = UIColor.black
        tempGauge.percentColor = UIColor.black
        
        tempGauge.lineWidth = 8
        tempGauge.lineCap = .round
        tempGauge.percentLabelFormat = ""
        
        gaugeTempLabel.text = "\(currentTemp)°C"
        
    }
    
    // Customizes and sets the value for the water level gauge.
    // Uses malkouz/MKMagnetic progress from: https://github.com/malkouz/MKMagneticProgress
    func setWaterLevelGauge() {
        let progressWaterLevel = currentWaterLevel / 100
        waterLevelGauge.setProgress(progress: CGFloat(progressWaterLevel), animated: true)
        waterLevelGauge.progressShapeColor = UIColor.blue
        waterLevelGauge.backgroundShapeColor = UIColor.lightGray
        waterLevelGauge.titleColor = UIColor.black
        waterLevelGauge.percentColor = UIColor.black
        
        waterLevelGauge.lineWidth = 8
        waterLevelGauge.lineCap = .round
        waterLevelGauge.percentLabelFormat = ""
        
        gaugeWaterLabel.text = "\(currentWaterLevel)%"
    }

    // Checks settings from firebase to set current settings.
    func checkInitialState() {
        if heatingSwitchStatus == "on" {
            heatingSwitchOutlet.setOn(true, animated: true)
        } else {
            heatingSwitchOutlet.setOn(false, animated: false)
        }
        
        if waterPumpSwitchStatus == "on" {
            waterPumpSwitchOutlet.setOn(true, animated: true)
        } else {
            waterPumpSwitchOutlet.setOn(false, animated: false)
        }
        
        if (currentMode == "Manual") {
            heatingSwitchOutlet.isEnabled = true
            heatingLabel.isEnabled = true
            
            waterPumpSwitchOutlet.isEnabled = true
            waterPumpLabel.isEnabled = true
        } else {
            heatingSwitchOutlet.isEnabled = false
            heatingLabel.isEnabled = false
            
            waterPumpSwitchOutlet.isEnabled = false
            waterPumpLabel.isEnabled = false
        }
    }
    
    func displayErrorMessage(_ erroMessage:String){
        let alertController = UIAlertController(title: "Error", message: erroMessage, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
}


