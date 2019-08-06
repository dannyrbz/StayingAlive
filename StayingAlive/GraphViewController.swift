//
//  GraphViewController.swift
//  FIT5140-Assign3b
//
//  Created by 王明棽 on 2018/11/3.
//  Copyright © 2018年 rbzha1. All rights reserved.
//


import UIKit
import ChartProgressBar
import Firebase
class GraphViewController: UIViewController {
    
    @IBOutlet weak var duration: UISegmentedControl!
    @IBOutlet weak var chart: ChartProgressBar!
    @IBOutlet weak var graphSegment: UISegmentedControl!
    
    @IBOutlet weak var graphTitle: UILabel!
    @IBOutlet weak var highValLabel: UILabel!
    @IBOutlet weak var avgValLabel: UILabel!
    @IBOutlet weak var lowValLabel: UILabel!
    @IBOutlet weak var evaluationView: UIView!
    @IBOutlet weak var maxImage: UIImageView!
    @IBOutlet weak var avgImage: UIImageView!
    @IBOutlet weak var minImage: UIImageView!
    
    var numOfNodes = 0
    var lowestTemp:Float =  100.0 // highest or impossible value of temeparture
    var lowestWaterLevel:Float = 100.0 // highest or impossible value of temeparture
    var highestWaterLevel:Float = 0.0
    var userId: String = ""
    
