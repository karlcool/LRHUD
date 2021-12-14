//
//  IndefiniteAnimatedView.swift
//  LRHUD
//
//  Created by 刘彦直 on 2021/12/10.
//

import UIKit

class IndefiniteAnimatedView: UIView {
    var strokeColor: UIColor = .clear {
        didSet {
            indefiniteAnimatedLayer.strokeColor = strokeColor.cgColor
        }
    }
    
    var strokeThickness: CGFloat = 2 {
        didSet {
            indefiniteAnimatedLayer.lineWidth = strokeThickness
        }
    }
    
    var radius: CGFloat = 0 {
        didSet {
            guard !radius.isEqual(to: oldValue) else {
                return
            }
            indefiniteAnimatedLayer.removeFromSuperlayer()
            _indefiniteAnimatedLayer = nil
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
    
    private var indefiniteAnimatedLayer: CAShapeLayer {
        setupAnimatedLayer()
        return _indefiniteAnimatedLayer!
    }
    
    private var _indefiniteAnimatedLayer: CAShapeLayer?
    
    override func willMove(toSuperview newSuperview: UIView?) {
        if newSuperview != nil {
            layoutAnimatedLayer()
        } else {
            indefiniteAnimatedLayer.removeFromSuperlayer()
            _indefiniteAnimatedLayer = nil
        }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return .init(width: (radius + strokeThickness / 2 + 5) * 2, height: (radius + strokeThickness / 2 + 5) * 2)
    }
    
    func layoutAnimatedLayer() {
        layer.addSublayer(indefiniteAnimatedLayer)
        let widthDiff = bounds.width - indefiniteAnimatedLayer.bounds.width
        let heightDiff = bounds.height - indefiniteAnimatedLayer.bounds.height
        indefiniteAnimatedLayer.position = .init(x: bounds.width - indefiniteAnimatedLayer.bounds.width / 2 - widthDiff / 2, y: bounds.height - indefiniteAnimatedLayer.bounds.height / 2 - heightDiff / 2)
    }
    
    func setupAnimatedLayer() {
        guard _indefiniteAnimatedLayer == nil else {
            return
        }
        let arcCenter = CGPoint(x: radius + strokeThickness / 2 + 5, y: radius + strokeThickness / 2 + 5)
        let smoothedPath = UIBezierPath(arcCenter: arcCenter, radius: radius, startAngle: .pi * 3 / 2, endAngle: .pi / 2 + .pi * 5, clockwise: true)
        
        _indefiniteAnimatedLayer = .init()
        _indefiniteAnimatedLayer!.contentsScale = UIScreen.main.scale
        _indefiniteAnimatedLayer!.frame = .init(x: 0, y: 0, width: arcCenter.x * 2, height: arcCenter.y * 2)
        _indefiniteAnimatedLayer!.fillColor = UIColor.clear.cgColor
        _indefiniteAnimatedLayer!.strokeColor = strokeColor.cgColor
        _indefiniteAnimatedLayer!.lineWidth = strokeThickness
        _indefiniteAnimatedLayer!.lineCap = .round
        _indefiniteAnimatedLayer!.lineJoin = .bevel
        _indefiniteAnimatedLayer!.path = smoothedPath.cgPath
        
//        let bundle = Bundle(for: LRHUD.self)
//        let url = bundle.url(forResource: "LRHUD", withExtension: "bundle")!
//        let imageBundle = Bundle(url: url)!
//
        let maskLayer = CALayer()
//        let path = imageBundle.path(forResource: "angle-mask", ofType: "png")!
//        maskLayer.contents = UIImage(contentsOfFile: path)?.cgImage
        maskLayer.contents = UIImage(named: "angle-mask")
        maskLayer.frame = _indefiniteAnimatedLayer!.bounds
        _indefiniteAnimatedLayer!.mask = maskLayer
        
        let animationDuration: TimeInterval = 1
        let timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.fromValue = 0
        animation.toValue = CGFloat.pi * 2
        animation.duration = animationDuration
        animation.timingFunction = timingFunction
        animation.isRemovedOnCompletion = false
        animation.repeatCount = .infinity
        animation.fillMode = .forwards
        animation.autoreverses = false
        _indefiniteAnimatedLayer!.mask?.add(animation, forKey: "rotate")
        
        let strokeStartAnimation = CABasicAnimation(keyPath: "strokeStart")
        strokeStartAnimation.fromValue = 0.015
        strokeStartAnimation.toValue = 0.515
        
        let strokeEndAnimation = CABasicAnimation(keyPath: "strokeEnd")
        strokeEndAnimation.fromValue = 0.485
        strokeEndAnimation.toValue = 0.985
        
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = animationDuration
        animationGroup.duration = .infinity
        animationGroup.isRemovedOnCompletion = false
        animationGroup.timingFunction = timingFunction
        animationGroup.animations = [strokeStartAnimation, strokeEndAnimation]
        _indefiniteAnimatedLayer!.mask?.add(animationGroup, forKey: "progress")
    }
}

extension IndefiniteAnimatedView: IndefiniteAnimated {
    func startAnimating() {
        
    }
    
    func stopAnimating() {
        
    }
    
    func set(color: UIColor) {
        strokeColor = color
    }
    
    func set(radius: CGFloat) {
        self.radius = radius
    }
    
    func set(thickness: CGFloat) {
        strokeThickness = thickness
    }
}
