//
//  ViewController.swift
//  LRHUD
//
//  Created by 刘彦直 on 2021/12/10.
//

import UIKit

class ViewController: UIViewController {
    let titles = ["show",
                  "show with status",
                  "show progress",
                  "show progress with status",
                  "show info with animation",
                  "show success with animation",
                  "show error with animation",
                  "show info with image",
                  "show success with image",
                  "show error with image",
                  "show with mask"]
    
    lazy var tableView: UITableView = {
        let result = UITableView(frame: view.bounds, style: .insetGrouped)
        result.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        result.dataSource = self
        result.delegate = self
        return result
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "LRHUD"
        
        view.addSubview(tableView)
        LRHUD.set(minimumDismissTimeInterval: 3)
        LRHUD.set(maximumDismissTimeInterval: 60)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        LRHUD.show(interaction: false)
//        LRHUD.show(progress: 0.2, status: "加载中")
//        LRHUD.show(info: "这是info的内容，很长")
//        LRHUD.show(success: "这是info的内容，很长这是info的内容，很长")
//        LRHUD.show(image: .add, status: "这是add")
        
    }

    @IBAction func click(_ sender: Any) {
        Task {
            await LRHUD.show(status: "loading")
            await Task.sleep(1000000000 * 10)
            await LRHUD.dismiss()
        }
        return
        if LRHUD.isVisible {
            LRHUD.dismiss()
        } else {
//            LRHUD.show(interaction: true)
            LRHUD.show(info: "这是info的内容，很长")
        }
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var config = UIListContentConfiguration.subtitleCell()
        config.text = titles[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell")!
        cell.contentConfiguration = config
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        LRHUD.set(maskStyle: .clear)
        LRHUD.register(imageAnimatedViewClass: ImageAnimatedView.self)
        if indexPath.row == 0 || indexPath.row == 1 {
            let status = indexPath.row == 0 ? nil : "loading"
            LRHUD.show(status: status, interaction: false)
        } else if indexPath.row == 2 || indexPath.row == 3 {
            let status = indexPath.row == 2 ? nil : "loading"
            Task {
                for i in 0 ... 10 {
                    await LRHUD.show(progress: Float(i) / 10, status: status)
                    await Task.sleep(100000000)
                }
                await LRHUD.show(success: "succeed")
            }
        } else if indexPath.row == 4 {
            LRHUD.show(info: "this is info")
        } else if indexPath.row == 5 {
            LRHUD.show(success: "this is success")
        } else if indexPath.row == 6 {
            LRHUD.show(error: "this is error")
        } else if indexPath.row == 7 {
            LRHUD.register(imageAnimatedViewClass: LRImageView.self)
            LRHUD.show(info: "this is info")
        } else if indexPath.row == 8 {
            LRHUD.register(imageAnimatedViewClass: LRImageView.self)
            LRHUD.show(success: "this is success")
        } else if indexPath.row == 9 {
            LRHUD.register(imageAnimatedViewClass: LRImageView.self)
            LRHUD.show(error: "this is error")
        } else if indexPath.row == 10 {
            LRHUD.set(maskStyle: .gradient)
            LRHUD.show(interaction: false)
        }
    }
}
let ddd = ["show",
              "show with status",
              "show progress",
              "show progress with status",
              "show info with animation",
              "show success with animation",
              "show error with animation",
              "show info with image",
              "show success with image",
              "show error with image",
              "show with mask"]
