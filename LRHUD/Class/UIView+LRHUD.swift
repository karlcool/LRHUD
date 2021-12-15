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
    
    lazy var infoImage: UIImage = {
        let temp: UIImage
        if #available(iOS 13.0, *) {
            temp = .init(systemName: "exclamationmark.circle") ?? .init()
        } else {
            temp = .init()
        }
        return temp.withRenderingMode(.alwaysTemplate)
    }()
    
    lazy var successImage: UIImage = {
        let temp: UIImage
        if #available(iOS 13.0, *) {
            temp = .init(systemName: "checkmark") ?? .init()
        } else {
            temp = .init()
        }
        return temp.withRenderingMode(.alwaysTemplate)
    }()
    
    lazy var errorImage: UIImage = {
        let temp: UIImage
        if #available(iOS 13.0, *) {
            temp = .init(systemName: "multiply") ?? .init()
        } else {
            temp = .init()
        }
        return temp.withRenderingMode(.alwaysTemplate)
    }()
    
    //MARK: - ImageAnimated
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
