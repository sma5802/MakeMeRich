//
//  BLGaugeView.swift
//  BitcoinTicker
//
//  Created by Test User on 2018/3/11.
//  Copyright © 2018年 London App Brewery. All rights reserved.
//

import UIKit
import Foundation

open class BLGaugeView: UIView {
    
    public var redColor    : UIColor?
    public var redLighterColor    : UIColor?
    public var yellowColor : UIColor?
    public var greenColor  : UIColor?
    public var greenLighterColor  : UIColor?
    
    public var labelFont   : UIFont?
    public var labelSize   : CGFloat?
    public var labelColor  : UIColor?
    
    public var needleColor : UIColor?
    var percentValue: CGFloat = 0.0
    
    let totalDegree = CGFloat(3/2*Double.pi)
    let baseDegree  = CGFloat(5/4*Double.pi)
    
    private let percentLabelValues = [0, 0.2, 0.4, 0.6, 0.8, 1]
    private let percentDistanceIncrementValues: [CGFloat] = [0, 18, 18, 12, 3, 0]
    
    internal var centerPoint: CGPoint {
        get {
            return CGPoint(x: centerX, y: centerY)
        }
    }
    
    private var centerX : CGFloat {
        get {
            return self.frame.width/2
        }
    }
    
    private var centerY : CGFloat {
        get {
            return self.frame.height/2
        }
    }
    
    
    var bgRadius: CGFloat {
        get {
            let centerValue = centerY < centerX ? centerY : centerX
            return centerValue - (centerValue*0.3)
        }
    }
    
    var needleRadius: CGFloat {
        get {
            let size = self.bounds.size
            return (size.height < size.width ? size.height : size.width) * 0.04
        }
    }
    
