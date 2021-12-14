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
        
        print("!")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        LRHUD.show()
    }

}

