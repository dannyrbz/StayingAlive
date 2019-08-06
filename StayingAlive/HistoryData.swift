//
//  HistoryData.swift
//  FIT5140-Assign3b
//
//  Created by 王明棽 on 2018/11/6.
//  Copyright © 2018年 rbzha1. All rights reserved.
//

import UIKit

class HistoryData: NSObject {
    var desc:String?
    var temp:Float?
    var waterLevel:Float?
    init(desc:String,temp:Float,waterLevel:Float) {
        self.desc = desc
        self.temp = temp
        self.waterLevel = waterLevel
    }
    
}