    var needleDegree: CGFloat {
        get {
            return baseDegree + (percentValue*totalDegree)
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        isOpaque        = false
        contentMode     = .redraw
    }
    
    open override func draw(_ rect: CGRect) {
        self.drawBackground()
        self.drawNeedle()
        //self.drawLabels()
    }
    
    
    private func drawBackground() {
        
        let startRedDegree  = CGFloat(3/4 * Double.pi)
        let endRedDegree    = startRedDegree + CGFloat(6/10 * Double.pi)
        let startLighterRedDegree  = endRedDegree
        let endLighterRedDegree    = startLighterRedDegree + CGFloat(3/40 * Double.pi)
        
        let startYellowDegree  = endLighterRedDegree
        let endYellowDegree    = startYellowDegree + CGFloat(3/20 * Double.pi)
        let startLigterGreenDegree   = endYellowDegree
        let endLighterGreenDegree     = endYellowDegree + CGFloat(3/40 * Double.pi)
        
        let startGreenDegree   = endLighterGreenDegree
        let endGreenDegree     = CGFloat(9/4 * Double.pi)
        
        let redColor = self.redColor ?? BLGaugeColors.red()
        let redLighterColor = self.redLighterColor ?? BLGaugeColors.redLighter()
        let yellowColor = self.yellowColor ?? BLGaugeColors.yellow()
        let greenColor = self.greenColor ?? BLGaugeColors.green()
        let greenLighterColor = self.greenLighterColor ?? BLGaugeColors.greenLighter()
        
        
        drawPathColored(fromDegree: startRedDegree, toDegree: endRedDegree, color: redColor)
        drawPathColored(fromDegree: startLighterRedDegree, toDegree: endLighterRedDegree, color: redLighterColor)
        drawPathColored(fromDegree: startYellowDegree, toDegree: endYellowDegree, color: yellowColor)
        drawPathColored(fromDegree: startLigterGreenDegree, toDegree: endLighterGreenDegree, color: greenLighterColor)
        drawPathColored(fromDegree: startGreenDegree, toDegree: endGreenDegree, color: greenColor)
        
        drawPathCleaner(fromDegree: startRedDegree, toDegree: endGreenDegree)
    }
    
    func drawPathColored(fromDegree: CGFloat, toDegree: CGFloat, color: UIColor) {
        let bgPath = UIBezierPath()
        bgPath.move(to: self.centerPoint)
        
        let baseNeedleAngle = needleDegree - CGFloat(1/2*Double.pi)
        
        let startAngle = fromDegree
        
        var endAngle = toDegree
        
        if baseNeedleAngle > fromDegree && baseNeedleAngle <= toDegree {
            endAngle = baseNeedleAngle
            drawPathColored(fromDegree: baseNeedleAngle, toDegree: toDegree, color: color)
        }
        
        bgPath.addArc(withCenter: self.centerPoint, radius: self.bgRadius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        bgPath.addLine(to: centerPoint)
        
        let pathColor = baseNeedleAngle > fromDegree ? color : color.lighterColor()
        pathColor.set()
        
        bgPath.fill()
    }
    
    func drawPathCleaner(fromDegree: CGFloat, toDegree: CGFloat) {
        let bgPathCleaner = UIBezierPath()
        bgPathCleaner.move(to: self.centerPoint)
        
        let innerRadius = self.bgRadius - (self.bgRadius * 0.20)
        bgPathCleaner.addArc(withCenter:  self.centerPoint, radius: innerRadius, startAngle: fromDegree, endAngle: toDegree, clockwise: true)
        bgPathCleaner.addLine(to: self.centerPoint)
        
        UIColor.black.set()
        
        bgPathCleaner.stroke()
        bgPathCleaner.fill()
    }
    
    func drawNeedle() {
        let distance    = self.bgRadius - self.bgRadius*0.1
        let startTime   = CGFloat(0.0)
        let endTime     = CGFloat(Double.pi)
        let topSpace    = (distance*0.1)/6
        
        let center = self.centerPoint
        
        let topPoint    = CGPoint(x: center.x, y: center.y - distance)
        let topPoint1   = CGPoint(x: center.x - topSpace, y: center.y - (distance*0.9))
        let topPoint2   = CGPoint(x: center.x + topSpace, y: center.y - (distance*0.9))
        let finishPoint = CGPoint(x: center.x + needleRadius, y: center.y)
        
        
        let needlePath = UIBezierPath()
        needlePath.move(to: centerPoint)
        
        let nextX = centerPoint.x + needleRadius * cos(startTime)
        let nextY = centerPoint.y + needleRadius * sin(startTime)
        
        let next = CGPoint(x: nextX, y: nextY)
        needlePath.addLine(to: next)
        needlePath.addArc(withCenter: centerPoint, radius: needleRadius, startAngle: startTime, endAngle: endTime, clockwise: true)
        
        needlePath.addLine(to: topPoint1)
        needlePath.addQuadCurve(to: topPoint2, controlPoint: topPoint)
        needlePath.addLine(to: finishPoint)
        
        var translate = CGAffineTransform(translationX: -1 * (self.bounds.origin.x +  centerPoint.x), y: -1 * (self.bounds.origin.y + centerPoint.y))
        needlePath.apply(translate)
        
        let rotate = CGAffineTransform(rotationAngle: needleDegree)
        needlePath.apply(rotate)
        
        translate = CGAffineTransform(translationX: self.bounds.origin.x + centerPoint.x, y: self.bounds.origin.y + centerPoint.y)
        needlePath.apply(translate)
        
        let needleColor = self.needleColor ?? BLGaugeColors.grey()
        needleColor.set()
        needlePath.fill()
    }
    
    func drawLabels() {
        for i in 0..<percentLabelValues.count {
            let value = percentLabelValues[i]
            let incrementValue = percentDistanceIncrementValues[i]
            
            let degree = CGFloat((3/4*Double.pi)+(value*3/2*Double.pi))
            self.drawLabel(title: "\(Int(value*100))" as NSString, onPoint: centerPoint.pointFrom(distance: bgRadius+incrementValue, andDegree: degree))
        }
    }
    
    func drawLabel(title: NSString, onPoint: CGPoint) {
        let rectToDraw = CGRect(x: onPoint.x, y: onPoint.y, width: 60.0, height: 30.0)
        
        let labelColor = self.labelColor ?? BLGaugeColors.grey700()
        let attrs = [NSAttributedStringKey.foregroundColor: labelColor,
                     NSAttributedStringKey.font: labelFont ?? UIFont.systemFont(ofSize: labelSize ?? 12.0)]
        
        title.draw(in: rectToDraw, withAttributes: attrs)
    }
    
    
    
    
    public func setPercentValue(percentValue: CGFloat) {
        
        self.percentValue = percentValue
        
        if self.percentValue > 1 {
            self.percentValue = 1
        }
        
        if self.percentValue < 0 {
            self.percentValue = 0
        }
        
        self.setNeedsDisplay()
    }
    
    
    
}

extension UIColor {
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }
    
    
    func lighterColor() -> UIColor {
        let lighterColor    = CIColor.init(color: self)
        let red             = lighterColor.red
        let green           = lighterColor.green
        let blue            = lighterColor.blue
        let alpha           = lighterColor.alpha
        
        let lighterStep: CGFloat = 0.25
        
        return UIColor(red: min(red+lighterStep, 1.0), green: min(green+lighterStep, 1), blue: min(blue+lighterStep, 1), alpha: alpha)
    }
    
}

extension CGPoint {
    func pointFrom(distance: CGFloat, andDegree: CGFloat) -> CGPoint {
        return CGPoint(x: self.x+cos(andDegree)*distance, y: self.y+sin(andDegree)*distance)
    }
}

open class BLGaugeColors {
    
    class func red() -> UIColor {
        return UIColor.init(hex: "FF4500")
    }
    class func redLighter() -> UIColor {
        return UIColor.init(hex: "880000")
    }
    
    class func yellow() -> UIColor {
        return UIColor.init(hex: "FFEB3B")
    }
    
    class func green() -> UIColor {
        return UIColor.init(hex: "008000")
    }
    class func greenLighter() -> UIColor {
        return UIColor.init(hex: "7CFC00")
    }
    
    class func grey() -> UIColor {
        return UIColor.init(hex: "9E9E9E")
    }
    
    class func grey700() -> UIColor {
        return UIColor.init(hex: "616161")
    }
}





