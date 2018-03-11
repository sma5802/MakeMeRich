//
//  ViewController.swift
//  BitcoinTicker
//
//  Created by Angela Yu on 23/01/2016.
//  Copyright © 2016 London App Brewery. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SVProgressHUD
import Foundation

class ViewController: UIViewController{
    
    let btcURL = "https://api.gemini.com/v1/pubticker/BTCUSD"
    let btcURL2 = "https://api.gemini.com/v1/trades/btcusd?since="
    let stockURL = "https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&symbol="
    let stockURL2 = "&interval=1min&outputsize=compact&apikey=TI75XBSBGNM4YZM6"
    var finalURL = ""
    var lastCloseGBTCPrice = ""
    var lastCloseBTCPrice = ""
    var currentGBTCPrice = ""
    var currentBTCPrice = ""
    var lastClosedDate = ""


    //Pre-setup IBOutlets
    @IBOutlet weak var bitcoinPriceLabel: UILabel!

    
    @IBOutlet weak var ClosedBTCPrice: UILabel!
    
    @IBOutlet weak var myGauge: BLGaugeView!
    @IBOutlet weak var OvernightFactor: UILabel!
    @IBOutlet weak var ClosedGBTCPrice: UILabel!
    @IBOutlet weak var Suggestion: UILabel!
    @IBOutlet weak var CenRating: UILabel!
    @IBOutlet weak var gtbcPriceLabel: UILabel!
 

    @IBAction func DisclaimerPressed(_ sender: Any) {
        let message = "This application is solely for educational purpose and should not be taken as an investment advice.  Viewer's own judgement is highly recommended since financial market can be precarious and subjected to substantial risk.  Any financial result using this application is viewer's own responsibility."
        
        // create the alert
        let alert = UIAlertController(title: "Warning", message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        getLastGBTCClosePriceInfo()
      
        
        Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)

        getTickerData(ticker:"BTC")
        getTickerData(ticker:"GBTC")
        
       
    }
    
    @objc func update() {
        getTickerData(ticker:"BTC")
        getTickerData(ticker:"GBTC")
        calculateCenRate()
        
    }
    
    
//    
//    //MARK: - Networking
//    /***************************************************************/
//    
    func getTickerData(ticker: String) {
        
        let tickerURL = ticker == "BTC" ? btcURL : stockURL + ticker + stockURL2
        print(tickerURL)
        Alamofire.request(tickerURL, method: .get)
            .responseJSON { response in
                if response.result.isSuccess {
                    let bitcoinJSON : JSON = JSON(response.result.value!)

                    self.updateBitcoinData(json: bitcoinJSON, ticker:ticker)

                } else {
                    print("Error: \(String(describing: response.result.error))")
                    self.bitcoinPriceLabel.text = "Connection Issues"
                }
            }

    }
    
    func getLastBTCPrice(timestamp ts:Int) {
        
        let tickerURL = btcURL2 + String(ts)
        print(tickerURL)
        Alamofire.request(tickerURL, method: .get)
            .responseJSON { response in
                if response.result.isSuccess {
                    let json : JSON = JSON(response.result.value!)
           
                    let t1 = json.array!
                    let t2 = t1.sorted{ $0["timestamp"] < $1["timestamp"]  }
                    let t3 = t2[0]["price"]
                    self.lastCloseBTCPrice = String(t3.doubleValue)
                    let myValue = Int(t3.doubleValue)
                    
                    self.ClosedBTCPrice.text = String(format: "$%d", myValue)
                    self.calculateCenRate()
                }
        }
        
    }
    
