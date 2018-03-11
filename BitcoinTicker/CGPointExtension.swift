//
//  SFGaugeView.swift
//  Pods
//
//  Created by Bruno Lima on 21/09/17.
//
//

extension CGPoint {
    func pointFrom(distance: CGFloat, andDegree: CGFloat) -> CGPoint {
        return CGPoint(x: self.x+cos(andDegree)*distance, y: self.y+sin(andDegree)*distance)
    }
}