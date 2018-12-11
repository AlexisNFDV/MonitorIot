//
//  ViewController.swift
//  LineChartTest
//
//  Created by Developer on 20/11/2018.
//  Copyright © 2018 Developer. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Charts

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        APIRequest()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Variables du graphiques
    //@IBOutlet weak var menuTemp: UISegmentedControl!
    @IBOutlet weak var chart: LineChartView!
    var dataSet: LineChartDataSet!
    var entries: [ChartDataEntry] = Array()
    
    //variables des données
    var recupere = JSON()
    var donnée = [Double]()
    var heure1 = [Double]()
    var heure = [Double]()
    
    func setUp(dataPoints: [Double], values:[Double])
    {
        entries = []
        
        for i in 0..<dataPoints.count
        {
            let dataPoint = ChartDataEntry(x: values[i], y:dataPoints[i])
            entries.append(dataPoint)
        }
        
        //Limite
         let ll1 = ChartLimitLine(limit: 35, label: "Limite max")
         ll1.lineWidth = 4
         ll1.lineDashLengths = [5, 5]
         ll1.labelPosition = .rightTop
         ll1.valueFont = .systemFont(ofSize: 10)
         
         let ll2 = ChartLimitLine(limit: 15, label: "Limite Min")
         ll2.lineWidth = 4
         ll2.lineDashLengths = [5,5]
         ll2.labelPosition = .rightBottom
         ll2.valueFont = .systemFont(ofSize: 10)
         
         let leftAxis = chart.leftAxis
         leftAxis.removeAllLimitLines()
         leftAxis.addLimitLine(ll1)
         leftAxis.addLimitLine(ll2)
         leftAxis.axisMaximum = 50
         leftAxis.axisMinimum = 0
         leftAxis.gridLineDashLengths = [5, 5]
         leftAxis.drawLimitLinesBehindDataEnabled = true
        
        //Insertion des données
        dataSet = LineChartDataSet(values: entries, label: "Température")
        chart.data = LineChartData(dataSet: dataSet)
        
        //Style
        chart.rightAxis.enabled = false
        chart.xAxis.labelPosition = .bottom
        chart.doubleTapToZoomEnabled = false
        chart.scaleYEnabled = false
        chart.scaleXEnabled = false
        chart.pinchZoomEnabled = false
        
        dataSet.mode = .cubicBezier
        dataSet.drawCirclesEnabled = false
        dataSet.drawValuesEnabled = false
        dataSet.lineWidth = 5
        
        chart.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        chart.chartDescription?.text = "Temps(Minutes)"
    }
    
    func APIRequest(){
        
        Alamofire
            .request("http://10.92.1.27:3000/thing/list")
            .responseJSON
            { response in
                print("Request: \(String(describing: response.request))")
                print("Response: \(String(describing: response.response))")
                print("Result: \(response.result)")
                
                if let json = response.result.value {
                    self.recupere = JSON(json)
                }
                
                for (key,subJson):(String, JSON) in self.recupere{
                    
                    let valeur:Double = (Double(subJson["value"].stringValue)!)
                    let date:String
                    
                    if(key == "0")
                    {
                        date = "0"
                        self.donnée.insert(valeur, at:Int(key)!)
                        self.heure1.insert(0, at:Int(key)!)
                    }
                    else{
                        date = subJson["date"].stringValue
                        print(date)
                        let premier_split = date.split(separator: "T", maxSplits: 1)
                        let second_split = premier_split[1].split(separator: ".", maxSplits: 1)
                        let troisieme_split = second_split[0].split(separator: ":")
                        
                        self.donnée.insert(valeur, at:Int(key)!)
                        self.heure1.insert(Double(troisieme_split[2])!, at:Int(key)!)
                    }
                }
                
                var tmp:Double
                
                for i in 0..<self.heure1.count
                {
                    for j in 0..<self.heure1.count
                    {
                        if(self.heure1[i] < self.heure1[j])
                        {
                            tmp = self.heure1[i];
                            self.heure1[i] = self.heure1[j];
                            self.heure1[j] = tmp;
                        }
                    }
                }
                
                print(self.donnée)
                print(self.heure1)
                self.setUp(dataPoints: self.donnée, values: self.heure1)
        }
    }
}

