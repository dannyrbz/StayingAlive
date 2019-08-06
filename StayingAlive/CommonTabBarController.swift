//
//  CommonTabBarController.swift
//  FIT5140-Assign3b
//
//  Created by 王明棽 on 2018/11/6.
//  Copyright © 2018年 rbzha1. All rights reserved.
//

import UIKit
import Firebase
class CommonTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // Action for signing out firebase account
    @IBAction func signOut(_ sender: Any) {
        do{
            try Auth.auth().signOut()
        }catch{
            print(error)
        }
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }

}


