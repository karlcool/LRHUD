//
//  ImageAnimatedView.swift
//  LRHUD
//
//  Created by 刘彦直 on 2021/12/14.
//

import UIKit

open class ImageAnimatedView: UIImageView, ImageAnimated {
    public var style: LRHUD.ImageStyle?
    
    private func animatedIconSucceed(_ view: UIView) {

        let length = view.frame.width
        let delay = (self.alpha == 0) ? 0.25 : 0.0

        let path = UIBezierPath()
        path.move(to: CGPoint(x: length * 0.15, y: length * 0.50))
        path.addLine(to: CGPoint(x: length * 0.5, y: length * 0.80))
        path.addLine(to: CGPoint(x: length * 1.0, y: length * 0.25))

        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = 0.25
        animation.fromValue = 0
        animation.toValue = 1
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        animation.beginTime = CACurrentMediaTime() + delay

        let layer = CAShapeLayer()
        layer.path = path.cgPath
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.lightGray.cgColor
        layer.lineWidth = 3
        layer.lineCap = .round
        layer.lineJoin = .round
        layer.strokeEnd = 0

        layer.add(animation, forKey: "animation")
        view.layer.addSublayer(layer)
    }
    
    //MARK: - ImageAnimated
    override open func startAnimating() {
        image = .init()
        animatedIconSucceed(self)
    }
    
    open func setup() {}

    open func set(image: UIImage) {}
    
    open func set(color: UIColor) {}
    
    open func set(radius: CGFloat) {}
    
    open func set(thickness: CGFloat) {}
}
