//
//  UIView+LRHUD.swift
//  LRHUD
//
//  Created by 刘彦直 on 2021/12/14.
//

import UIKit

extension UIActivityIndicatorView: IndefiniteAnimated {
    public func setup() {
        if #available(iOS 13.0, *) {
            style = .large
        } else {
            style = .gray
        }
    }
    
    public func set(color: UIColor) {
        self.color = color
    }
    
    public func set(radius: CGFloat) {}
    
    public func set(thickness: CGFloat) {}
}

open class LRImageView: UIImageView, ImageAnimated {
    public var style: LRHUD.ImageStyle? {
        didSet {
            guard let _style = style else {
                return
            }
            switch _style {
            case .info:
                image = infoImage
            case .success:
                image = successImage
            case .error:
                image = errorImage
            case .named(_):
                image = infoImage
            case .image(let _image):
                image = _image
            }
        }
    }
    
    var infoImage: UIImage = (UIImage(systemName: "exclamationmark.circle") ?? UIImage()).withRenderingMode(.alwaysTemplate)
    
    var successImage: UIImage = (UIImage(systemName: "checkmark") ?? UIImage()).withRenderingMode(.alwaysTemplate)
    
    var errorImage: UIImage = (UIImage(systemName: "multiply") ?? UIImage()).withRenderingMode(.alwaysTemplate)

    open func setup() {}

    open func set(color: UIColor) {
        tintColor = color
    }
    
    open func set(radius: CGFloat) {}
    
    open func set(thickness: CGFloat) {}
}

public extension LRHUD {
    static func set(infoImage: UIImage) {
        if sharedView.imageAnimatedViewClass != LRImageView.self {
            register(imageAnimatedViewClass: LRImageView.self)
        }
        (sharedView.imageAnimatedView as? LRImageView)?.infoImage = infoImage
    }
    
    static func set(successImage: UIImage) {
        if sharedView.imageAnimatedViewClass != LRImageView.self {
            register(imageAnimatedViewClass: LRImageView.self)
        }
        (sharedView.imageAnimatedView as? LRImageView)?.successImage = successImage
    }
    
    static func set(errorImage: UIImage) {
        if sharedView.imageAnimatedViewClass != LRImageView.self {
            register(imageAnimatedViewClass: LRImageView.self)
        }
        (sharedView.imageAnimatedView as? LRImageView)?.errorImage = errorImage
    }
}
