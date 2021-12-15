//
//  ImageAnimatedView.swift
//  LRHUD
//
//  Created by 刘彦直 on 2021/12/14.
//

import UIKit

open class ImageAnimatedView: UIImageView, ImageAnimated {
    public var style: LRHUD.ImageStyle? {
        didSet {
            if case .image(let _image) = style {
                image = _image
            } else {
                image = nil
            }
        }
    }
    
    private(set) var lineColor: UIColor = .clear
    
    private(set) var lineWidth: CGFloat = 1

    //MARK: - ImageAnimated
    override open func startAnimating() {
        guard let _style = style else {
            return
        }
        switch _style {
        case .info:
            animatedIconInfo(self)
        case .success:
            animatedIconSuccess(self)
        case .error:
            animatedIconError(self)
        default: break
        }
        
    }
    
    open func setup() {}

    open func set(image: UIImage) {}
    
    open func set(color: UIColor) {
        lineColor = color
    }
    
    open func set(radius: CGFloat) {}
    
    open func set(thickness: CGFloat) {
        lineWidth = thickness
    }
}

//MARK: - Animation
//from https://github.com/relatedcode/ProgressHUD
extension ImageAnimatedView {
    func animatedIconInfo(_ view: UIView) {
        let length = view.frame.width
        let delay = (self.alpha == 0) ? 0.25 : 0.0

        let path1 = UIBezierPath()
        path1.move(to: .init(x: length * 0.5, y: length * 0.15))
        path1.addLine(to: .init(x: length * 0.5, y: length * 0.70))
        
        let path2 = UIBezierPath()
        path2.move(to: .init(x: length * 0.5, y: length * 0.95))
        path2.addLine(to: .init(x: length * 0.5, y: length * 0.95))

        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = 0.15
        animation.fromValue = 0
        animation.toValue = 1
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        
        let paths = [path1, path2]
        for i in 0..<2 {
            let layer = CAShapeLayer()
            layer.path = paths[i].cgPath
            layer.fillColor = UIColor.clear.cgColor
            layer.strokeColor = lineColor.cgColor
            
            layer.lineWidth = i == 0 ? lineWidth : lineWidth * 1.7
            layer.lineCap = .round
            layer.lineJoin = .round
            layer.strokeEnd = 0

            animation.beginTime = CACurrentMediaTime() + 0.25 * Double(i) + delay

            layer.add(animation, forKey: "animation")
            view.layer.addSublayer(layer)
        }
    }
    
    func animatedIconSuccess(_ view: UIView) {
        let length = view.frame.width
        let delay = (self.alpha == 0) ? 0.25 : 0.0

        let path = UIBezierPath()
        path.move(to: .init(x: length * 0.15, y: length * 0.50))
        path.addLine(to: .init(x: length * 0.5, y: length * 0.80))
        path.addLine(to: .init(x: length * 1.0, y: length * 0.25))

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
        layer.strokeColor = lineColor.cgColor
        layer.lineWidth = lineWidth
        layer.lineCap = .round
        layer.lineJoin = .round
        layer.strokeEnd = 0

        layer.add(animation, forKey: "animation")
        view.layer.addSublayer(layer)
    }
    
    func animatedIconError(_ view: UIView) {
        let length = view.frame.width
        let delay = (self.alpha == 0) ? 0.25 : 0.0

        let path1 = UIBezierPath()
        path1.move(to: .init(x: length * 0.15, y: length * 0.15))
        path1.addLine(to: .init(x: length * 0.85, y: length * 0.85))
        
        let path2 = UIBezierPath()
        path2.move(to: .init(x: length * 0.85, y: length * 0.15))
        path2.addLine(to: .init(x: length * 0.15, y: length * 0.85))

        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = 0.15
        animation.fromValue = 0
        animation.toValue = 1
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        
        let paths = [path1, path2]
        for i in 0..<2 {
            let layer = CAShapeLayer()
            layer.path = paths[i].cgPath
            layer.fillColor = UIColor.clear.cgColor
            layer.strokeColor = lineColor.cgColor
            layer.lineWidth = lineWidth
            layer.lineCap = .round
            layer.lineJoin = .round
            layer.strokeEnd = 0

            animation.beginTime = CACurrentMediaTime() + 0.25 * Double(i) + delay

            layer.add(animation, forKey: "animation")
            view.layer.addSublayer(layer)
        }
    }
}