    var data:[BarData] = []
    var dataList:[HistoryData] = []
    //var waterList:[HistoryData] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        duration.selectedSegmentIndex = 0
        graphSegment.selectedSegmentIndex = 0
        self.duration.layer.cornerRadius = 10.0
        self.graphSegment.layer.cornerRadius = 10.0
        userId = Auth.auth().currentUser!.uid
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
         loadHistoryData("Hourly")
    }
    /*
     the function to read data from firebase and sort into datalist
 */
    func loadHistoryData(_ duration:String){
        if dataList.isEmpty == false{
            dataList.removeAll()
        }
        //let dateFormate = DateFormatter()
        //dateFormate.dateFormat = "yyyyMMdd"
        //let today = dateFormate.string(from: Date())
        self.graphTitle.text = "History-\(duration)"
        let ref = Database.database().reference().child("Users").child(userId).child("Data").child("Historic Data").child(duration)
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if(snapshot.childrenCount > 0)
            {
                let value = snapshot.value as? NSDictionary
                let tempObject = value?["Temp"] as? NSArray
                let waterObject = value?["Water"] as? NSArray
                for key in 0..<(tempObject?.count)!{
                    let newKey = Int(key) + 1
                    let temp = (tempObject?[key] as? NSNumber)?.floatValue ?? 0.0
                    let waterLevel = (waterObject?[key] as? NSNumber)?.floatValue ?? 0.0
                    if temp != 0.0 && waterLevel != 0.0{
                        self.dataList.append(HistoryData(desc: "\(newKey)", temp: temp, waterLevel: waterLevel))
                    }
                }
                DispatchQueue.main.async {
                    if self.dataList.isEmpty == false{
                        self.drawGraph()
                    }else{
                        self.displayErrorMessage("The data is empty")
                    }
                }
            };
        }
    }
    
    // the functionto append data into Bardata from datalist base on the segement selected by user
    func initData(){
        if graphSegment.selectedSegmentIndex == 0{
            data.removeAll()
            self.dataList = self.dataList.sorted{ Float($0.desc!)! < Float($1.desc!)!}
            for hourData in dataList{
                
                data.append(BarData.init(barTitle: String("\(hourData.desc!)"), barValue: hourData.temp!, pinText: "\(hourData.temp!)C"))
            }
            
            self.maxImage.image = UIImage(named: "MaxTemp")
            self.avgImage.image = UIImage(named: "avgTemp")
            self.minImage.image = UIImage(named: "MinTemp")
        }
        else {
            data.removeAll()
            for hourData in dataList{
                
                data.append(BarData.init(barTitle: String(String("\(hourData.desc!)").suffix(2)), barValue: hourData.waterLevel!, pinText: "\(hourData.waterLevel!)%"))
            }
            self.maxImage.image = UIImage(named: "maxWater")
            self.avgImage.image = UIImage(named: "avgWater")
            self.minImage.image = UIImage(named: "minWater")
        }
        setMinMaxLabels()
    }
    
    // the funcion to draw the graph
    // studing from https://github.com/hadiidbouk/ChartProgressBar-iOS
    func drawGraph(){
        initData()
        if chart.isBarsEmpty() == false{
            chart.removeValues()
            //chart.removeFromSuperview()
            for view in chart.subviews{
                view.removeFromSuperview()
            }
        }
        if graphSegment.selectedSegmentIndex == 0{
            chart.progressColor = UIColor.red
        }else{
            chart.progressColor = UIColor.blue//init(hexString: "0000FF") //#0000e5//99ffffff
        }
        chart.data = data
        chart.barsCanBeClick = true
        //chart.maxValue = 100.0
        chart.emptyColor = UIColor.clear
        chart.barWidth = 4
        chart.progressClickColor = UIColor.init(hexString: "F2912C")
        chart.pinBackgroundColor = UIColor.init(hexString: "E2335E")
        chart.pinTxtColor = UIColor.init(hexString: "ffffff")
        chart.barTitleColor = UIColor.init(hexString: "111e6c")
        chart.barTitleSelectedColor = UIColor.init(hexString: "F2912C")//UIColor.init(hexString: "FFFFFF")
        chart.pinMarginBottom = 15
        chart.barTitleWidth = 14
        chart.pinWidth = 70
        chart.pinHeight = 29
        chart.pinTxtSize = 17
        chart.delegate = self
        chart.build()
        
        
    }
    
    @IBAction func graphSelector(_ sender: UISegmentedControl) {
        drawGraph()
    }
    
    
    @IBAction func changeDuration(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0{
            loadHistoryData("Hourly")
            
            
        }
        else if sender.selectedSegmentIndex == 1 {
            loadHistoryData("Daily")
        }
        else if sender.selectedSegmentIndex == 2{
            loadHistoryData("Weekly")
            
        }else{
             loadHistoryData("Hourly")
        }
    }

    /*To set the labels*/
    func setMinMaxLabels()
    {
        if(graphSegment.selectedSegmentIndex == 0)
        {
            let sortedList = self.dataList.sorted{ Float($0.temp!) > Float($1.temp!)}
            chart.maxValue = (sortedList.first?.temp!)! + (sortedList.first?.temp!)! * 0.1
            var totalTemp:Float = 0.0
            for data in sortedList{
                totalTemp += data.temp!
            }
            let avgTemp = Float(totalTemp) / Float(sortedList.count)
            //String(format: "%.2f", (sortedList.first?.temp!)!)
            self.highValLabel.text = String("Highest Temprature    \((sortedList.first?.temp!)!)˚C")
            self.lowValLabel.text = String("Lowest Temprature    \((sortedList.last?.temp!)!)˚C")
            self.avgValLabel.text = String(format: "Average Temprature    %.2f˚C", avgTemp)
        }
        else{
            let sortedList = self.dataList.sorted{ Float($0.waterLevel!) > Float($1.waterLevel!)}
            chart.maxValue = (sortedList.first?.waterLevel!)! + (sortedList.first?.waterLevel!)! * 0.1
            var totalWater:Float = 0.0
            for data in sortedList{
                totalWater += data.waterLevel!
            }
            let avgWaterLevel = Float(totalWater) / Float(sortedList.count)
            self.highValLabel.text = String("Highest Water Level    \(String(describing: (sortedList.first?.waterLevel!)!))%")
            self.lowValLabel.text = String("Lowest Water Level    \(String(describing: (sortedList.last?.waterLevel!)!))%")
            //String(format: "Average Temprature˚C", avgTemp)
            self.avgValLabel.text = String(format:"Average Water Level     %.2f",avgWaterLevel)+"%"
        }
    }
    
    func displayErrorMessage(_ erroMessage:String){
        let alertController = UIAlertController(title: "Error", message: erroMessage, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
 
    
}
extension GraphViewController: ChartProgressBarDelegate {
    func ChartProgressBar(_ chartProgressBar: ChartProgressBar, didSelectRowAt rowIndex: Int) {
        print(rowIndex)
    }
}