    func calculateCenRate(){
        
        
        if let myCurrentBTC = Double(self.currentBTCPrice) ,
            let myCurrentGBTC = Double(self.currentGBTCPrice) ,
            let myLastBTC = Double(self.lastCloseBTCPrice) ,
            let myLastGBTC = Double(self.lastCloseGBTCPrice) {
            
            print("Current BTC: '\(myCurrentBTC)'")
            print("Current GBTC: '\(myCurrentGBTC)'")
            print("Last BTC at 4:00 PM:  '\(myLastBTC)'")
            print("Last GBTC at 4:00 PM: '\(myLastGBTC)'")
            
            var cenRating = Double(0)
            
            
            let overnightFactor = myCurrentBTC / myLastBTC
            let roundedFactor = String(format: "%.3f",overnightFactor)
            OvernightFactor.text = String(roundedFactor)
            print("Overnight factor: '\(roundedFactor)'")
            cenRating = pow(overnightFactor, Double(1.5)) * myLastGBTC
            print("Cen Rating: pow(overnightFactor, Double(1.5)) * myLastGBTC = '\(cenRating)'")
            var message = ""
            var percentage = 0.0

            if overnightFactor >  1{
                if(cenRating < myCurrentGBTC ){
                    message = "Sell"
                    percentage = 0.5 + (myCurrentGBTC - cenRating) / myCurrentGBTC
                }
                else{
                    message = "Hold"
                    percentage = 0.525
                }
            }
            else {
                if(cenRating <= myCurrentGBTC ){
                    message = "Hold"
                    percentage = 0.475
                }
                else{
                    message = "Buy"
                    percentage = 0.5 - (cenRating - myCurrentGBTC) / myCurrentGBTC
                }
            }
            print(message)
            CenRating.text = String(format: "$%.2f",cenRating)
            
            myGauge.setPercentValue(percentValue: CGFloat(percentage))
            
        }
        else
        {
            CenRating.text = ""
        }
        SVProgressHUD.dismiss()
        
    }

    func getLastGBTCClosePriceInfo(){
        let tickerURL = "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY_ADJUSTED&symbol=GBTC&outputsize=compact&apikey=TI75XBSBGNM4YZM6"
        print(tickerURL)
        SVProgressHUD.show()
        Alamofire.request(tickerURL, method: .get)
            .responseJSON { response in
                if response.result.isSuccess {
                    let bitcoinJSON : JSON = JSON(response.result.value!)
                    
                    let t1 = bitcoinJSON["Time Series (Daily)"].dictionary!
                    let t2 = t1.sorted{ $0.key > $1.key }
                    //get today's date
                    let today = Date()
                    let hour = Calendar.current.component(.hour, from: today)
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    let todayString = dateFormatter.string(from: today)
                    print(t2[0].key)
                    print(t2[1].key)
                    let t3 = String(t2[0].key) == todayString && hour < 16 ? t2[1] : t2[0]
                    let t4 = t3.value
                    self.lastClosedDate = String(t3.key)
                    
                    if let tempResult = t4["4. close"].string {
                        
                        self.lastCloseGBTCPrice = tempResult
                        if let myValue = Float(tempResult) {
                             self.ClosedGBTCPrice.text = String(format: "$%.2f",myValue)
                        }
                       
                        let closedDate = String(t3.key) + " 16:00:00"
                        
                        let myDate: Date = String(closedDate).toDate(dateFormat: "yyyy-MM-dd HH:mm:ss")!
                        let lastTimestamp =  Int(myDate.timeIntervalSince1970)
                        print(closedDate)
                        print(Int(lastTimestamp))
                        self.getLastBTCPrice(timestamp: lastTimestamp)
                    }
                    
                }
        }
        
    }
    
    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
    
    func updateBitcoinData(json : JSON, ticker:String) {
        if(ticker == "BTC"){
                let tempResult = json["last"].doubleValue
                currentBTCPrice = String(tempResult)
                let myBTCValue = Int(tempResult)
                bitcoinPriceLabel.text = String(format: "$%d",myBTCValue)
            }
            else{
            if(json["Time Series (1min)"].dictionary != nil){
                let t1 = json["Time Series (1min)"].dictionary!
                let t2 = t1.sorted{ $0.key > $1.key }
                let t3 = t2[0]
                let t4 = t3.value

                if let tempResult = t4["1. open"].string {
                    currentGBTCPrice = tempResult
                    if let myValue = Double(tempResult) {
                        gtbcPriceLabel.text = String(format: "$%.2f",myValue)
                    }
                    else{
                        gtbcPriceLabel.text = ""
                    }
                    
                }
                else{
                    gtbcPriceLabel.text = "N/A"
                }
                }
            }
        }
}

extension String{
    func toDate(dateFormat format : String) -> Date?{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.date(from: self)
    }
}
