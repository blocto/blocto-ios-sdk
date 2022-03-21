//
//  ViewController.swift
//  BloctoSDK
//
//  Created by scottphc on 01/12/2022.
//  Copyright (c) 2022 scottphc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import BloctoSDK

final class ViewController: UIViewController {
    
    private var requestAccountButton: UIButton = {
        let button: UIButton = UIButton()
        button.setTitle("request account", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .blue
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.contentEdgeInsets = .init(top: 12, left: 12, bottom: 12, right: 12)
        return button
    }()
    
    private var textField: UITextField = {
        let textField = UITextField()
        return textField
    }()

    private var sendButton: UIButton = {
        let button: UIButton = UIButton()
        button.setTitle("send transaction", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .blue
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.contentEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
        return button
    }()
    
    private lazy var disposeBag: DisposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupBinding()
    }

    private func setupViews() {
        view.backgroundColor = .white
        
        view.addSubview(requestAccountButton)
        
        requestAccountButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(50)
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(50)
        }
    }
    
    private func setupBinding() {
        _ = requestAccountButton.rx.tap
            .throttle(
                DispatchTimeInterval.milliseconds(500),
                latest: false,
                scheduler: MainScheduler.instance)
            .take(until: rx.deallocated)
            .subscribe(onNext: { [weak self] _ in
                BloctoSDK.shared.solana.requestAccount { [weak self] result in
                    switch result {
                    case .success(let address):
                        self?.requestAccountButton.setTitle(address, for: .normal)
                    case .failure(let error):
                        self?.requestAccountButton.setTitle(error.localizedDescription, for: .normal)
                    }
                }
            })
    }

}
