//
//  ImageAnimatedView.swift
//  LRHUD
//
//  Created by 刘彦直 on 2021/12/14.
//

import UIKit

class ImageAnimatedView: UIImageView {
    
    var infoImage: UIImage = .init(systemName: "exclamationmark.circle") ?? .init()
    
    var successImage: UIImage = .init(systemName: "checkmark") ?? .init()
    
    var errorImage: UIImage = .init(systemName: "multiply") ?? .init()

}

extension ImageAnimatedView: ImageAnimated {
    func setup() {}

    func image(forType: LRHUD.ImageType) -> UIImage {
        switch forType {
        case .error:
            return errorImage
        case .info:
            return infoImage
        case .success:
            return successImage
        case .named(_):
            return infoImage
        }
    }
}
