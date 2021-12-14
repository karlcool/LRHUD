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
        LRHUD.set(defaultStyle: .dark)
//        LRHUD.set(defaultMaskType: .gradient)
        LRHUD.set(defaultAnimationType: .native)
        print("!")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        LRHUD.show()
        LRHUD.show(progress: 0.2, status: "加载中")
//        LRHUD.show(info: "这是info的内容，很长")
//        LRHUD.show(success: "这是info的内容，很长这是info的内容，很长")
    }

}

