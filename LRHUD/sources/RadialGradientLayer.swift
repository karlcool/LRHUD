//
//  RadialGradientLayer.swift
//  LRHUD
//
//  Created by 刘彦直 on 2021/12/13.
//

import UIKit
import CoreGraphics

class RadialGradientLayer: CALayer {
    var gradientCenter: CGPoint = .zero
    
    override func draw(in ctx: CGContext) {
        let locations: [CGFloat] = [0, 1]
        let colors: [CGFloat] = [0, 0, 0, 0, 0, 0, 0, 0.75]
        guard let gradient = CGGradient(colorSpace: CGColorSpaceCreateDeviceRGB(), colorComponents: colors, locations: locations, count: 2) else {
            return
        }
        ctx.drawRadialGradient(gradient, startCenter: gradientCenter, startRadius: 0, endCenter: gradientCenter, endRadius: min(bounds.size.width, bounds.size.height), options: .drawsAfterEndLocation)
    }
}
