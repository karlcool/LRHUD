//
//  ProgressAnimatedView.swift
//  LRHUD
//
//  Created by 刘彦直 on 2021/12/13.
//

import UIKit

class ProgressAnimatedView: UIView {
    var strokeEnd: CGFloat = 0
    
    var strokeColor: UIColor = .clear {
        didSet {
            ringAnimatedLayer.strokeColor = strokeColor.cgColor
        }
    }
    
    var strokeThickness: CGFloat = 0 {
        didSet {
            ringAnimatedLayer.lineWidth = strokeThickness
        }
    }
    
    var radius: CGFloat = 0 {
        didSet {
            guard !radius.isEqual(to: oldValue) else {
                return
            }
            ringAnimatedLayer.removeFromSuperlayer()
            _ringAnimatedLayer = nil
            guard superview != nil else {
                return
            }
            layoutAnimatedLayer()
        }
    }
    
    override var frame: CGRect {
        didSet {
            guard !frame.equalTo(oldValue) else {
                return
            }
            guard superview != nil else {
                return
            }
            layoutAnimatedLayer()
        }
    }
    
    private var ringAnimatedLayer: CAShapeLayer {
        setupAnimatedLayer()
        return _ringAnimatedLayer!
    }
    
    private var _ringAnimatedLayer: CAShapeLayer?
    
    override func willMove(toSuperview newSuperview: UIView?) {
        if newSuperview != nil {
            layoutAnimatedLayer()
        } else {
            ringAnimatedLayer.removeFromSuperlayer()
            _ringAnimatedLayer = nil
        }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return .init(width: (radius + strokeThickness / 2 + 5) * 2, height: (radius + strokeThickness / 2 + 5) * 2)
    }
    
    func layoutAnimatedLayer() {
        layer.addSublayer(ringAnimatedLayer)
        let widthDiff = bounds.width - ringAnimatedLayer.bounds.width
        let heightDiff = bounds.height - ringAnimatedLayer.bounds.height
        ringAnimatedLayer.position = .init(x: bounds.width - ringAnimatedLayer.bounds.width / 2 - widthDiff / 2, y: bounds.height - ringAnimatedLayer.bounds.height / 2 - heightDiff / 2)
    }
    
    func setupAnimatedLayer() {
        guard _ringAnimatedLayer == nil else {
            return
        }
        let arcCenter = CGPoint(x: radius + strokeThickness / 2 + 5, y: radius + strokeThickness / 2 + 5)
        let smoothedPath = UIBezierPath(arcCenter: arcCenter, radius: radius, startAngle: -.pi / 2, endAngle: .pi / 2, clockwise: true)
        
        _ringAnimatedLayer = .init()
        _ringAnimatedLayer!.contentsScale = UIScreen.main.scale
        _ringAnimatedLayer!.frame = .init(x: 0, y: 0, width: arcCenter.x * 2, height: arcCenter.y * 2)
        _ringAnimatedLayer!.fillColor = UIColor.clear.cgColor
        _ringAnimatedLayer!.strokeColor = strokeColor.cgColor
        _ringAnimatedLayer!.lineWidth = strokeThickness
        _ringAnimatedLayer!.lineCap = .round
        _ringAnimatedLayer!.lineJoin = .bevel
        _ringAnimatedLayer!.path = smoothedPath.cgPath
    }
}
