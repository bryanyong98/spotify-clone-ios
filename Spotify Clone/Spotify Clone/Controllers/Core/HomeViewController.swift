//
//  ViewController.swift
//  Spotify Clone
//
//  Created by Bryan Yong on 03/09/2023.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home"
        let button = UIBarButtonItem(
            image: UIImage(systemName: "gear"),
            style: .done,
            target: self,
            action: #selector(didTapSettings)
        )
        button.tintColor = .systemBlue
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = button
    }

    @objc func didTapSettings() {
        let vc = SettingsViewController()
        vc.title = "Settings"
        vc .navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}

