//
//  ImageAnimatedView.swift
//  LRHUD
//
//  Created by 刘彦直 on 2021/12/14.
//

import UIKit

class ImageAnimatedView: UIImageView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

extension ImageAnimatedView: ImageAnimated {
    func setup() {}

    func set(imageType: LRHUD.ImageType) {}
}
