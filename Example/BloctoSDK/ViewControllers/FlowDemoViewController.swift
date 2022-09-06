//
//  FlowDemoViewController.swift
//  BloctoSDK_Example
//
//  Created by Andrew Wang on 2022/7/8.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import SafariServices
import SnapKit

// swiftlint:disable type_body_length file_length
final class FlowDemoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Flow"

        view.backgroundColor = .white
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "Please refer to https://github.com/portto/fcl-swift/tree/main/Demo for Flow Demo"
        view.addSubview(label)
        label.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(50)
        }

        let button = UIButton()
        button.setTitle("go to demo", for: .normal)
        button.contentEdgeInsets = .init(top: 5, left: 10, bottom: 5, right: 10)
        button.backgroundColor = .blue
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        view.addSubview(button)
        button.snp.makeConstraints {
            $0.top.equalTo(label.snp.bottom).offset(100)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(50)
        }
        button.addTarget(self, action: #selector(onRoute), for: .touchUpInside)

    }

    @objc
    func onRoute() {
        guard let url = URL(string: "https://github.com/portto/fcl-swift/tree/main/Demo") else {
            return
        }
        let safariVC = SFSafariViewController(url: url)
        safariVC.delegate = self
        present(safariVC, animated: true, completion: nil)
    }

}

// MARK: SFSafariViewControllerDelegate

extension FlowDemoViewController: SFSafariViewControllerDelegate {}
