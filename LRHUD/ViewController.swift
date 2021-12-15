//
//  ViewController.swift
//  LRHUD
//
//  Created by 刘彦直 on 2021/12/10.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        LRHUD.set(minimumDismissTimeInterval: 50)
        LRHUD.set(maximumDismissTimeInterval: 60)
//        LRHUD.set(style: .dark)
//        LRHUD.set(hudForegroundColor: .white)
//        LRHUD.set(hudBackgroundColor: .hex(0x162926, alpha: 0.77))
        LRHUD.set(cornerRadius: 8)
        LRHUD.set(font: .systemFont(ofSize: 14))
//        LRHUD.register(imageAnimatedViewClass: LRImageView.self)
//        LRHUD.register(indefiniteAnimatedViewClass: UIActivityIndicatorView.self)
//        LRHUD.set(maskStyle: .gradient)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        LRHUD.show(interaction: false)
//        LRHUD.show(progress: 0.2, status: "加载中")
//        LRHUD.show(info: "这是info的内容，很长")
        LRHUD.show(success: "这是info的内容，很长这是info的内容，很长")
//        LRHUD.show(image: .add, status: "这是add")
    }

    @IBAction func click(_ sender: Any) {
        if LRHUD.isVisible {
            LRHUD.dismiss()
        } else {
//            LRHUD.show(interaction: true)
            LRHUD.show(info: "这是info的内容，很长")
        }
    }
}


extension UIColor {
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let red = CGFloat(CGFloat((hex & 0xFF0000) >> 16) / 255.0)
        let green = CGFloat(CGFloat((hex & 0x00FF00) >> 8) / 255.0)
        let blue = CGFloat(CGFloat((hex & 0x0000FF) >> 0) / 255.0)
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, alpha: CGFloat = 1.0) {
        self.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: alpha)
    }
    
    static func hex(_ hex: Int, alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(hex: hex, alpha: alpha)
    }
}
