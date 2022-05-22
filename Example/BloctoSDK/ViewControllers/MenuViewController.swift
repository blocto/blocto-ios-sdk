//
//  MenuViewController.swift
//  BloctoSDK_Example
//
//  Created by Andrew Wang on 2022/5/11.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift

final class MenuViewController: UIViewController {

    private var solanaButton: UIButton = {
        let button: UIButton = UIButton()
        button.setTitle("Solana Demo", for: .normal)
        button.setTitleColor(.darkGray, for: .normal)
        button.setTitleColor(.gray, for: .highlighted)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return button
    }()

    private var evmBaseButton: UIButton = {
        let button: UIButton = UIButton()
        button.setTitle("EVM Base Demo", for: .normal)
        button.setTitleColor(.darkGray, for: .normal)
        button.setTitleColor(.gray, for: .highlighted)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupBinding()

        title = "Menu"
    }

    private func setupViews() {
        view.backgroundColor = .white
        view.addSubview(solanaButton)
        view.addSubview(evmBaseButton)

        solanaButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(50)
            $0.centerX.equalToSuperview()
        }

        evmBaseButton.snp.makeConstraints {
            $0.top.equalTo(solanaButton.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
        }
    }

    private func setupBinding() {
        _ = solanaButton.rx.tap
            .throttle(
                DispatchTimeInterval.milliseconds(500),
                latest: false,
                scheduler: MainScheduler.instance)
            .take(until: rx.deallocated)
            .subscribe(onNext: { [weak self] _ in
                let solanaViewController = SolanaDemoViewController()
                self?.navigationController?.pushViewController(
                    solanaViewController,
                    animated: true)
            })

        _ = evmBaseButton.rx.tap
            .throttle(
                DispatchTimeInterval.milliseconds(500),
                latest: false,
                scheduler: MainScheduler.instance)
            .take(until: rx.deallocated)
            .subscribe(onNext: { [weak self] _ in
                let evmBaseDemoViewController = EVMBaseDemoViewController()
                self?.navigationController?.pushViewController(
                    evmBaseDemoViewController,
                    animated: true)
            })
    }

}
