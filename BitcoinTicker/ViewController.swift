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

class ViewController: UIViewController{
    
    let btcURL = "https://api.gemini.com/v1/pubticker/BTCUSD"
    let btcURL2 = "https://min-api.cryptocompare.com/data/histohour?fsym=BTC&tsym=USD&limit=1&toTS="
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

    @IBOutlet weak var Suggestion: UILabel!
    @IBOutlet weak var CenRating: UILabel!
    @IBOutlet weak var gtbcPriceLabel: UILabel!
 
    @IBAction func DisclaimerPressed(_ sender: Any) {
        let message = "The information contained in this presentation is solely for educational purposes and does not constitue investment advice.  We may or we may not take the trade. The risk of trading in securities markets can be substantial.  You should carefully consider if engaging in such activity is suitable to your own financial situation. I, Raymond Cen, am not responsible for any liabilities arising from the result of your market involvement or individual trade activities."
        
        // create the alert
        let alert = UIAlertController(title: "Warning", message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getLastClosePriceInfo()
      
        
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
                    let t1 = json["Data"].array!
                    let t2 = t1.sorted{ $0["time"] > $1["time"]  }
                    let t3 = t2[0]["close"]
                    self.lastCloseBTCPrice = String(t3.doubleValue)
                    
                    self.calculateCenRate()
                    
                    
                }
        }
        
    }
    
    func calculateCenRate(){
        
        if let myCurrentBTC = Double(self.currentBTCPrice) ,
            let myCurrentGBTC = Double(self.currentGBTCPrice) ,
            let myLastBTC = Double(self.lastCloseBTCPrice) ,
            let myLastGBTC = Double(self.lastCloseGBTCPrice) {
        
            var cenRating = Double(0)
            var message = ""
            
            let overnightFactor = myCurrentBTC / myLastBTC
            cenRating = pow(overnightFactor, Double(1.5)) * myLastGBTC
            if overnightFactor >  1{
                if(cenRating < myCurrentGBTC ){
                    message = "Sell!"
                    Suggestion.textColor = UIColor.red

                }
                else{
                    message = "Hold"
                    Suggestion.textColor = UIColor.yellow

                }
            }
            else {
                if(cenRating <= myCurrentGBTC ){
                    message = "Hold"
                    Suggestion.textColor = UIColor.yellow

                }
                else{
                    message = "buy!"
                    Suggestion.textColor = UIColor.green
                }
            }
            print(message)
            CenRating.text = "Cen's fair price: $" + String(cenRating)
            Suggestion.text = message
        }
        else
        {
            CenRating.text = ""
            Suggestion.text = ""
        }
        
    }

    func getLastClosePriceInfo(){
        let tickerURL = "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY_ADJUSTED&symbol=GBTC&outputsize=compact&apikey=TI75XBSBGNM4YZM6"
        Alamofire.request(tickerURL, method: .get)
            .responseJSON { response in
                if response.result.isSuccess {
                    let bitcoinJSON : JSON = JSON(response.result.value!)
                    
                    let t1 = bitcoinJSON["Time Series (Daily)"].dictionary!
                    let t2 = t1.sorted{ $0.key > $1.key }
                    let t3 = t2[1]
                    let t4 = t3.value
                    self.lastClosedDate = String(t3.key)
                    
                    if let tempResult = t4["4. close"].string {
                        
                        self.lastCloseGBTCPrice = tempResult
                        let closedDate = String(t3.key) + " 16:00:00"
                        
                        let myDate: Date = String(closedDate).toDate(dateFormat: "yyyy-MM-dd HH:mm:ss")!
                        let lastTimestamp =  Int(myDate.timeIntervalSince1970)
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
                if let tempResult = json["last"].string {
                    currentBTCPrice = tempResult
                    bitcoinPriceLabel.text = "BTC:\t$" + tempResult
                }
                else{
                    bitcoinPriceLabel.text = "BTC:\tPrice N/A"
                }
            }
            else{
            if(json["Time Series (1min)"].dictionary != nil){
                let t1 = json["Time Series (1min)"].dictionary!
                let t2 = t1.sorted{ $0.key > $1.key }
                let t3 = t2[0]
                let t4 = t3.value

                if let tempResult = t4["1. open"].string {
                    currentGBTCPrice = tempResult
                    gtbcPriceLabel.text = ticker + ":\t$" + tempResult
                }
                else{
                    gtbcPriceLabel.text = ticker + ": Price N/A"
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

