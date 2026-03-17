//
//  ViewController.swift
//  DomainCheckSwift
//
//  Created by crazyLuobo on 03/17/2026.
//  Copyright (c) 2026 crazyLuobo. All rights reserved.
//

import UIKit
import DomainCheckSwift

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // 应用启动时（如 AppDelegate）必须先配置
        let config = DomainCheckConfig(
            checkDomainUrls: [
                "https://raw.githubusercontent.com/IFPLLIMIT/Kingfisher/refs/heads/master/README.md",
                "https://pastebin.com/raw/M9Y6kLv3",
                "https://hackmd.io/@IFPLLIMIT/HJWKWzbslx"
            ],
            startString: "KINGFISHERSTART",
            middleString: "LIMITED",
            endString: "ENDRUPEE"
        )
        DomainCheckManager.initialize(config: config)
        DomainCheckManager.share.hallNetworkCanConnect = {
            DomainCheckManager.share.getHallCanUserDomain { domail in
                print(domail)
            } failure: {
                
            }

            
        }
        
        DomainCheckManager.share.startCheckNetwork()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

